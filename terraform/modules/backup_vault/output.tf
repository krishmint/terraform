output "backup_vault_name" {
  description = "The name of the backup vault"
  value       = aws_backup_vault.backup_vault.name
}

output "backup_vault_arn" {
  description = "The ARN of the backup vault"
  value       = aws_backup_vault.backup_vault.arn
}

output "custom_backup_policy_arn" {
  description = "ARN of the custom IAM policy for AWS Backup"
  value       = aws_iam_policy.custom_backup_policy.arn
}

output "custom_backup_policy_name" {
  description = "Name of the custom IAM policy for AWS Backup"
  value       = aws_iam_policy.custom_backup_policy.name
}

output "backup_plan_id" {
  description = "ID of the AWS Backup Plan"
  value       = aws_backup_plan.asg_backup_plan.id
}

output "backup_plan_name" {
  description = "Name of the AWS Backup Plan"
  value       = aws_backup_plan.asg_backup_plan.name
}

output "backup_selection_id" {
  description = "ID of the backup selection"
  value       = aws_backup_selection.asg_backup_selection.id
}

# Useful locals
output "backup_selection_tag_key" {
  description = "Backup selection tag key used to match resources"
  value       = local.backup_selection_tag_key
}

output "backup_selection_tag_value" {
  description = "Backup selection tag value used to match resources"
  value       = local.backup_selection_tag_value
}