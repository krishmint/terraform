variable "ec2_configs" {
  description = "List of EC2 instance configurations"
  type        = list(object({
    name_prefix                 = string
    ami_id                      = string
    instance_type               = string
    key_name                    = string
    subnet_id                   = string
    vpc_security_group_ids      = list(string)
    iam_instance_profile        = string
    associate_public_ip_address = bool
    root_volume_size            = number 
    root_volume_type            = string
    root_volume_encrypted       = bool
    enable_detailed_monitoring  = bool
  }))
}

variable "associate_public_ip_address" {
  description = "Associate a public IP address with the instance"
  type        = bool
  default     = true
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 8
}

variable "root_volume_encrypted" {
  description = "Encrypt root volume"
  type        = bool
  default     = true
}

variable "user_data" {
  description = "User data script"
  type        = string
  default     = null
}

variable "create_eip" {
  description = "Create and associate an Elastic IP"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
