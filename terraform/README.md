# Terraform AWS Infrastructure

This Terraform configuration creates a complete AWS infrastructure with a modular design following best practices.

## Architecture Overview

The infrastructure includes:
- **VPC**: Custom VPC with public and private subnets across multiple AZs
- **Security Groups**: Configurable security groups for web and database tiers
- **Auto Scaling**: Auto Scaling Group with Ubuntu 22.04 instances
- **IAM**: IAM roles and policies for EC2 instances
- **WAF**: Optional AWS WAF with managed rules (conditionally deployed)

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform >= 1.8** installed
3. **S3 bucket** for remote state storage
4. **Appropriate IAM permissions** for resource creation

## Quick Start

1. **Clone and navigate to the terraform directory:**
   ```bash
   cd terraform/
   ```

2. **Update backend configuration:**
   Edit `backend.tf` and update the S3 bucket name and region:
   ```hcl
   terraform {
     backend "s3" {
       bucket = "your-terraform-state-bucket"  # Update this
       key    = "infrastructure/terraform.tfstate"
       region = "us-west-2"                    # Update this
       encrypt = true
     }
   }
   ```

3. **Customize variables:**
   Edit `terraform.tfvars` to match your requirements:
   ```hcl
   environment  = "staging"  # or "prod"
   project_name = "webapp"
   aws_region   = "us-west-2"
   
   # Enable WAF if needed
   enable_waf = true
   ```

4. **Initialize and apply:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Module Structure

```
terraform/
├── main.tf              # Root module configuration
├── variables.tf         # Root module variables
├── outputs.tf          # Root module outputs
├── backend.tf          # Remote state configuration
├── terraform.tfvars   # Variable values
└── modules/
    ├── vpc/            # VPC and networking
    ├── security_group/ # Security groups
    ├── iam/           # IAM roles and policies
    ├── autoscaling/   # Auto Scaling Group
    └── waf/           # AWS WAF (optional)
```

## Environment-Based Naming

All resources use the naming convention: `{environment}-{project_name}-{resource_type}`

Examples:
- `staging-webapp-vpc`
- `prod-webapp-asg`
- `staging-webapp-web-sg`

## Configuration Options

### VPC Configuration
- **CIDR blocks**: Configurable for VPC and subnets
- **Availability Zones**: Multi-AZ deployment
- **NAT Gateway**: Optional for private subnet internet access

### Auto Scaling
- **Instance Type**: Configurable (default: t3.micro)
- **Capacity**: Min, max, and desired instance counts
- **AMI**: Latest Ubuntu 22.04 LTS
- **Monitoring**: CloudWatch alarms for CPU-based scaling

### Security
- **Security Groups**: Web tier (HTTP/HTTPS/SSH) and database tier
- **IAM**: EC2 role with read-only access and CloudWatch permissions
- **WAF**: Optional with managed rules and rate limiting

### WAF Features (Optional)
- AWS Managed Common Rule Set
- Known Bad Inputs protection
- Rate limiting (configurable)
- Geo-blocking (configurable)
- CloudWatch logging

## Outputs

The configuration provides comprehensive outputs including:
- VPC and subnet IDs
- Security group IDs
- Auto Scaling Group details
- IAM role and profile information
- WAF Web ACL ARN (if enabled)

## Customization

### Adding New Environments
1. Create new `.tfvars` files (e.g., `prod.tfvars`)
2. Update the environment variable
3. Apply with: `terraform apply -var-file="prod.tfvars"`

### Enabling WAF
Set `enable_waf = true` in your variables file. The WAF module will be conditionally created.

### Modifying Security Groups
Edit the security group module to add/remove rules as needed for your application requirements.

## Best Practices Implemented

- ✅ **Modular Design**: Separate modules for each logical component
- ✅ **Remote State**: S3 backend for state management
- ✅ **Environment Separation**: Environment-based naming and tagging
- ✅ **Security**: Least privilege IAM, security groups, and optional WAF
- ✅ **Monitoring**: CloudWatch integration and alarms
- ✅ **High Availability**: Multi-AZ deployment
- ✅ **Auto Scaling**: CPU-based scaling policies
- ✅ **Latest Versions**: Terraform 1.8+ and AWS Provider 5.x

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

**Warning**: This will permanently delete all resources. Make sure you have backups if needed.

## Support

For issues or questions:
1. Check the Terraform documentation
2. Review AWS service documentation
3. Validate your IAM permissions
4. Check CloudWatch logs for application issues