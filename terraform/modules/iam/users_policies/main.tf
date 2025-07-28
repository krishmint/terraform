locals {
  name_prefix = "${var.environment}-${var.project_name}"
}

# Developer Policy - EC2 and S3 access
resource "aws_iam_policy" "developer_policy" {
  name        = "${local.name_prefix}-developer-policy"
  description = "Policy for developers with EC2 and S3 access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:RebootInstances",
          "ec2:CreateTags",
          "ec2:CreateSnapshot",
          "ec2:DescribeSnapshots",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# DevOps Policy - Infrastructure and deployment access
resource "aws_iam_policy" "devops_policy" {
  name        = "${local.name_prefix}-devops-policy"
  description = "Policy for DevOps with infrastructure and deployment access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "s3:*",
          "autoscaling:*",
          "elasticloadbalancing:*",
          "cloudwatch:*",
          "logs:*",
          "iam:ListRoles",
          "iam:ListInstanceProfiles",
          "iam:PassRole",
          "vpc:*",
          "route53:*",
          "acm:*",
          "wafv2:*",
          "cloudtrail:*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# Attach policies to users
resource "aws_iam_user_policy_attachment" "developer_policy_attachment" {
  count      = length(var.developer_users_resource)
  user       = var.developer_users_resource[count.index].name
  policy_arn = aws_iam_policy.developer_policy.arn
}

resource "aws_iam_user_policy_attachment" "devops_policy_attachment" {
  count      = length(var.devops_users_resource)
  user       = var.devops_users_resource[count.index].name
  policy_arn = aws_iam_policy.devops_policy.arn
}

resource "aws_iam_user_policy_attachment" "admin_policy_attachment" {
  count      = length(var.admin_users_resource)
  user       = var.admin_users_resource[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create access keys for users (optional - for programmatic access)
resource "aws_iam_access_key" "developer_keys" {
  count = var.create_access_keys ? length(var.developer_users) : 0
  user  = var.developer_users[count.index]
}

resource "aws_iam_access_key" "devops_keys" {
  count = var.create_access_keys ? length(var.devops_users) : 0
  user  = var.devops_users[count.index]
}

resource "aws_iam_access_key" "admin_keys" {
  count = var.create_access_keys ? length(var.admin_users) : 0
  user  = var.admin_users[count.index]
}
