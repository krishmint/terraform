
locals {
  common_tags = merge(
    var.default_tags,
    var.additional_tags,
    {
      Region      = var.aws_region
    }
  )

  name_prefix = "${var.project_name}-${var.environment}"
}


data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
  tags         = local.common_tags
}


module "key_pair" {
  count  = var.enable_features.key_pair ? 1 : 0
  source = "./modules/key_pair"

  key_name       = var.key_pair_config.key_name
  s3_bucket_name = var.key_pair_config.s3_bucket_name
  s3_key_prefix  = var.key_pair_config.s3_key_prefix
  project_name   = var.project_name
  environment    = var.environment
  tags           = local.common_tags
}


module "vpc" {
  count  = var.enable_features.vpc ? 1 : 0
  source = "./modules/vpc"

  name_prefix             = local.name_prefix
  vpc_cidr                = var.vpc_config.cidr_block
  availability_zones      = var.availability_zones
  public_subnet_cidrs     = var.subnet_config.public_subnets
  private_subnet_cidrs    = var.subnet_config.private_subnets
  database_subnet_cidrs   = var.subnet_config.database_subnets
  enable_dns_hostnames    = var.vpc_config.enable_dns_hostnames
  enable_dns_support      = var.vpc_config.enable_dns_support
  enable_nat_gateway      = var.vpc_config.enable_nat_gateway
  single_nat_gateway      = var.vpc_config.single_nat_gateway
  tags                    = local.common_tags
}


module "security_groups" {
  count  = var.enable_features.vpc ? 1 : 0
  source = "./modules/security_group"

  name_prefix = local.name_prefix
  vpc_id      = module.vpc[0].vpc_id
  rules       = var.security_group_rules
  tags        = local.common_tags
}


module "ec2" {
  count  = var.enable_features.ec2 ? 1 : 0
  source = "./modules/ec2"

  
  ec2_configs = {
    event-app = {
      name_prefix                 = "app1"
      ami_id                      = "ami-05f991c49d264708f"
      instance_type               = "t2.micro"
      key_name                    = var.enable_features.key_pair ? module.key_pair[0].key_name : null
      subnet_id                   = var.enable_features.vpc ? module.vpc[0].public_subnet_ids[0] : null
      vpc_security_group_ids      = var.enable_features.vpc ? [module.security_groups[0].security_group_ids["ec2"]] : []
      iam_instance_profile        = module.iam.ec2_instance_profile_name
      associate_public_ip_address = true
      root_volume_size            = 8
      root_volume_type            = "gp3"
      root_volume_encrypted       = true
      enable_detailed_monitoring  = false
    },

    ep-api = {
      name_prefix                 = "app1"
      ami_id                      = "ami-05f991c49d264708f"
      instance_type               = "t2.micro"
      key_name                    = var.enable_features.key_pair ? module.key_pair[0].key_name : null
      subnet_id                   = var.enable_features.vpc ? module.vpc[0].public_subnet_ids[0] : null
      vpc_security_group_ids      = var.enable_features.vpc ? [module.security_groups[0].security_group_ids["ec2"]] : []
      iam_instance_profile        = module.iam.ec2_instance_profile_name
      associate_public_ip_address = true
      root_volume_size            = 8
      root_volume_type            = "gp3"
      root_volume_encrypted       = true
      enable_detailed_monitoring  = false
    }
  }

  tags                     = local.common_tags

  depends_on = [module.vpc, module.security_groups, module.iam]
}


module "autoscaling" {
  count  = var.enable_features.autoscaling ? 1 : 0
  source = "./modules/autoscaling"

  name_prefix                = local.name_prefix
  ami_id                     = var.ec2_config.ami_id
  instance_type              = var.ec2_config.instance_type
  key_name                   = var.enable_features.key_pair ? module.key_pair[0].key_name : null
  security_group_ids         = var.enable_features.vpc ? [module.security_groups[0].security_group_ids["ec2"]] : []
  subnet_ids                 = var.enable_features.vpc ? module.vpc[0].private_subnet_ids : []
  target_group_arns          = var.enable_features.load_balancer ? [module.load_balancer[0].target_group_arn] : []
  iam_instance_profile       = module.iam.ec2_instance_profile_name
  min_size                   = var.autoscaling_config.min_size
  max_size                   = var.autoscaling_config.max_size
  desired_capacity           = var.autoscaling_config.desired_capacity
  health_check_type          = var.autoscaling_config.health_check_type
  health_check_grace_period  = var.autoscaling_config.health_check_grace_period
  default_cooldown           = var.autoscaling_config.default_cooldown
  instance_warmup            = var.autoscaling_config.instance_warmup
  enabled_metrics            = var.autoscaling_config.enabled_metrics
  root_volume_size           = var.ec2_config.root_volume_size
  root_volume_type           = var.ec2_config.root_volume_type
  root_volume_encrypted      = var.ec2_config.root_volume_encrypted
  tags                       = local.common_tags

  depends_on = [module.vpc, module.security_groups, module.iam, module.load_balancer]
}


module "load_balancer" {
  count  = var.enable_features.load_balancer ? 1 : 0
  source = "./modules/load_balancer"

  name_prefix                        = local.name_prefix
  load_balancer_type                 = var.load_balancer_config.type
  scheme                            = var.load_balancer_config.scheme
  security_group_ids                = var.enable_features.vpc ? [module.security_groups[0].security_group_ids["alb"]] : []
  subnet_ids                        = var.enable_features.vpc ? module.vpc[0].public_subnet_ids : []
  vpc_id                           = var.enable_features.vpc ? module.vpc[0].vpc_id : null
  enable_deletion_protection        = var.load_balancer_config.enable_deletion_protection
  idle_timeout                     = var.load_balancer_config.idle_timeout
  enable_http2                     = var.load_balancer_config.enable_http2
  enable_cross_zone_load_balancing = var.load_balancer_config.enable_cross_zone_load_balancing
  tags                             = local.common_tags

  depends_on = [module.vpc, module.security_groups]
}


module "rds" {
  count  = var.enable_features.rds ? 1 : 0
  source = "./modules/rds_mysql"

  name_prefix                = local.name_prefix
  engine_version             = var.rds_config.engine_version
  instance_class             = var.rds_config.instance_class
  allocated_storage          = var.rds_config.allocated_storage
  max_allocated_storage      = var.rds_config.max_allocated_storage
  storage_type               = var.rds_config.storage_type
  storage_encrypted          = var.rds_config.storage_encrypted
  database_name              = var.rds_database_config.database_name
  username                   = var.rds_database_config.username
  port                       = var.rds_database_config.port
  multi_az                   = var.rds_config.multi_az
  publicly_accessible        = var.rds_config.publicly_accessible
  backup_retention_period    = var.rds_config.backup_retention_period
  backup_window              = var.rds_config.backup_window
  maintenance_window         = var.rds_config.maintenance_window
  deletion_protection        = var.rds_config.deletion_protection
  skip_final_snapshot        = var.rds_config.skip_final_snapshot
  final_snapshot_identifier  = var.rds_config.final_snapshot_identifier
  vpc_security_group_ids     = var.enable_features.vpc ? [module.security_groups[0].security_group_ids["rds"]] : []
  subnet_group_subnet_ids    = var.enable_features.vpc ? module.vpc[0].database_subnet_ids : []
  tags                       = local.common_tags

  depends_on = [module.vpc, module.security_groups]
}


module "backup" {
  count  = var.enable_features.backup ? 1 : 0
  source = "./modules/backup_vault"

  vault_name           = var.backup_config.backup_vault_name
  plan_name            = var.backup_config.backup_plan_name
  backup_rules         = var.backup_config.rules
  iam_role_arn         = module.iam.backup_role_arn
  project_name         = var.project_name
  environment          = var.environment
  tags                 = local.common_tags

  depends_on = [module.iam]
}


#module "cloudtrail" {
#  count  = var.enable_features.cloudtrail ? 1 : 0
#  source = "./modules/cloudtrail"

#  trail_name                           = var.cloudtrail_config.trail_name
#  s3_bucket_name                       = var.cloudtrail_config.s3_bucket_name
#  include_global_service_events        = var.cloudtrail_config.include_global_service_events
#  is_multi_region_trail               = var.cloudtrail_config.is_multi_region_trail
#  enable_logging                      = var.cloudtrail_config.enable_logging
#  enable_log_file_validation          = var.cloudtrail_config.enable_log_file_validation
#  event_selector_read_write_type      = var.cloudtrail_config.event_selector_read_write_type
#  event_selector_include_management_events = var.cloudtrail_config.event_selector_include_management_events
#  cloudtrail_role_arn                 = module.iam.cloudtrail_role_arn
#  project_name                        = var.project_name
#  environment                         = var.environment
#  tags                                = local.common_tags
#
#  depends_on = [module.iam]
#}


module "waf" {
  count  = var.enable_features.waf && var.enable_features.load_balancer ? 1 : 0
  source = "./modules/waf"

  name_prefix                    = local.name_prefix
  scope                         = var.waf_config.scope
  resource_arn                  = module.load_balancer[0].load_balancer_arn
  cloudwatch_metrics_enabled    = var.waf_config.cloudwatch_metrics_enabled
  sampled_requests_enabled      = var.waf_config.sampled_requests_enabled
  tags                          = local.common_tags

  depends_on = [module.load_balancer]
}
