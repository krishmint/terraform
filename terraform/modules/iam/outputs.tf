# IAM Module Outputs
output "instance_role_name" {
  description = "Name of the IAM instance role"
  value       = aws_iam_role.ec2_role.name
}

output "instance_role_arn" {
  description = "ARN of the IAM instance role"
  value       = aws_iam_role.ec2_role.arn
}

output "instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "instance_profile_arn" {
  description = "ARN of the IAM instance profile"
  value       = aws_iam_instance_profile.ec2_profile.arn
}

output "cloudwatch_logs_policy_arn" {
  description = "ARN of the CloudWatch logs policy"
  value       = aws_iam_policy.cloudwatch_logs.arn
}

output "developer_users" {
  description = "List of developer user names"
  value       = aws_iam_user.developers[*].name
}

output "devops_users" {
  description = "List of DevOps user names"
  value       = aws_iam_user.devops[*].name
}

output "admin_users" {
  description = "List of admin user names"
  value       = aws_iam_user.admin[*].name
}

output "developer_policy_arn" {
  description = "ARN of the developer policy"
  value       = aws_iam_policy.developer_policy.arn
}

output "devops_policy_arn" {
  description = "ARN of the DevOps policy"
  value       = aws_iam_policy.devops_policy.arn
}

# Access keys (sensitive)
output "developer_access_keys" {
  description = "Access keys for developer users"
  value = var.create_access_keys ? {
    for i, user in aws_iam_user.developers :
    user.name => {
      access_key_id = aws_iam_access_key.developer_keys[i].id
      secret_access_key = aws_iam_access_key.developer_keys[i].secret
    }
  } : {}
  sensitive = true
}

output "devops_access_keys" {
  description = "Access keys for DevOps users"
  value = var.create_access_keys ? {
    for i, user in aws_iam_user.devops :
    user.name => {
      access_key_id = aws_iam_access_key.devops_keys[i].id
      secret_access_key = aws_iam_access_key.devops_keys[i].secret
    }
  } : {}
  sensitive = true
}

output "admin_access_keys" {
  description = "Access keys for admin users"
  value = var.create_access_keys ? {
    for i, user in aws_iam_user.admin :
    user.name => {
      access_key_id = aws_iam_access_key.admin_keys[i].id
      secret_access_key = aws_iam_access_key.admin_keys[i].secret
    }
  } : {}
  sensitive = true
}