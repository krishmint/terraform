# Environment-specific configuration
aws_region   = "us-west-2"
environment  = "staging"
project_name = "webapp"

# VPC Configuration
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets    = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
enable_nat_gateway = true

# Auto Scaling Configuration
instance_type        = "t3.micro"
asg_min_size        = 1
asg_max_size        = 5
asg_desired_capacity = 2

# WAF Configuration
enable_waf = false
# Load Balancer Configuration
health_check_path = "/health"
ssl_certificate_arn = ""
enable_deletion_protection = false

# IAM Users Configuration
developer_users = ["developer1", "developer2", "developer3"]
devops_users    = ["devops1"]
admin_users     = ["admin1"]
create_access_keys = false  # Set to true if you need programmatic access

# CloudTrail Configuration
cloudtrail_log_retention_days     = 90
force_destroy_cloudtrail_bucket   = false
enable_session_tracking           = true