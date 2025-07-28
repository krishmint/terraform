variable "vault-name" {
  type = string
}

variable "vault-tags" {
  type = map(string)
}

variable "backup-plan-name" {
  type    = string
  default = "asg-backup-plan"
}

variable "backup_tag_key" {
  type = string
}

variable "backup_tag_value" {
  type = string
}

# backup Module Variables
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "custom_policy_json" {}
variable "vault_access_policy_json" {}
variable "backup_role_arn" {}
variable "backup_role_name" {}