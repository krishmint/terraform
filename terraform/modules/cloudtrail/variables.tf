variable "trail_name" {
  description = "Name of the CloudTrail"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}

variable "include_global_service_events" {
  description = "Include global service events"
  type        = bool
  default     = true
}

variable "is_multi_region_trail" {
  description = "Multi-region trail"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable logging"
  type        = bool
  default     = true
}

variable "enable_log_file_validation" {
  description = "Enable log file validation"
  type        = bool
  default     = true
}

variable "event_selector_read_write_type" {
  description = "Event selector read/write type"
  type        = string
  default     = "All"
}

variable "event_selector_include_management_events" {
  description = "Include management events in event selector"
  type        = bool
  default     = true
}

variable "cloudtrail_role_arn" {
  description = "IAM role ARN for CloudTrail"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 90
}

variable "log_retention_days_s3" {
  description = "S3 log retention period in days"
  type        = number
  default     = 2555  # 7 years
}

variable "enable_metric_filters" {
  description = "Enable CloudWatch metric filters"
  type        = bool
  default     = true
}

variable "alarm_sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarms"
  type        = string
  default     = null
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}