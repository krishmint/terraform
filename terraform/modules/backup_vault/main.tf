data "aws_caller_identity" "current" {}

locals {
  name_prefix                = "${var.environment}-${var.project_name}"
  backup_selection_tag_key   = var.backup_tag_key
  backup_selection_tag_value = var.backup_tag_value
}

# Backup Vault
resource "aws_backup_vault" "backup_vault" {
  name = var.vault-name
  tags = var.vault-tags
}

resource "aws_backup_vault_policy" "vault_policy" {
  backup_vault_name = aws_backup_vault.backup_vault.name
  policy            = var.vault_access_policy_json
}

# attached json file into policy
resource "aws_iam_policy" "custom_backup_policy" {
  name        = "CustomAWSBackupExecutionPolicy"
  description = "Custom policy with least privileges for AWS Backup jobs"
  policy      = var.custom_policy_json
}

# add custom backup policy into iam role
resource "aws_iam_role_policy_attachment" "backup_role_attach" {
  role       = var.backup_role_name
  policy_arn = aws_iam_policy.custom_backup_policy.arn
}

# Backup Plan
resource "aws_backup_plan" "asg_backup_plan" {
  name = var.backup-plan-name

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.backup_vault.name
    schedule          = "cron(0 5 * * ? *)"

    lifecycle {
      delete_after = 7
    }
  }
}

# Backup Selection (Tag Based)
resource "aws_backup_selection" "asg_backup_selection" {
  name         = "${var.environment}-${var.project_name}-backup-selection"
  iam_role_arn = var.backup_role_arn
  plan_id      = aws_backup_plan.asg_backup_plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = local.backup_selection_tag_key
    value = local.backup_selection_tag_value
  }
}


