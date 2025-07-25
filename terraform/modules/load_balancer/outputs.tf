# Load Balancer Module Outputs
output "load_balancer_id" {
  description = "ID of the load balancer"
  value       = aws_lb.main.id
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.web.arn
}

output "target_group_name" {
  description = "Name of the target group"
  value       = aws_lb_target_group.web.name
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.web.arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener (if enabled)"
  value       = var.ssl_certificate_arn != "" ? aws_lb_listener.web_https[0].arn : null
}