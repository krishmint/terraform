# AWS Backup module
module "backup" {
  source                   = "./modules/backup_vault"
  vault-name               = var.vault_name
  vault-tags               = var.vault_tags
  backup-plan-name         = var.backup_plan_name
  backup_tag_key           = var.backup_key
  backup_tag_value         = var.backup_value
  environment              = var.environment
  project_name             = var.project_name
  custom_policy_json       = module.backup_iam.custom_aws_backup_policy
  vault_access_policy_json = module.backup_iam.vault_access_policy
  backup_role_arn          = module.backup_iam.backup_iam_role_arn
  backup_role_name         = module.backup_iam.backup_iam_role_name
}