# WAF Web ACL
resource "aws_wafv2_web_acl" "main" {
  name  = "${var.name_prefix}-web-acl"
  scope = var.scope

  default_action {
    allow {}
  }

  # AWS Managed Rule - Core Rule Set
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
      metric_name                = "CommonRuleSetMetric"
      sampled_requests_enabled   = var.sampled_requests_enabled
    }
  }

  # AWS Managed Rule - Known Bad Inputs
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
      metric_name                = "KnownBadInputsRuleSetMetric"
      sampled_requests_enabled   = var.sampled_requests_enabled
    }
  }

  # AWS Managed Rule - SQL Injection
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
      metric_name                = "SQLiRuleSetMetric"
      sampled_requests_enabled   = var.sampled_requests_enabled
    }
  }

  # Rate Limiting Rule
  rule {
    name     = "RateLimitRule"
    priority = 4

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = var.sampled_requests_enabled
    }
  }

  # IP Reputation Rule (if enabled)
  dynamic "rule" {
    for_each = var.enable_ip_reputation_rule ? [1] : []
    content {
      name     = "AWSManagedRulesAmazonIpReputationList"
      priority = 5

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesAmazonIpReputationList"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "IpReputationListMetric"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    }
  }

  # Custom IP Allowlist Rule (if provided)
  dynamic "rule" {
    for_each = length(var.allowed_ips) > 0 ? [1] : []
    content {
      name     = "IPAllowlistRule"
      priority = 10

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.allowed_ips[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "IPAllowlistRule"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    }
  }

  # Custom IP Blocklist Rule (if provided)
  dynamic "rule" {
    for_each = length(var.blocked_ips) > 0 ? [1] : []
    content {
      name     = "IPBlocklistRule"
      priority = 11

      action {
        block {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.blocked_ips[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "IPBlocklistRule"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
    metric_name                = "${var.name_prefix}WebAcl"
    sampled_requests_enabled   = var.sampled_requests_enabled
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-web-acl"
    }
  )
}

# IP Set for allowed IPs
resource "aws_wafv2_ip_set" "allowed_ips" {
  count = length(var.allowed_ips) > 0 ? 1 : 0

  name               = "${var.name_prefix}-allowed-ips"
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.allowed_ips

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-allowed-ips"
    }
  )
}

# IP Set for blocked IPs
resource "aws_wafv2_ip_set" "blocked_ips" {
  count = length(var.blocked_ips) > 0 ? 1 : 0

  name               = "${var.name_prefix}-blocked-ips"
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.blocked_ips

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-blocked-ips"
    }
  )
}

# Associate WAF with ALB
resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = var.resource_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

# CloudWatch Log Group for WAF logs
resource "aws_cloudwatch_log_group" "waf_logs" {
  count             = var.enable_logging ? 1 : 0
  name              = "/aws/wafv2/${var.name_prefix}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# WAF Logging Configuration
resource "aws_wafv2_web_acl_logging_configuration" "main" {
  count                   = var.enable_logging ? 1 : 0
  resource_arn            = aws_wafv2_web_acl.main.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf_logs[0].arn]

  redacted_fields {
    single_header {
      name = "authorization"
    }
  }

  redacted_fields {
    single_header {
      name = "cookie"
    }
  }
}