locals {
  name_prefix = "${var.environment}-${var.project_name}"
}

# IAM Users
resource "aws_iam_user" "developers" {
  count = length(var.developer_users)
  name  = var.developer_users[count.index]
  path  = "/developers/"

  tags = merge(var.tags, {
    Name = var.developer_users[count.index]
    Role = "Developer"
  })
}

resource "aws_iam_user" "devops" {
  count = length(var.devops_users)
  name  = var.devops_users[count.index]
  path  = "/devops/"

  tags = merge(var.tags, {
    Name = var.devops_users[count.index]
    Role = "DevOps"
  })
}

resource "aws_iam_user" "admin" {
  count = length(var.admin_users)
  name  = var.admin_users[count.index]
  path  = "/admin/"

  tags = merge(var.tags, {
    Name = var.admin_users[count.index]
    Role = "Admin"
  })
}

## 
resource "aws_iam_access_key" "developer_keys" {
  count = var.create_access_keys ? length(var.developer_users) : 0
  user  = aws_iam_user.developers[count.index].name
}

resource "aws_iam_access_key" "devops_keys" {
  count = var.create_access_keys ? length(var.devops_users) : 0
  user  = aws_iam_user.devops[count.index].name
}

resource "aws_iam_access_key" "admin_keys" {
  count = var.create_access_keys ? length(var.admin_users) : 0
  user  = aws_iam_user.admin[count.index].name
}


