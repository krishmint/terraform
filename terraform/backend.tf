# Backend configuration for remote state storage
terraform {
  backend "s3" {
    # Configure these values according to your setup
    bucket = "infra-terraform-01"
   
    region = "us-east-1"

    # Encryption at rest
    encrypt = true

    # Note: DynamoDB table for state locking is intentionally omitted
    # as per requirements
  }
}
