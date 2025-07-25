# CloudTrail Module - main.tf
locals {
  name_prefix = "${var.environment}-${var.project_name}"
}

# S3 Bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket        = "${local.name_prefix}-cloudtrail-logs-${random_string.bucket_suffix.result}"
  force_destroy = var.force_destroy_bucket

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-cloudtrail-logs"
  })
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket versioning
resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket public access block
resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket policy for CloudTrail
resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail_logs.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# CloudWatch Log Group for CloudTrail
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/${local.name_prefix}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-cloudtrail-logs"
  })
}

# IAM Role for CloudTrail to write to CloudWatch Logs
resource "aws_iam_role" "cloudtrail_logs_role" {
  name = "${local.name_prefix}-cloudtrail-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for CloudTrail to write to CloudWatch Logs
resource "aws_iam_role_policy" "cloudtrail_logs_policy" {
  name = "${local.name_prefix}-cloudtrail-logs-policy"
  role = aws_iam_role.cloudtrail_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
      }
    ]
  })
}

# CloudTrail
resource "aws_cloudtrail" "main" {
  name           = "${local.name_prefix}-cloudtrail"
  s3_bucket_name = aws_s3_bucket.cloudtrail_logs.bucket

  # CloudWatch Logs integration
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_logs_role.arn

  # Event selectors for comprehensive logging
  event_selector {
    read_write_type                 = "All"
    include_management_events       = true
    exclude_management_event_sources = []

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::*/*"]
    }

    data_resource {
      type   = "AWS::S3::Bucket"
      values = ["arn:aws:s3:::*"]
    }
  }

  # Advanced event selectors for detailed logging
  advanced_event_selector {
    name = "Log all management and data events"
    field_selector {
      field  = "eventCategory"
      equals = ["Management", "Data"]
    }
  }

  # Insight selectors for API call analysis
  insight_selector {
    insight_type = "ApiCallRateInsight"
  }

  depends_on = [aws_s3_bucket_policy.cloudtrail_logs]

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-cloudtrail"
  })
}

# DynamoDB table for session metadata (optional)
resource "aws_dynamodb_table" "user_sessions" {
  count = var.enable_session_tracking ? 1 : 0

  name           = "${local.name_prefix}-user-sessions"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "username"
  range_key      = "session_id"

  attribute {
    name = "username"
    type = "S"
  }

  attribute {
    name = "session_id"
    type = "S"
  }

  attribute {
    name = "login_time"
    type = "S"
  }

  global_secondary_index {
    name     = "LoginTimeIndex"
    hash_key = "username"
    range_key = "login_time"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-user-sessions"
  })
}

# Lambda function for processing CloudTrail logs (optional)
resource "aws_lambda_function" "cloudtrail_processor" {
  count = var.enable_session_tracking ? 1 : 0

  filename         = "cloudtrail_processor.zip"
  function_name    = "${local.name_prefix}-cloudtrail-processor"
  role            = aws_iam_role.lambda_role[0].arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 60

  source_code_hash = data.archive_file.lambda_zip[0].output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.user_sessions[0].name
    }
  }

  tags = var.tags
}

# Lambda deployment package
data "archive_file" "lambda_zip" {
  count = var.enable_session_tracking ? 1 : 0

  type        = "zip"
  output_path = "cloudtrail_processor.zip"
  source {
    content = templatefile("${path.module}/lambda_function.py", {
      dynamodb_table = var.enable_session_tracking ? aws_dynamodb_table.user_sessions[0].name : ""
    })
    filename = "index.py"
  }
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  count = var.enable_session_tracking ? 1 : 0

  name = "${local.name_prefix}-lambda-cloudtrail-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  count = var.enable_session_tracking ? 1 : 0

  name = "${local.name_prefix}-lambda-cloudtrail-policy"
  role = aws_iam_role.lambda_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.user_sessions[0].arn
      }
    ]
  })
}

# CloudWatch Log Stream trigger for Lambda
resource "aws_cloudwatch_log_subscription_filter" "cloudtrail_filter" {
  count = var.enable_session_tracking ? 1 : 0

  name            = "${local.name_prefix}-cloudtrail-filter"
  log_group_name  = aws_cloudwatch_log_group.cloudtrail.name
  filter_pattern  = "[timestamp, request_id, event_name=\"ConsoleLogin\" || event_name=\"AssumeRole\" || event_name=\"GetSessionToken\"]"
  destination_arn = aws_lambda_function.cloudtrail_processor[0].arn
}

# Permission for CloudWatch Logs to invoke Lambda
resource "aws_lambda_permission" "allow_cloudwatch" {
  count = var.enable_session_tracking ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatchLogs"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudtrail_processor[0].function_name
  principal     = "logs.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
}