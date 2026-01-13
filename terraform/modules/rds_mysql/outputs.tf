output "instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.main.arn
}

output "endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "database_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "username" {
  description = "Master username"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "password_secret_arn" {
  description = "ARN of the secret containing the database password"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "password_secret_name" {
  description = "Name of the secret containing the database password"
  value       = aws_secretsmanager_secret.db_password.name
}

output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.main.name
}

output "parameter_group_name" {
  description = "DB parameter group name"
  value       = aws_db_parameter_group.main.name
}

output "option_group_name" {
  description = "DB option group name"
  value       = aws_db_option_group.main.name
}

output "security_group_ids" {
  description = "Security group IDs attached to the RDS instance"
  value       = aws_db_instance.main.vpc_security_group_ids
}

output "hosted_zone_id" {
  description = "Hosted zone ID of the RDS instance"
  value       = aws_db_instance.main.hosted_zone_id
}