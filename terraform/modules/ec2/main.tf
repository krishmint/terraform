# EC2 Module - main.tf
locals {
  name_prefix = "${var.environment}-${var.project_name}"
}

# Data source for Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source for existing key pair
data "aws_key_pair" "existing" {
  key_name = var.existing_key_pair_name
}

# Security Group for standalone EC2 instance
resource "aws_security_group" "ec2_standalone" {
  name_prefix = "${local.name_prefix}-ec2-standalone-"
  description = "Security group for standalone EC2 instance"
  vpc_id      = var.vpc_id

  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }

  # HTTP access (optional)
  dynamic "ingress" {
    for_each = var.enable_http_access ? [1] : []
    content {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = var.http_cidr_blocks
    }
  }

  # HTTPS access (optional)
  dynamic "ingress" {
    for_each = var.enable_https_access ? [1] : []
    content {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = var.https_cidr_blocks
    }
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-ec2-standalone-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# User data script for instance initialization
locals {
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment  = var.environment
    project_name = var.project_name
    instance_name = "${local.name_prefix}-standalone"
  }))
}

# EC2 Instance
resource "aws_instance" "standalone" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  # Use existing key pair
  key_name = data.aws_key_pair.existing.key_name

  # Network configuration
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2_standalone.id]
  associate_public_ip_address = var.associate_public_ip

  # IAM instance profile
  iam_instance_profile = var.instance_profile_name

  # User data for initialization
  user_data = local.user_data

  # EBS optimization
  ebs_optimized = true

  # Instance metadata options (IMDSv2)
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
    http_put_response_hop_limit = 2
  }

  # Monitoring
  monitoring = var.enable_detailed_monitoring

  # Root volume configuration
  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = true

    tags = merge(var.tags, {
      Name = "${local.name_prefix}-standalone-root-volume"
    })
  }

  # Additional EBS volumes
  dynamic "ebs_block_device" {
    for_each = var.additional_ebs_volumes
    content {
      device_name           = ebs_block_device.value.device_name
      volume_type           = ebs_block_device.value.volume_type
      volume_size           = ebs_block_device.value.volume_size
      delete_on_termination = ebs_block_device.value.delete_on_termination
      encrypted             = true

      tags = merge(var.tags, {
        Name = "${local.name_prefix}-standalone-${ebs_block_device.value.device_name}"
      })
    }
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-standalone"
    Type = "Standalone"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP (optional)
resource "aws_eip" "standalone" {
  count = var.create_elastic_ip ? 1 : 0

  instance = aws_instance.standalone.id
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-standalone-eip"
  })

  depends_on = [aws_instance.standalone]
}
