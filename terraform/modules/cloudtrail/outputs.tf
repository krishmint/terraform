# CloudTrail Module Outputs
output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_name" {
  description = "Name of the CloudTrail"
  value       = aws_cloudtrail.main.name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for session tracking"
  value       = var.enable_session_tracking ? aws_dynamodb_table.user_sessions[0].name : null
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for session tracking"
  value       = var.enable_session_tracking ? aws_dynamodb_table.user_sessions[0].arn : null
}

output "lambda_function_name" {
  description = "Name of the Lambda function for CloudTrail processing"
  value       = var.enable_session_tracking ? aws_lambda_function.cloudtrail_processor[0].function_name : null
}