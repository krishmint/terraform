variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "create_access_keys" {
  type    = bool
  default = true
}

variable "developer_users_resource" {
  description = "Developer IAM user resources"
  type        = list(object({ name = string }))
}

variable "developer_users" {
  type = list(string)
}

variable "devops_users_resource" {
  description = "DevOps IAM user resources"
  type        = list(object({ name = string }))
}

variable "devops_users" {
  type = list(string)
}

variable "admin_users_resource" {
  description = "Admin IAM user resources"
  type        = list(object({ name = string }))
}

variable "admin_users" {
  type = list(string)
}

variable "developer_keys" {
  type = list(object({
    id     = string
    secret = string
  }))
}

variable "devops_keys" {
  type = list(object({
    id     = string
    secret = string
  }))
}

variable "admin_keys" {
  type = list(object({
    id     = string
    secret = string
  }))
}