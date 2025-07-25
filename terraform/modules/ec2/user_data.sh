#!/bin/bash

# Update system
apt-get update -y
apt-get upgrade -y

# Install basic packages
apt-get install -y \
    curl \
    wget \
    unzip \
    htop \
    tree \
    git \
    vim \
    awscli \
    amazon-cloudwatch-agent \
    nginx

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
    "metrics": {
        "namespace": "CWAgent",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/syslog",
                        "log_group_name": "/aws/ec2/${environment}-${project_name}-standalone",
                        "log_stream_name": "{instance_id}/syslog"
                    },
                    {
                        "file_path": "/var/log/nginx/access.log",
                        "log_group_name": "/aws/ec2/${environment}-${project_name}-standalone",
                        "log_stream_name": "{instance_id}/nginx-access"
                    },
                    {
                        "file_path": "/var/log/nginx/error.log",
                        "log_group_name": "/aws/ec2/${environment}-${project_name}-standalone",
                        "log_stream_name": "{instance_id}/nginx-error"
                    }
                ]
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s

# Create a simple web page
mkdir -p /var/www/html
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Standalone EC2 Instance</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }
        .container { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
        .info { margin: 20px 0; }
        .status { color: #27ae60; font-weight: bold; }
        .meta { background: #ecf0f1; padding: 15px; border-radius: 5px; margin: 15px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="header">🖥️ Standalone EC2 Instance</h1>
        <div class="info">
            <p class="status">✅ Server is running successfully!</p>
            <div class="meta">
                <p><strong>Environment:</strong> ${environment}</p>
                <p><strong>Project:</strong> ${project_name}</p>
                <p><strong>Instance Name:</strong> ${instance_name}</p>
                <p><strong>Instance ID:</strong> <span id="instance-id">Loading...</span></p>
                <p><strong>Private IP:</strong> <span id="private-ip">Loading...</span></p>
                <p><strong>Availability Zone:</strong> <span id="az">Loading...</span></p>
            </div>
        </div>
        <h3>🔧 Installed Software:</h3>
        <ul>
            <li>Ubuntu 22.04 LTS</li>
            <li>Docker & Docker Compose</li>
            <li>Nginx Web Server</li>
            <li>AWS CLI</li>
            <li>CloudWatch Agent</li>
            <li>Development tools (git, vim, htop, etc.)</li>
        </ul>
        <h3>📊 Monitoring:</h3>
        <ul>
            <li>CloudWatch metrics enabled</li>
            <li>System logs forwarded to CloudWatch</li>
            <li>Nginx access/error logs monitored</li>
        </ul>
    </div>
    
    <script>
        // Fetch instance metadata
        Promise.all([
            fetch('http://169.254.169.254/latest/meta-data/instance-id'),
            fetch('http://169.254.169.254/latest/meta-data/local-ipv4'),
            fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone')
        ]).then(responses => 
            Promise.all(responses.map(r => r.text()))
        ).then(([instanceId, privateIp, az]) => {
            document.getElementById('instance-id').textContent = instanceId;
            document.getElementById('private-ip').textContent = privateIp;
            document.getElementById('az').textContent = az;
        }).catch(error => {
            console.log('Could not fetch metadata:', error);
        });
    </script>
</body>
</html>
EOF

# Create health check endpoint
cat > /var/www/html/health << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Health Check</title>
</head>
<body>
    <h1>OK</h1>
    <p>Status: Healthy</p>
    <p>Timestamp: $(date)</p>
    <p>Instance: ${instance_name}</p>
</body>
</html>
EOF

# Configure nginx
systemctl start nginx
systemctl enable nginx

# Create a simple API endpoint
cat > /var/www/html/api.php << 'EOF'
<?php
header('Content-Type: application/json');
echo json_encode([
    'status' => 'healthy',
    'timestamp' => date('c'),
    'environment' => '${environment}',
    'project' => '${project_name}',
    'instance' => '${instance_name}',
    'server' => gethostname()
]);
?>
EOF

# Install PHP for the API endpoint
apt-get install -y php-fpm php-cli
systemctl start php8.1-fpm
systemctl enable php8.1-fpm

# Configure nginx to handle PHP
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.php;

    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Restart nginx
systemctl restart nginx

# Set up log rotation
cat > /etc/logrotate.d/custom-logs << 'EOF'
/var/log/custom/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 root root
}
EOF

# Create custom log directory
mkdir -p /var/log/custom

# Log completion
echo "$(date): Standalone EC2 instance setup completed successfully" >> /var/log/user-data.log
echo "Environment: ${environment}" >> /var/log/user-data.log
echo "Project: ${project_name}" >> /var/log/user-data.log
echo "Instance: ${instance_name}" >> /var/log/user-data.log

# Send completion notification to CloudWatch
aws logs create-log-group --log-group-name "/aws/ec2/${environment}-${project_name}-standalone" --region $(curl -s http://169.254.169.254/latest/meta-data/placement/region) || true