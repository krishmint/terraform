output "security_group_ids" {
  description = "Map of security group names to IDs"
  value       = { for k, v in aws_security_group.main : k => v.id }
}

output "security_group_arns" {
  description = "Map of security group names to ARNs"
  value       = { for k, v in aws_security_group.main : k => v.arn }
}