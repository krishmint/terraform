# Root module - main.tf
terraform {
  required_version = ">= 1.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Local values for consistent naming
locals {
  common_tags = {
    Environment  = var.environment
    Project      = var.project_name
    ManagedBy    = "Terraform"
    Backup_key   = var.backup_key
    Backup_value = var.backup_value
  }

  name_prefix = "${var.environment}-${var.project_name}"
}

data "aws_caller_identity" "current" {}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  environment        = var.environment
  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  enable_nat_gateway = var.enable_nat_gateway

  tags = local.common_tags
}

# Security Group Module
module "security_group" {
  source = "./modules/security_group"

  environment  = var.environment
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id

  tags = local.common_tags
}

# IAM Module
# module "iam" {
#   source = "./modules/iam"

#   environment  = var.environment
#   project_name = var.project_name

#   tags = local.common_tags
# }

# Auto Scaling Group Module
module "autoscaling" {
  source = "./modules/autoscaling"

  environment           = var.environment
  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  security_group_ids    = [module.security_group.web_security_group_id]
  instance_profile_name = module.ec2_iam.instance_profile_name #.iam.instance_profile_name
  target_group_arns     = [module.load_balancer.target_group_arn]

  instance_type    = var.instance_type
  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  tags = local.common_tags
}

# Load Balancer Module
module "load_balancer" {
  source = "./modules/load_balancer"

  environment        = var.environment
  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  security_group_ids = [module.security_group.alb_security_group_id]

  health_check_path          = var.health_check_path
  ssl_certificate_arn        = var.ssl_certificate_arn
  enable_deletion_protection = var.enable_deletion_protection

  tags = local.common_tags
}

# WAF Module (Optional)
module "waf" {
  source = "./modules/waf"

  count = var.enable_waf ? 1 : 0

  environment  = var.environment
  project_name = var.project_name

  tags = local.common_tags
}

# CloudTrail Module
#module "cloudtrail" {
#  source = "./modules/cloudtrail"

#  environment             = var.environment
#  project_name            = var.project_name
#  log_retention_days      = var.cloudtrail_log_retention_days
#  force_destroy_bucket    = var.force_destroy_cloudtrail_bucket
#  enable_session_tracking = var.enable_session_tracking

#  tags = local.common_tags
#}

# EC2 Instance
module "EC2" {
  source = "./modules/ec2"

  environment           = var.environment
  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  subnet_id             = module.vpc.public_subnet_ids[0]
  instance_profile_name = module.ec2_iam.instance_profile_name

  tags = local.common_tags
}

