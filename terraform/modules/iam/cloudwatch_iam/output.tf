# return cloudwatch log policy arn
output "cloudwatch_logs_policy_arn" {
  description = "ARN of the CloudWatch logs policy"
  value       = aws_iam_policy.cloudwatch_logs.arn
}