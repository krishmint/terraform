# Environment-specific configuration
aws_region   = "us-east-1"
environment  = "staging"
project_name = "webapp"

# VPC Configuration
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets    = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
enable_nat_gateway = true

# Auto Scaling Configuration
instance_type        = "t3.micro"
asg_min_size         = 1
asg_max_size         = 5
asg_desired_capacity = 2

# WAF Configuration
enable_waf = false
# Load Balancer Configuration
health_check_path          = "/health"
ssl_certificate_arn        = ""
enable_deletion_protection = false

# IAM Users Configuration
developer_users    = ["developer1", "developer2", "developer3"]
devops_users       = ["devops1"]
admin_users        = ["admin1"]
create_access_keys = false # Set to true if you need programmatic access

# CloudTrail Configuration
cloudtrail_log_retention_days   = 90
force_destroy_cloudtrail_bucket = false
enable_session_tracking         = true

# backup key and value
backup_key           = "backup"
backup_value         = "true"
aws_backup_role_name = "backup_role@stage"
vault_name           = "steging_vault"
vault_tags = {
  "Environment" = "Staging"
}
backup_plan_name = "staging_plan"