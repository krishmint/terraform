# Generate TLS private key
resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096

  lifecycle {
    prevent_destroy = false
  }
}

# Create AWS key pair
resource "aws_key_pair" "main" {
  key_name   = var.key_name
  public_key = tls_private_key.main.public_key_openssh

  lifecycle {
    prevent_destroy = false
  }

  tags = merge(
    var.tags,
    {
      Name = var.key_name
    }
  )
}

# S3 Bucket for storing private key
resource "aws_s3_bucket" "key_storage" {
  bucket = var.s3_bucket_name

  lifecycle {
    prevent_destroy = false
  }

  tags = merge(
    var.tags,
    {
      Name        = var.s3_bucket_name
      Purpose     = "SSH Key Storage"
      Project     = var.project_name
      Environment = var.environment
    }
  )
}

# S3 Bucket versioning
resource "aws_s3_bucket_versioning" "key_storage" {
  bucket = aws_s3_bucket.key_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "key_storage" {
  bucket = aws_s3_bucket.key_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket public access block
resource "aws_s3_bucket_public_access_block" "key_storage" {
  bucket = aws_s3_bucket.key_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Store private key in S3
resource "aws_s3_object" "private_key" {
  bucket  = aws_s3_bucket.key_storage.id
  key     = "${var.s3_key_prefix}/${var.key_name}-private-key.pem"
  content = tls_private_key.main.private_key_pem
  
  server_side_encryption = "AES256"
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.key_name}-private-key"
      KeyPair     = var.key_name
      Project     = var.project_name
      Environment = var.environment
    }
  )

  lifecycle {
    prevent_destroy = false
  }
}

# Store public key in S3 (for reference)
resource "aws_s3_object" "public_key" {
  bucket  = aws_s3_bucket.key_storage.id
  key     = "${var.s3_key_prefix}/${var.key_name}-public-key.pub"
  content = tls_private_key.main.public_key_openssh
  
  server_side_encryption = "AES256"
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.key_name}-public-key"
      KeyPair     = var.key_name
      Project     = var.project_name
      Environment = var.environment
    }
  )

  lifecycle {
    prevent_destroy = false
  }
}
