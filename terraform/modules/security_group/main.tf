# Security Groups
resource "aws_security_group" "main" {
  for_each = var.rules

  name_prefix = "${var.name_prefix}-${each.key}-"
  description = each.value.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = each.value.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = each.value.egress_rules
    content {
      description = egress.value.description
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  lifecycle {
    prevent_destroy = false
    create_before_destroy = false
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-${each.key}-sg"
    }
  )
}
