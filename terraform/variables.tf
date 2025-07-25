# Root module variables
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (e.g., staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "webapp"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

# Auto Scaling Configuration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 2
}

# WAF Configuration
variable "enable_waf" {
  description = "Enable AWS WAF"
  type        = bool
  default     = false
}
# Load Balancer Configuration
variable "health_check_path" {
  description = "Health check path for the load balancer target group"
  type        = string
  default     = "/health"
}

variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener (optional)"
  type        = string
  default     = ""
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the load balancer"
  type        = bool
  default     = false
}

# IAM Users Configuration
variable "developer_users" {
  description = "List of developer usernames"
  type        = list(string)
  default     = ["developer1", "developer2", "developer3"]
}

variable "devops_users" {
  description = "List of DevOps usernames"
  type        = list(string)
  default     = ["devops1"]
}

variable "admin_users" {
  description = "List of admin usernames"
  type        = list(string)
  default     = ["admin1"]
}

variable "create_access_keys" {
  description = "Create access keys for users (for programmatic access)"
  type        = bool
  default     = false
}

# CloudTrail Configuration
variable "cloudtrail_log_retention_days" {
  description = "Number of days to retain CloudTrail logs in CloudWatch"
  type        = number
  default     = 90
}

variable "force_destroy_cloudtrail_bucket" {
  description = "Force destroy CloudTrail S3 bucket even if not empty"
  type        = bool
  default     = false
}

variable "enable_session_tracking" {
  description = "Enable DynamoDB table and Lambda for session tracking"
  type        = bool
  default     = true
}