# EC2 Instance
resource "aws_instance" "main" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = var.associate_public_ip_address
  monitoring                  = var.enable_detailed_monitoring

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    encrypted             = var.root_volume_encrypted
    delete_on_termination = true

    tags = merge(
      var.tags,
      {
        Name = "${var.name_prefix}-root-volume"
      }
    )
  }

  user_data = var.user_data

  lifecycle {
    prevent_destroy = true
    ignore_changes = [ami]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-ec2"
    }
  )
}

# Elastic IP (optional)
resource "aws_eip" "main" {
  count = var.create_eip ? 1 : 0

  instance = aws_instance.main.id
  domain   = "vpc"

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-eip"
    }
  )
}