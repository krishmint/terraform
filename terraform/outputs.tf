# =============================================================================
# OUTPUTS
# =============================================================================

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = var.enable_features.vpc ? module.vpc[0].vpc_id : null
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = var.enable_features.vpc ? module.vpc[0].vpc_cidr_block : null
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = var.enable_features.vpc ? module.vpc[0].public_subnet_ids : []
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = var.enable_features.vpc ? module.vpc[0].private_subnet_ids : []
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = var.enable_features.vpc ? module.vpc[0].database_subnet_ids : []
}

# EC2 Outputs
output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = var.enable_features.ec2 ? module.ec2[0].instance_id : null
}

output "ec2_instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = var.enable_features.ec2 ? module.ec2[0].public_ip : null
}

output "ec2_instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = var.enable_features.ec2 ? module.ec2[0].private_ip : null
}

# Auto Scaling Outputs
output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = var.enable_features.autoscaling ? module.autoscaling[0].autoscaling_group_arn : null
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = var.enable_features.autoscaling ? module.autoscaling[0].autoscaling_group_name : null
}

# Load Balancer Outputs
output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = var.enable_features.load_balancer ? module.load_balancer[0].load_balancer_arn : null
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = var.enable_features.load_balancer ? module.load_balancer[0].dns_name : null
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = var.enable_features.load_balancer ? module.load_balancer[0].zone_id : null
}

# RDS Outputs
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = var.enable_features.rds ? module.rds[0].endpoint : null
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = var.enable_features.rds ? module.rds[0].port : null
}

output "rds_database_name" {
  description = "RDS database name"
  value       = var.enable_features.rds ? module.rds[0].database_name : null
}

# Key Pair Outputs
output "key_pair_name" {
  description = "Name of the key pair"
  value       = var.enable_features.key_pair ? module.key_pair[0].key_name : null
}

output "private_key_s3_location" {
  description = "S3 location of the private key"
  value       = var.enable_features.key_pair ? module.key_pair[0].private_key_s3_location : null
  sensitive   = true
}

# Security Group Outputs
output "security_group_ids" {
  description = "Map of security group IDs"
  value       = var.enable_features.vpc ? module.security_groups[0].security_group_ids : {}
}

# IAM Outputs
output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = module.iam.ec2_instance_profile_name
}

output "backup_role_arn" {
  description = "ARN of the backup role"
  value       = module.iam.backup_role_arn
}

# Backup Outputs
output "backup_vault_arn" {
  description = "ARN of the backup vault"
  value       = var.enable_features.backup ? module.backup[0].vault_arn : null
}

output "backup_plan_arn" {
  description = "ARN of the backup plan"
  value       = var.enable_features.backup ? module.backup[0].plan_arn : null
}

# WAF Outputs
output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = var.enable_features.waf && var.enable_features.load_balancer ? module.waf[0].web_acl_arn : null
}

# CloudTrail Outputs
#output "cloudtrail_arn" {
#  description = "ARN of the CloudTrail"
#  value       = var.enable_features.cloudtrail ? module.cloudtrail[0].trail_arn : null
#}

#output "cloudtrail_s3_bucket" {
#  description = "S3 bucket for CloudTrail logs"
#  value       = var.enable_features.cloudtrail ? module.cloudtrail[0].s3_bucket_name : null
#}
