# Environment-specific configuration
aws_region   = "us-east-1"
environment  = "dev"
project_name = "terraform"

# Virtual Network Configuration
vpc_cidr           = "172.16.0.0/16"
availability_zones = ["us-east-2a", "us-east-2b"]
public_subnets     = ["172.16.1.0/24", "172.16.2.0/24"]
private_subnets    = ["172.16.11.0/24", "172.16.12.0/24"]
enable_nat_gateway = false


# Auto Scaling Configuration
instance_type        = "t3.micro"
asg_min_size         = 1
asg_max_size         = 5
asg_desired_capacity = 1

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
aws_backup_role_name = "backup_role@prod"
vault_name           = "prod_vault"
vault_tags = {
  "Environment" = "prod"
}
backup_plan_name = "prod_plan"
