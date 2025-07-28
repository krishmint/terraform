locals {
  name_prefix = "${var.environment}-${var.project_name}"
}

# Custom policy for CloudWatch logs (optional)
resource "aws_iam_policy" "cloudwatch_logs" {
  name        = "${local.name_prefix}-cloudwatch-logs"
  description = "Policy for CloudWatch logs access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })

  tags = var.tags
}

# Attach custom CloudWatch logs policy
resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = var.ec2_role_name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}