# =============================================================================
# GLOBAL VARIABLES
# =============================================================================

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}



# =============================================================================
# TAGGING
# =============================================================================

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# =============================================================================
# VPC CONFIGURATION
# =============================================================================

variable "vpc_config" {
  description = "VPC configuration"
  type = object({
    cidr_block           = string
    enable_dns_hostnames = bool
    enable_dns_support   = bool
    enable_nat_gateway   = bool
    single_nat_gateway   = bool
  })
}

variable "subnet_config" {
  description = "Subnet configuration"
  type = object({
    public_subnets  = list(string)
    private_subnets = list(string)
    database_subnets = list(string)
  })
}

# =============================================================================
# KEY PAIR CONFIGURATION
# =============================================================================

variable "key_pair_config" {
  description = "EC2 Key Pair configuration"
  type = object({
    create_key_pair = bool
    key_name        = string
    s3_bucket_name  = string
    s3_key_prefix   = string
  })
}

# =============================================================================
# EC2 CONFIGURATION  ## NOT required
  
  ##"ec2_config" varibale is not required as we are passing values directly in main.tf 
 ## we are passing values 2 times as in ec2 baby module we are using for each 
# =============================================================================

# variable "ec2_config" {
#   description = "EC2 instance configuration"
#   type = object({
#     instance_type          = string
#     ami_id                 = string
#     root_volume_size       = number
#     root_volume_type       = string
#     root_volume_encrypted  = bool
#     enable_detailed_monitoring = bool
#   })
# }

# =============================================================================
# AUTO SCALING CONFIGURATION
# =============================================================================

variable "autoscaling_config" {
  description = "Auto Scaling configuration"
  type = object({
    min_size                = number
    max_size                = number
    desired_capacity        = number
    health_check_type       = string
    health_check_grace_period = number
    default_cooldown        = number
    instance_warmup         = number
    enabled_metrics         = list(string)
  })
}

# =============================================================================
# LOAD BALANCER CONFIGURATION
# =============================================================================

variable "load_balancer_config" {
  description = "Load balancer configuration"
  type = object({
    type                     = string
    scheme                   = string
    enable_deletion_protection = bool
    idle_timeout             = number
    enable_http2             = bool
    enable_cross_zone_load_balancing = bool
  })
}

# =============================================================================
# RDS CONFIGURATION
# =============================================================================

variable "rds_config" {
  description = "RDS MySQL configuration"
  type = object({
    engine_version           = string
    instance_class          = string
    allocated_storage       = number
    max_allocated_storage   = number
    storage_type            = string
    storage_encrypted       = bool
    multi_az                = bool
    publicly_accessible     = bool
    backup_retention_period = number
    backup_window          = string
    maintenance_window     = string
    deletion_protection    = bool
    skip_final_snapshot    = bool
    final_snapshot_identifier = string
  })
}

variable "rds_database_config" {
  description = "RDS database configuration"
  type = object({
    database_name = string
    username      = string
    port          = number
  })
}

# =============================================================================
# SECURITY GROUP RULES
# =============================================================================

variable "security_group_rules" {
  description = "Security group rules configuration"
  type = map(object({
    description = string
    ingress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      description = string
    }))
    egress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      description = string
    }))
  }))
}

# =============================================================================
# WAF CONFIGURATION
# =============================================================================

variable "waf_config" {
  description = "WAF configuration"
  type = object({
    enabled                = bool
    scope                  = string
    cloudwatch_metrics_enabled = bool
    sampled_requests_enabled   = bool
  })
}

# =============================================================================
# BACKUP CONFIGURATION
# =============================================================================

variable "backup_config" {
  description = "AWS Backup configuration"
  type = object({
    backup_vault_name = string
    backup_plan_name  = string
    rules = list(object({
      name                     = string
      schedule                 = string
      start_window             = number
      completion_window        = number
      delete_after             = number
      cold_storage_after       = number
      recovery_point_tags      = map(string)
    }))
  })
}

# =============================================================================
# CLOUDTRAIL CONFIGURATION
# =============================================================================

variable "cloudtrail_config" {
  description = "CloudTrail configuration"
  type = object({
    trail_name                        = string
    s3_bucket_name                   = string
    include_global_service_events    = bool
    is_multi_region_trail           = bool
    enable_logging                  = bool
    enable_log_file_validation      = bool
    event_selector_read_write_type  = string
    event_selector_include_management_events = bool
  })
}

# =============================================================================
# FEATURE FLAGS
# =============================================================================

variable "enable_features" {
  description = "Feature flags to enable/disable components"
  type = object({
    vpc                = bool
    security_groups    = bool
    ec2                = bool
    autoscaling        = bool
    load_balancer      = bool
    rds                = bool
    backup             = bool
    cloudtrail         = bool
    waf                = bool
    key_pair           = bool
  })
  default = {
    vpc                = true
    security_groups    = false
    ec2                = true
    autoscaling        = true
    load_balancer      = true
    rds                = true
    backup             = true
    cloudtrail         = true
    waf                = true
    key_pair           = true
  }
}