# WAF Module Variables
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "rate_limit" {
  description = "Rate limit for requests per 5-minute period"
  type        = number
  default     = 2000
}

variable "blocked_countries" {
  description = "List of country codes to block"
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "Number of days to retain WAF logs"
  type        = number
  default     = 30
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}