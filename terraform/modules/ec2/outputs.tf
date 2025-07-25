# EC2 Module Outputs
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.standalone.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.standalone.arn
}

output "instance_public_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.standalone.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.standalone.private_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the instance"
  value       = aws_instance.standalone.public_dns
}

output "instance_private_dns" {
  description = "Private DNS name of the instance"
  value       = aws_instance.standalone.private_dns
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.ec2_standalone.id
}

output "security_group_arn" {
  description = "ARN of the security group"
  value       = aws_security_group.ec2_standalone.arn
}

output "key_pair_name" {
  description = "Name of the key pair used"
  value       = var.create_key_pair ? aws_key_pair.main[0].key_name : data.aws_key_pair.existing[0].key_name
}

output "key_pair_fingerprint" {
  description = "Fingerprint of the key pair"
  value       = var.create_key_pair ? aws_key_pair.main[0].fingerprint : data.aws_key_pair.existing[0].fingerprint
}

output "elastic_ip" {
  description = "Elastic IP address (if created)"
  value       = var.create_elastic_ip ? aws_eip.standalone[0].public_ip : null
}

output "elastic_ip_allocation_id" {
  description = "Allocation ID of the Elastic IP (if created)"
  value       = var.create_elastic_ip ? aws_eip.standalone[0].allocation_id : null
}

output "ami_id" {
  description = "AMI ID used for the instance"
  value       = data.aws_ami.ubuntu.id
}

output "ami_name" {
  description = "Name of the AMI used"
  value       = data.aws_ami.ubuntu.name
}