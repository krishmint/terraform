# return users info
output "developer_users_resource" {
  value = aws_iam_user.developers
}

output "devops_users_resource" {
  value = aws_iam_user.devops
}

output "admin_users_resource" {
  value = aws_iam_user.admin
}

output "developer_users" {
  value = aws_iam_user.developers[*].name
}

output "devops_users" {
  value = aws_iam_user.devops[*].name
}

output "admin_users" {
  value = aws_iam_user.admin[*].name
}

output "developer_keys" {
  value     = aws_iam_access_key.developer_keys
  sensitive = true
}

output "devops_keys" {
  value     = aws_iam_access_key.devops_keys
  sensitive = true
}

output "admin_keys" {
  value     = aws_iam_access_key.admin_keys
  sensitive = true
}