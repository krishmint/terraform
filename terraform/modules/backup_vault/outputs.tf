output "vault_id" {
  description = "ID of the backup vault"
  value       = aws_backup_vault.main.id
}

output "vault_arn" {
  description = "ARN of the backup vault"
  value       = aws_backup_vault.main.arn
}

output "vault_name" {
  description = "Name of the backup vault"
  value       = aws_backup_vault.main.name
}

output "plan_id" {
  description = "ID of the backup plan"
  value       = aws_backup_plan.main.id
}

output "plan_arn" {
  description = "ARN of the backup plan"
  value       = aws_backup_plan.main.arn
}

output "plan_name" {
  description = "Name of the backup plan"
  value       = aws_backup_plan.main.name
}

output "kms_key_id" {
  description = "ID of the KMS key used for encryption"
  value       = aws_kms_key.backup.key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = aws_kms_key.backup.arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  value       = var.enable_notifications ? aws_sns_topic.backup_notifications[0].arn : null
}