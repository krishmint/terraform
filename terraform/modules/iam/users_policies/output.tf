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
    for i, user in var.developer_users_resource :
    user.name => {
      access_key_id = var.developer_keys[i].id
      secret_access_key = var.developer_keys[i].secret
    }
  } : {}
  sensitive = true
}

output "devops_access_keys" {
  description = "Access keys for DevOps users"
  value = var.create_access_keys ? {
    for i, user in var.devops_users_resource :
    user.name => {
      access_key_id = var.devops_keys[i].id
      secret_access_key = var.devops_keys[i].secret
    }
  } : {}
  sensitive = true
}

output "admin_access_keys" {
  description = "Access keys for admin users"
  value = var.create_access_keys ? {
    for i, user in var.admin_users_resource :
    user.name => {
      access_key_id = var.admin_keys[i].id
      secret_access_key = var.admin_keys[i].secret
    }
  } : {}
  sensitive = true
}

