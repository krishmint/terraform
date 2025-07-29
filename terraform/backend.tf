# S3 Backend Configuration (No DynamoDB locking as requested)
terraform {
  backend "s3" {
    bucket         = var.backend_bucket_name
    key            = var.backend_key
    region         = var.backend_region
    encrypt        = true
    versioning     = true
  }

  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.default_tags
  }
}