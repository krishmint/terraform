output "trail_arn" {
  description = "ARN of the CloudTrail"
  value       = aws_cloudtrail.main.arn
}

output "trail_id" {
  description = "ID of the CloudTrail"
  value       = aws_cloudtrail.main.id
}

output "s3_bucket_name" {
  description = "S3 bucket name for logs"
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN for logs"
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudwatch_log_group_arn" {
  description = "CloudWatch log group ARN"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}