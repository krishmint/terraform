variable "vault_name" {
  description = "Name of the backup vault"
  type        = string
}

variable "plan_name" {
  description = "Name of the backup plan"
  type        = string
}

variable "backup_rules" {
  description = "List of backup rules"
  type = list(object({
    name                 = string
    schedule             = string
    start_window         = number
    completion_window    = number
    delete_after         = number
    cold_storage_after   = number
    recovery_point_tags  = map(string)
  }))
}

variable "iam_role_arn" {
  description = "IAM role ARN for backup operations"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "enable_notifications" {
  description = "Enable backup notifications"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}