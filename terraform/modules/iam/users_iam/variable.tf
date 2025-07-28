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

variable "developer_users" {
  description = "List of developer usernames"
  type        = list(string)
  default     = ["developer1", "developer2", "developer3"]
}

variable "devops_users" {
  description = "List of DevOps usernames"
  type        = list(string)
  default     = ["devops1"]
}

variable "admin_users" {
  description = "List of admin usernames"
  type        = list(string)
  default     = ["admin1"]
}

variable "create_access_keys" {
  type    = bool
  default = true
}
