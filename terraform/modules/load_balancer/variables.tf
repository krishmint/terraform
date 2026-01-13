variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "load_balancer_type" {
  description = "Type of load balancer (application, network, gateway)"
  type        = string
  default     = "application"
}

variable "scheme" {
  description = "Load balancer scheme (internet-facing or internal)"
  type        = string
  default     = "internet-facing"
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the target group"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "Idle timeout in seconds"
  type        = number
  default     = 60
}

variable "enable_http2" {
  description = "Enable HTTP/2"
  type        = bool
  default     = true
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "S3 bucket for access logs"
  type        = string
  default     = null
}

variable "access_logs_prefix" {
  description = "S3 prefix for access logs"
  type        = string
  default     = "alb-logs"
}

variable "target_group_port" {
  description = "Target group port"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Target group protocol"
  type        = string
  default     = "HTTP"
}

variable "health_check_healthy_threshold" {
  description = "Health check healthy threshold"
  type        = number
  default     = 2
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_matcher" {
  description = "Health check matcher"
  type        = string
  default     = "200"
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_unhealthy_threshold" {
  description = "Health check unhealthy threshold"
  type        = number
  default     = 2
}

variable "stickiness_type" {
  description = "Stickiness type"
  type        = string
  default     = "lb_cookie"
}

variable "stickiness_cookie_duration" {
  description = "Stickiness cookie duration in seconds"
  type        = number
  default     = 86400
}

variable "stickiness_enabled" {
  description = "Enable stickiness"
  type        = bool
  default     = false
}

variable "enable_http_listener" {
  description = "Enable HTTP listener (redirect to HTTPS)"
  type        = bool
  default     = true
}

variable "enable_https_listener" {
  description = "Enable HTTPS listener"
  type        = bool
  default     = false
}

variable "enable_http_only_listener" {
  description = "Enable HTTP-only listener (no HTTPS redirect)"
  type        = bool
  default     = false
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "certificate_arn" {
  description = "SSL certificate ARN for HTTPS listener"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}