output "ec2_role_arn" {
  description = "ARN of the EC2 role"
  value       = aws_iam_role.ec2_role.arn
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "backup_role_arn" {
  description = "ARN of the backup role"
  value       = aws_iam_role.backup_role.arn
}

output "cloudtrail_role_arn" {
  description = "ARN of the CloudTrail role"
  value       = aws_iam_role.cloudtrail_role.arn
}

output "cloudwatch_role_arn" {
  description = "ARN of the CloudWatch role"
  value       = aws_iam_role.cloudwatch_role.arn
}

output "developers_group_name" {
  description = "Name of the developers group"
  value       = aws_iam_group.developers.name
}

output "operators_group_name" {
  description = "Name of the operators group"
  value       = aws_iam_group.operators.name
}