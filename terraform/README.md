# Terraform Infrastructure Project

This Terraform project follows best practices for managing AWS infrastructure across multiple environments (dev, staging, prod).

<<<<<<< HEAD
## Architecture Overview

##GGG

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
├── backend.tf              # S3 backend configuration
├── main.tf                 # Main configuration with module calls
├── variables.tf            # Global variable definitions
├── outputs.tf             # Global outputs
├── envs/                  # Environment-specific configurations
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
└── modules/               # Reusable modules
    ├── iam/              # Centralized IAM configuration
    ├── key_pair/         # EC2 key pair management with S3 storage
    ├── vpc/              # VPC with subnets, gateways, routing
    ├── security_group/   # Security groups
    ├── ec2/              # EC2 instances
    ├── autoscaling/      # Auto Scaling Groups
    ├── load_balancer/    # Application Load Balancer
    ├── rds_mysql/        # MySQL RDS instances
    ├── backup_vault/     # AWS Backup
    ├── cloudtrail/       # CloudTrail logging
    └── waf/              # Web Application Firewall
```

## 🚀 Features

### ✅ Centralized Variables
- All hardcoded values extracted to `variables.tf`
- Environment-specific values in separate `.tfvars` files
- Minimal variable defaults, managed through tfvars files

### ✅ Isolated IAM Configuration
- Dedicated IAM module with all IAM resources
- Data sources for dynamic IAM role fetching
- Environment-scoped roles and policies

### ✅ Key Pair Management
- Automated EC2 key pair creation
- Private keys stored securely in S3 with encryption
- Independent key pair management for security

### ✅ Terraform Best Practices
- Layered modular directory structure
- Consistent naming conventions and tagging
- Self-contained, reusable modules
- Lifecycle rules to prevent accidental deletion

### ✅ Reusable RDS MySQL Module
- Custom parameter groups and DB subnet groups
- Multi-AZ deployment support
- Configurable backup retention and maintenance windows
- Security groups, deletion protection

### ✅ Highly Configurable Resources
- All key properties exposed as variables
- Object and map types for advanced configurations
- Environment-specific customization support
- Feature flags for component control

### ✅ Deletion Protection
- `prevent_destroy` lifecycle blocks on critical resources
- Deletion protection flags on RDS, ALB, and other critical services
- Clear documentation of protected resources

### ✅ S3 Remote Backend
- S3-only backend configuration (no DynamoDB)
- Versioning and encryption enabled
- Per-environment state isolation

## 🏃‍♂️ Usage

### Prerequisites
1. AWS CLI configured with appropriate credentials
2. Terraform >= 1.5 installed
3. S3 buckets created for Terraform state storage

### Initialize and Plan

```bash
# Initialize Terraform
terraform init

# Plan for development environment
terraform plan -var-file="envs/dev.tfvars"

# Plan for staging environment
terraform plan -var-file="envs/staging.tfvars"

# Plan for production environment
terraform plan -var-file="envs/prod.tfvars"
```

### Apply Changes

```bash
# Apply to development
terraform apply -var-file="envs/dev.tfvars"

# Apply to staging
terraform apply -var-file="envs/staging.tfvars"

# Apply to production
terraform apply -var-file="envs/prod.tfvars"
```

### Retrieve SSH Keys

```bash
# Download private key from S3
aws s3 cp s3://myapp-dev-ssh-keys/ssh-keys/myapp-dev-key-private-key.pem ./myapp-dev-key.pem
chmod 600 ./myapp-dev-key.pem

# Connect to EC2 instance
ssh -i ./myapp-dev-key.pem ec2-user@<instance-ip>
```

## 🔧 Configuration

### Environment Variables
Each environment has its own `.tfvars` file with specific configurations:

- **Development**: Minimal resources, single NAT gateway, smaller instances
- **Staging**: Production-like setup with reduced scale
- **Production**: High availability, multi-AZ, enhanced monitoring

### Feature Flags
Use the `enable_features` variable to control which components are deployed:

```hcl
enable_features = {
  vpc           = true
  ec2           = true
  autoscaling   = true
  load_balancer = true
  rds           = true
  backup        = true
  cloudtrail    = true
  waf           = true
  key_pair      = true
}
```

### Backend Configuration
Update backend configuration in each `.tfvars` file:

```hcl
backend_bucket_name = "your-terraform-state-bucket"
backend_key        = "environment/terraform.tfstate"
backend_region     = "us-west-2"
```

## 🛡️ Security

### Key Management
- Private keys are stored in encrypted S3 buckets
- Public keys are also stored for reference
- Keys are tagged and organized by environment

### IAM Best Practices
- Least privilege principle applied
- Environment-specific roles and policies
- Centralized IAM management

### Network Security
- Private subnets for application and database layers
- Security groups with minimal required access
- WAF protection for web applications

## 📊 Monitoring and Backup

### AWS Backup
- Automated daily backups
- Environment-specific retention policies
- Cold storage transition for cost optimization

### CloudTrail
- Multi-region trail for compliance
- S3 storage with encryption
- Log file validation enabled

### Monitoring
- CloudWatch metrics for all resources
- Enhanced monitoring for RDS
- Performance Insights available

## 🔄 Lifecycle Management

### Protected Resources
The following resources have `prevent_destroy` enabled:
- VPC and subnets
- RDS instances
- IAM roles and policies
- S3 buckets
- Key pairs

### Deletion Protection
Critical resources have deletion protection enabled:
- RDS instances (configurable per environment)
- Load balancers (enabled in staging/prod)
- Backup vaults

## 📝 Customization

### Adding New Environments
1. Create new `.tfvars` file in `envs/` directory
2. Configure environment-specific values
3. Update backend configuration
4. Run terraform commands with new tfvars file

### Adding New Resources
1. Create or update relevant module
2. Add variables to module's `variables.tf`
3. Update main configuration to call module
4. Add outputs if needed
5. Update environment tfvars files

### Modifying Existing Resources
1. Update module configuration
2. Add new variables if needed
3. Update tfvars files for affected environments
4. Plan and apply changes

This infrastructure provides a solid foundation for scalable, secure, and maintainable AWS deployments across multiple environments.
