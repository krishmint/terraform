# S3 Backend Configuration (No DynamoDB locking as requested)
terraform {
  backend "s3" {
    bucket         = var.backend_bucket_name  
    key            = var.backend_key
    use_lockfile   = true         ## new feature of terraform to lock state file without use of dynabodb
    region         = var.backend_region
    encrypt        = true
  }

### TERRFAORM BLOCK
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

### PROVIDER BLOCK

provider "aws" {
  region = var.aws_region
}
