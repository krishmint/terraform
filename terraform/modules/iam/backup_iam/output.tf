# vault access policy
output "vault_access_policy" {
  value = data.aws_iam_policy_document.backup_policy_json.json
}

# custom aws backup policy
output "custom_aws_backup_policy" {
  value = data.aws_iam_policy_document.custom_backup_policy.json
}

# backup iam role arn 
output "backup_iam_role_arn" {
  description = "ARN of the IAM role used by AWS Backup"
  value       = aws_iam_role.backup_role.arn
}

# backup iam role name
output "backup_iam_role_name" {
  description = "Name of the IAM role used by AWS Backup"
  value       = aws_iam_role.backup_role.name
}