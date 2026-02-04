# S3 Backend Configuration (No DynamoDB locking as requested)
terraform {
  backend "s3" {
    bucket         = "terra-state-bucket-krish" ## varibale cannot be used as terraform {} block (where you define the backend) 
                                                ## is processed before any variables are loaded  
    key            = "dev/terraform.tfstate"
    use_lockfile   = true         ## new feature of terraform to lock state file without use of dynabodb
    region         = "ap-south-1"
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
