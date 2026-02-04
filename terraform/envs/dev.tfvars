environment    = "dev"
project_name   = "rocketscience"
aws_region     = "ap-south-1"
availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]



# Default Tags
default_tags = {
  Environment = "dev"
  Project     = "rocketscience"
  ManagedBy   = "Terraform"
}

additional_tags = {
  Backup = "daily"
}

# VPC Configuration
vpc_config = {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = false
  single_nat_gateway   = false
}

subnet_config = {
  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets  = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  database_subnets = ["10.0.100.0/24", "10.0.200.0/24", "10.0.201.0/24"]
}

# Key Pair Configuration
key_pair_config = {
  create_key_pair = false
  key_name        = "myapp-dev-key"
  s3_bucket_name  = "myapp-dev-ssh-keys"
  s3_key_prefix   = "ssh-keys"
}

# # EC2 Configuration
# ec2_config = {
#   instance_type               = "t3.micro"
#   ami_id                     = "ami-05f991c49d264708f" # Ubuntu 24.04
#   root_volume_size           = 8
#   root_volume_type           = "gp3"
#   root_volume_encrypted      = true
#   enable_detailed_monitoring = false
# }

# Auto Scaling Configuration
autoscaling_config = {
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  health_check_type         = "ELB"
  health_check_grace_period = 300
  default_cooldown          = 300
  instance_warmup           = 0
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
}

# Load Balancer Configuration
load_balancer_config = {
  type                            = "application"
  scheme                          = "internet-facing"
  enable_deletion_protection      = false
  idle_timeout                    = 60
  enable_http2                    = true
  enable_cross_zone_load_balancing = true
}

# RDS Configuration
rds_config = {
  engine_version           = "8.0.35"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type            = "gp3"
  storage_encrypted       = true
  multi_az                = false
  publicly_accessible     = false
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  deletion_protection    = false
  skip_final_snapshot    = true
  final_snapshot_identifier = null
}

rds_database_config = {
  database_name = "myappdb"
  username      = "admin"
  port          = 3306
}

# Security Group Rules
security_group_rules = {
  web = {
    description = "Web server security group"
    ingress_rules = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP from anywhere"
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTPS from anywhere"
      }
    ]
    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "All outbound traffic"
      }
    ]
  }
  ec2 = {
    description = "EC2 instances security group"
    ingress_rules = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "SSH from VPC"
      },
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
        description = "HTTP from VPC"
      }
    ]
    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "All outbound traffic"
      }
    ]
  }
  alb = {
    description = "Application Load Balancer security group"
    ingress_rules = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP from anywhere"
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTPS from anywhere"
      }
    ]
    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "All outbound traffic"
      }
    ]
  }
  rds = {
    description = "RDS database security group"
    ingress_rules = [
      {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
        description = "MySQL from VPC"
      }
    ]
    egress_rules = []
  }
}

# WAF Configuration
waf_config = {
  enabled                    = true
  scope                      = "REGIONAL"
  cloudwatch_metrics_enabled = true
  sampled_requests_enabled   = true
}

# Backup Configuration
backup_config = {
  backup_vault_name = "myapp-dev-backup-vault"
  backup_plan_name  = "myapp-dev-backup-plan"
  rules = [
    {
      name                 = "daily_backup"
      schedule             = "cron(0 5 ? * * *)"
      start_window         = 60
      completion_window    = 300
      delete_after         = 30
      cold_storage_after   = null
      recovery_point_tags  = {
        BackupType = "automated"
      }
    }
  ]
}

# CloudTrail Configuration
cloudtrail_config = {
  trail_name                                = "myapp-dev-cloudtrail"
  s3_bucket_name                           = "myapp-dev-cloudtrail-logs"
  include_global_service_events            = true
  is_multi_region_trail                   = true
  enable_logging                          = true
  enable_log_file_validation              = true
  event_selector_read_write_type          = "All"
  event_selector_include_management_events = true
}

# Feature Flags
enable_features = {
  vpc           = true
  ec2           = false
  autoscaling   = false
  load_balancer = false
  rds           = false
  backup        = false
  cloudtrail    = false
  waf           = false
  key_pair      = false
}
