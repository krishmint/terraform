# Backend configuration for remote state storage
terraform {
  backend "s3" {
    # Configure these values according to your setup
    bucket = "your-terraform-state-bucket"
    key    = "infrastructure/terraform.tfstate"
    region = "us-west-2"
    
    # Encryption at rest
    encrypt = true
    
    # Note: DynamoDB table for state locking is intentionally omitted
    # as per requirements
  }
}