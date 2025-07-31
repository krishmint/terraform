# EC2 Instance
resource "aws_instance" "main" {
  for_each                    = var.ec2_configs

  ami                         = each.value.ami_id
  instance_type               = each.value.instance_type
  key_name                    = each.value.key_name
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = each.value.vpc_security_group_ids
  iam_instance_profile        = each.value.iam_instance_profile
  associate_public_ip_address = var.associate_public_ip_address
  monitoring                  = var.enable_detailed_monitoring

  root_block_device {
    volume_type               = each.value.root_volume_type
    volume_size               = each.value.root_volume_size
    encrypted                 = each.value.root_volume_encrypted
    delete_on_termination     = false

    tags = merge(
      var.tags,
      {
        Name = "{each.value.name_prefix}-root-volume"
      }
    )
  }

  user_data = var.user_data

  lifecycle {
    prevent_destroy = false
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
    prevent_destroy = false
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-eip"
    }
  )
}
