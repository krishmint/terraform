variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "scope" {
  description = "WAF scope (REGIONAL or CLOUDFRONT)"
  type        = string
  default     = "REGIONAL"
  
  validation {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.scope)
    error_message = "Scope must be either REGIONAL or CLOUDFRONT."
  }
}

variable "resource_arn" {
  description = "ARN of the resource to associate with WAF (ALB, CloudFront, etc.)"
  type        = string
}

variable "cloudwatch_metrics_enabled" {
  description = "Enable CloudWatch metrics"
  type        = bool
  default     = true
}

variable "sampled_requests_enabled" {
  description = "Enable sampled requests"
  type        = bool
  default     = true
}

variable "rate_limit" {
  description = "Rate limit for requests per 5-minute period"
  type        = number
  default     = 2000
}

variable "enable_ip_reputation_rule" {
  description = "Enable IP reputation list rule"
  type        = bool
  default     = true
}

variable "allowed_ips" {
  description = "List of IP addresses to allow"
  type        = list(string)
  default     = []
}

variable "blocked_ips" {
  description = "List of IP addresses to block"
  type        = list(string)
  default     = []
}

variable "enable_logging" {
  description = "Enable WAF logging"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}