# KMS Key for Backup Vault encryption
resource "aws_kms_key" "backup" {
  description             = "KMS key for ${var.project_name} ${var.environment} backup vault"
  deletion_window_in_days = 7

  lifecycle {
    prevent_destroy = false
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-backup-key"
    }
  )
}

resource "aws_kms_alias" "backup" {
  name          = "alias/${var.project_name}-${var.environment}-backup"
  target_key_id = aws_kms_key.backup.key_id
}

# Backup Vault
resource "aws_backup_vault" "main" {
  name        = var.vault_name
  kms_key_arn = aws_kms_key.backup.arn

  lifecycle {
    prevent_destroy = false
  }

  tags = merge(
    var.tags,
    {
      Name = var.vault_name
    }
  )
}

# Backup Plan
resource "aws_backup_plan" "main" {
  name = var.plan_name

  dynamic "rule" {
    for_each = var.backup_rules
    content {
      rule_name         = rule.value.name
      target_vault_name = aws_backup_vault.main.name
      schedule          = rule.value.schedule
      start_window      = rule.value.start_window
      completion_window = rule.value.completion_window

      recovery_point_tags = rule.value.recovery_point_tags

      lifecycle {
        delete_after       = rule.value.delete_after
        cold_storage_after = rule.value.cold_storage_after
      }

      copy_action {
        destination_vault_arn = aws_backup_vault.main.arn

        lifecycle {
          delete_after       = rule.value.delete_after
          cold_storage_after = rule.value.cold_storage_after
        }
      }
    }
  }

  lifecycle {
    prevent_destroy = false
  }

  tags = merge(
    var.tags,
    {
      Name = var.plan_name
    }
  )
}

# Backup Selection
resource "aws_backup_selection" "main" {
  iam_role_arn = var.iam_role_arn
  name         = "${var.plan_name}-selection"
  plan_id      = aws_backup_plan.main.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Environment"
    value = var.environment
  }

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "true"
  }

  # Include all supported resource types
  resources = [
    "arn:aws:ec2:*:*:volume/*",
    "arn:aws:ec2:*:*:instance/*",
    "arn:aws:rds:*:*:db:*",
    "arn:aws:rds:*:*:cluster:*",
#    "arn:aws:efs:*:*:file-system/*",
    "arn:aws:fsx:*:*:file-system/*",
    "arn:aws:dynamodb:*:*:table/*"
  ]

  lifecycle {
    prevent_destroy = false
  }
}

# Backup Vault Policy
resource "aws_backup_vault_policy" "main" {
  backup_vault_name = aws_backup_vault.main.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAccessToBackupVault"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "backup:DescribeBackupVault",
          "backup:DeleteBackupVault",
          "backup:PutBackupVaultAccessPolicy",
          "backup:DeleteBackupVaultAccessPolicy",
          "backup:GetBackupVaultAccessPolicy"
        ]
        Resource = "*"
      }
    ]
  })
}

# Data source for current AWS account ID
data "aws_caller_identity" "current" {}

# CloudWatch Log Group for backup notifications
resource "aws_cloudwatch_log_group" "backup_notifications" {
  name              = "/aws/backup/${var.vault_name}"
  retention_in_days = 30

  tags = var.tags
}

# SNS Topic for backup notifications (optional)
resource "aws_sns_topic" "backup_notifications" {
  count = var.enable_notifications ? 1 : 0
  name  = "${var.project_name}-${var.environment}-backup-notifications"

  tags = var.tags
}

# Backup Vault Notifications (optional)
resource "aws_backup_vault_notifications" "main" {
  count               = var.enable_notifications ? 1 : 0
  backup_vault_name   = aws_backup_vault.main.name
  sns_topic_arn       = aws_sns_topic.backup_notifications[0].arn
  backup_vault_events = [
    "BACKUP_JOB_STARTED",
    "BACKUP_JOB_COMPLETED",
    "BACKUP_JOB_FAILED",
    "RESTORE_JOB_STARTED",
    "RESTORE_JOB_COMPLETED",
    "RESTORE_JOB_FAILED"
  ]
}
