
# EC2 Instance Role
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-${var.environment}-ec2-role"

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

  lifecycle {
    prevent_destroy = false
  }

  tags = var.tags
}

# EC2 Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  lifecycle {
    prevent_destroy = false
  }

  tags = var.tags
}

# EC2 Role Policy - Basic CloudWatch and SSM permissions
resource "aws_iam_role_policy" "ec2_policy" {
  name = "${var.project_name}-${var.environment}-ec2-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:UpdateInstanceInformation",
          "ssm:SendCommand"
        ]
        Resource = "*"
      }
    ]
  })
}

# # Backup Service Role
# resource "aws_iam_role" "backup_role" {
#   name = "${var.project_name}-${var.environment}-backup-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "backup.amazonaws.com"
#         }
#       }
#     ]
#   })

#   lifecycle {
#     prevent_destroy = false
#   }

#   tags = var.tags
# }

# # Attach AWS managed backup policy
# resource "aws_iam_role_policy_attachment" "backup_policy" {
#   role       = aws_iam_role.backup_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
# }

# # CloudTrail Role
# resource "aws_iam_role" "cloudtrail_role" {
#   name = "${var.project_name}-${var.environment}-cloudtrail-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "cloudtrail.amazonaws.com"
#         }
#       }
#     ]
#   })

#   lifecycle {
#     prevent_destroy = false
#   }

#   tags = var.tags
# }

# # CloudTrail S3 Policy
# resource "aws_iam_role_policy" "cloudtrail_s3_policy" {
#   name = "${var.project_name}-${var.environment}-cloudtrail-s3-policy"
#   role = aws_iam_role.cloudtrail_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:PutObject",
#           "s3:GetBucketACL"
#         ]
#         Resource = [
#           "arn:aws:s3:::${var.project_name}-${var.environment}-cloudtrail-*",
#           "arn:aws:s3:::${var.project_name}-${var.environment}-cloudtrail-*/*"
#         ]
#       }
#     ]
#   })
# }

# # CloudWatch Logs Role
# resource "aws_iam_role" "cloudwatch_role" {
#   name = "${var.project_name}-${var.environment}-cloudwatch-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "logs.amazonaws.com"
#         }
#       }
#     ]
#   })

#   lifecycle {
#     prevent_destroy = false
#   }

#   tags = var.tags
# }

# # Users and Groups (Optional - only if needed)
# resource "aws_iam_group" "developers" {
#   name = "${var.project_name}-${var.environment}-developers"
#   path = "/"
# }

# resource "aws_iam_group" "operators" {
#   name = "${var.project_name}-${var.environment}-operators"
#   path = "/"
# }

# # Developer Group Policy
# resource "aws_iam_group_policy" "developers_policy" {
#   name  = "${var.project_name}-${var.environment}-developers-policy"
#   group = aws_iam_group.developers.name

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "ec2:Describe*",
#           "rds:Describe*",
#           "s3:ListBucket",
#           "s3:GetObject",
#           "logs:Describe*",
#           "logs:Get*",
#           "cloudwatch:Get*",
#           "cloudwatch:List*"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# # Operator Group Policy
# resource "aws_iam_group_policy" "operators_policy" {
#   name  = "${var.project_name}-${var.environment}-operators-policy"
#   group = aws_iam_group.operators.name

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "ec2:*",
#           "rds:*",
#           "s3:*",
#           "logs:*",
#           "cloudwatch:*",
#           "backup:*"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

