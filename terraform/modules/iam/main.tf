# IAM Module - main.tf
locals {
  name_prefix = "${var.environment}-${var.project_name}"
}

# IAM Role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "${local.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-ec2-role"
  })
}

# Attach EC2 Read Only Access policy
resource "aws_iam_role_policy_attachment" "ec2_readonly" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# Attach SSM Managed Instance Core policy (for Systems Manager)
resource "aws_iam_role_policy_attachment" "ssm_managed_instance" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
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
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${local.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-ec2-profile"
  })
}

# IAM Users
resource "aws_iam_user" "developers" {
  count = length(var.developer_users)
  name  = var.developer_users[count.index]
  path  = "/developers/"

  tags = merge(var.tags, {
    Name = var.developer_users[count.index]
    Role = "Developer"
  })
}

resource "aws_iam_user" "devops" {
  count = length(var.devops_users)
  name  = var.devops_users[count.index]
  path  = "/devops/"

  tags = merge(var.tags, {
    Name = var.devops_users[count.index]
    Role = "DevOps"
  })
}

resource "aws_iam_user" "admin" {
  count = length(var.admin_users)
  name  = var.admin_users[count.index]
  path  = "/admin/"

  tags = merge(var.tags, {
    Name = var.admin_users[count.index]
    Role = "Admin"
  })
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
  count      = length(aws_iam_user.developers)
  user       = aws_iam_user.developers[count.index].name
  policy_arn = aws_iam_policy.developer_policy.arn
}

resource "aws_iam_user_policy_attachment" "devops_policy_attachment" {
  count      = length(aws_iam_user.devops)
  user       = aws_iam_user.devops[count.index].name
  policy_arn = aws_iam_policy.devops_policy.arn
}

resource "aws_iam_user_policy_attachment" "admin_policy_attachment" {
  count      = length(aws_iam_user.admin)
  user       = aws_iam_user.admin[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create access keys for users (optional - for programmatic access)
resource "aws_iam_access_key" "developer_keys" {
  count = var.create_access_keys ? length(aws_iam_user.developers) : 0
  user  = aws_iam_user.developers[count.index].name
}

resource "aws_iam_access_key" "devops_keys" {
  count = var.create_access_keys ? length(aws_iam_user.devops) : 0
  user  = aws_iam_user.devops[count.index].name
}

resource "aws_iam_access_key" "admin_keys" {
  count = var.create_access_keys ? length(aws_iam_user.admin) : 0
  user  = aws_iam_user.admin[count.index].name
}