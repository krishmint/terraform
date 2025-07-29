# Random password for RDS
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Store password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name        = "${var.name_prefix}-rds-password"
  description = "RDS MySQL password for ${var.name_prefix}"

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result

  lifecycle {
    prevent_destroy = true
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.subnet_group_subnet_ids

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-db-subnet-group"
    }
  )
}

# Custom DB Parameter Group
resource "aws_db_parameter_group" "main" {
  family = "mysql${join(".", slice(split(".", var.engine_version), 0, 2))}"
  name   = "${var.name_prefix}-mysql-params"

  # Common MySQL optimizations
  parameter {
    name  = "innodb_buffer_pool_size"
    value = "{DBInstanceClassMemory*3/4}"
  }

  parameter {
    name  = "max_connections"
    value = "1000"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "2"
  }

  parameter {
    name  = "general_log"
    value = "0"
  }

  dynamic "parameter" {
    for_each = var.custom_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}

# Option Group
resource "aws_db_option_group" "main" {
  name                 = "${var.name_prefix}-mysql-options"
  option_group_description = "Option group for ${var.name_prefix} MySQL"
  engine_name          = "mysql"
  major_engine_version = join(".", slice(split(".", var.engine_version), 0, 2))

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier     = "${var.name_prefix}-mysql"
  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class

  # Storage
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted

  # Database
  db_name  = var.database_name
  username = var.username
  password = random_password.db_password.result
  port     = var.port

  # Network & Security
  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.main.name
  publicly_accessible    = var.publicly_accessible

  # High Availability
  multi_az = var.multi_az

  # Backup & Maintenance
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  copy_tags_to_snapshot  = true

  # Parameter and Option Groups
  parameter_group_name = aws_db_parameter_group.main.name
  option_group_name    = aws_db_option_group.main.name

  # Deletion Protection
  deletion_protection       = var.deletion_protection
  skip_final_snapshot      = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : var.final_snapshot_identifier

  # Monitoring
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null

  # Performance Insights
  performance_insights_enabled = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  # Auto Minor Version Upgrade
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  # Apply changes immediately or during maintenance window
  apply_immediately = var.apply_immediately

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      password, # Password is managed by Secrets Manager
    ]
  }

  depends_on = [
    aws_db_parameter_group.main,
    aws_db_option_group.main,
    aws_db_subnet_group.main
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-mysql"
    }
  )
}

# RDS Monitoring Role (optional)
resource "aws_iam_role" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0
  name  = "${var.name_prefix}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count      = var.monitoring_interval > 0 ? 1 : 0
  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# CloudWatch Log Group for slow query logs
resource "aws_cloudwatch_log_group" "rds_slow_query" {
  count             = var.enable_slow_query_log ? 1 : 0
  name              = "/aws/rds/instance/${aws_db_instance.main.identifier}/slowquery"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# CloudWatch Log Group for error logs
resource "aws_cloudwatch_log_group" "rds_error" {
  count             = var.enable_error_log ? 1 : 0
  name              = "/aws/rds/instance/${aws_db_instance.main.identifier}/error"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# CloudWatch Log Group for general logs
resource "aws_cloudwatch_log_group" "rds_general" {
  count             = var.enable_general_log ? 1 : 0
  name              = "/aws/rds/instance/${aws_db_instance.main.identifier}/general"
  retention_in_days = var.log_retention_days

  tags = var.tags
}