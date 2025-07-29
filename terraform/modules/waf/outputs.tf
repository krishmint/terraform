output "web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.id
}

output "web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.arn
}

output "web_acl_name" {
  description = "Name of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.name
}

output "allowed_ip_set_arn" {
  description = "ARN of the allowed IP set"
  value       = length(var.allowed_ips) > 0 ? aws_wafv2_ip_set.allowed_ips[0].arn : null
}

output "blocked_ip_set_arn" {
  description = "ARN of the blocked IP set"
  value       = length(var.blocked_ips) > 0 ? aws_wafv2_ip_set.blocked_ips[0].arn : null
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = var.enable_logging ? aws_cloudwatch_log_group.waf_logs[0].name : null
}