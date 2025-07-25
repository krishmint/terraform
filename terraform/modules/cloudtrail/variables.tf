# CloudTrail Module Variables
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudTrail logs in CloudWatch"
  type        = number
  default     = 90
}

variable "force_destroy_bucket" {
  description = "Force destroy S3 bucket even if not empty"
  type        = bool
  default     = false
}

variable "enable_session_tracking" {
  description = "Enable DynamoDB table and Lambda for session tracking"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}