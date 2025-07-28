data "aws_caller_identity" "current" {}

# Vault Access Policy
data "aws_iam_policy_document" "backup_policy_json" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }

    actions = [
      "backup:DescribeBackupVault",
      "backup:DeleteBackupVault",
      "backup:PutBackupVaultAccessPolicy",
      "backup:DeleteBackupVaultAccessPolicy",
      "backup:GetBackupVaultAccessPolicy",
      "backup:StartBackupJob",
      "backup:GetBackupVaultNotifications",
      "backup:PutBackupVaultNotifications",
    ]

    resources = [var.backup_vault_arn]
  }
}

# IAM Role for AWS Backup
resource "aws_iam_role" "backup_role" {
  name = var.backup_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "backup.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# create custom aws backup policy
data "aws_iam_policy_document" "custom_backup_policy" {
  statement {
    sid    = "EC2Permissions"
    effect = "Allow"
    actions = [
      "ec2:CreateSnapshot",
      "ec2:CreateSnapshots",
      "ec2:DeleteSnapshot",
      "ec2:DescribeInstances",
      "ec2:DescribeVolumes",
      "ec2:DescribeSnapshots",
      "ec2:CreateTags",
      "ec2:DeleteTags"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "BackupVaultAccess"
    effect = "Allow"
    actions = [
      "backup:CopyIntoBackupVault",
      "backup:DescribeBackupVault",
      "backup:DescribeProtectedResource",
      "backup:ListRecoveryPointsByBackupVault",
      "backup:ListTags",
      "backup:PutBackupVaultNotifications",
      "backup:GetBackupVaultNotifications"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Logging"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  # Add this get resource permission
  statement {
    sid    = "TagBasedSelection"
    effect = "Allow"
    actions = [
      "tag:GetResources"
    ]
    resources = ["*"]
  }
}
