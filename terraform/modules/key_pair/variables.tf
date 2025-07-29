variable "key_name" {
  description = "Name for the key pair"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for storing private key"
  type        = string
}

variable "s3_key_prefix" {
  description = "S3 key prefix for organizing keys"
  type        = string
  default     = "ssh-keys"
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