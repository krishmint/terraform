# Root module outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "web_security_group_id" {
  description = "ID of the web security group"
  value       = module.security_group.web_security_group_id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.autoscaling.autoscaling_group_name
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.autoscaling.autoscaling_group_arn
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.load_balancer.load_balancer_dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = module.load_balancer.load_balancer_zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.load_balancer.target_group_arn
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL (if enabled)"
  value       = var.enable_waf ? module.waf[0].web_acl_arn : null
}

output "subnet_id" {
  description = "ID of the first public subnet"
  value       = module.vpc.public_subnet_ids[0]
}


# CloudTrail Outputs
#output "cloudtrail_arn" {
#  description = "ARN of the CloudTrail"
#  value       = module.cloudtrail.cloudtrail_arn
#}

#output "cloudtrail_s3_bucket" {
#  description = "S3 bucket name for CloudTrail logs"
#  value       = module.cloudtrail.s3_bucket_name
#}

#output "cloudtrail_log_group" {
#  description = "CloudWatch log group for CloudTrail"
#  value       = module.cloudtrail.cloudwatch_log_group_name
#}


#output "session_tracking_table" {
#  description = "DynamoDB table for session tracking"
#  value       = module.cloudtrail.dynamodb_table_name
#}

output "instance_profile_name" {
  value = module.ec2_iam.instance_profile_name
}

output "instance_role_arn" {
  value = module.ec2_iam.instance_role_arn
}

# IAM Users Outputs
output "developer_users" {
  value = module.users_iam.developer_users
}

output "devops_users" {
  value = module.users_iam.devops_users
}

output "admin_users" {
  value = module.users_iam.admin_users
}
