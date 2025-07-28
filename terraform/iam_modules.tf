# AWS Backup IAM Module
module "backup_iam" {
  source           = "./modules/iam/backup_iam"
  account_id       = data.aws_caller_identity.current.account_id
  backup_role_name = var.aws_backup_role_name
  backup_vault_arn = module.backup.backup_vault_arn
}

# EC2 IAM Module
module "ec2_iam" {
  source = "./modules/iam/ec2_iam"

  environment  = var.environment
  project_name = var.project_name

  tags = local.common_tags
}

#  Cloudwatch IAM Module
module "cloudwatch_iam" {
  source        = "./modules/iam/cloudwatch_iam"
  environment   = var.environment
  project_name  = var.project_name
  tags          = local.common_tags
  ec2_role_name = module.ec2_iam.instance_role_name
}

#  Users IAM Module
module "users_iam" {
  source          = "./modules/iam/users_iam"
  environment     = var.environment
  project_name    = var.project_name
  tags            = local.common_tags
  developer_users = var.developer_users
  devops_users    = var.devops_users
  admin_users     = var.admin_users
}

#  Users IAM Module
module "users_policies" {
  source       = "./modules/iam/users_policies"
  environment  = var.environment
  project_name = var.project_name
  tags         = local.common_tags

  create_access_keys = var.create_access_keys

  # Pass user names (list of strings)
  developer_users = module.users_iam.developer_users
  devops_users    = module.users_iam.devops_users
  admin_users     = module.users_iam.admin_users

  # Pass user resources (object type)
  developer_users_resource = module.users_iam.developer_users_resource
  devops_users_resource    = module.users_iam.devops_users_resource
  admin_users_resource     = module.users_iam.admin_users_resource

  # Pass access keys outputs from users_iam module
  developer_keys = module.users_iam.developer_keys
  devops_keys    = module.users_iam.devops_keys
  admin_keys     = module.users_iam.admin_keys
}