locals {
  base_name = var.suffix != "" ? "${var.name}-${var.suffix}" : var.name
}

############################################
# Application Load Balancer
############################################

resource "aws_lb" "this" {
  name                       = local.base_name
  internal                   = var.internal
  load_balancer_type         = "application"
  security_groups            = var.use_existing_security_group ? [var.existing_security_group_id] : [aws_security_group.this[0].id]
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.tags, { Name = local.base_name })
}

############################################
# Security Group
############################################

resource "aws_security_group" "this" {
  count = var.use_existing_security_group ? 0 : 1

  name_prefix = local.base_name
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_http_cidrs
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_https_cidrs
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.allowed_egress_cidrs
  }

  tags = merge(var.tags, { Name = local.base_name })
}

############################################
# Target Groups
############################################

# HTTP Target Group (Only created if HTTPS is disabled)
resource "aws_lb_target_group" "http" {
  count = var.enable_https ? 0 : 1

  name        = "${local.base_name}-http"
  port        = var.target_type == "lambda" ? null : var.target_http_port
  protocol    = var.target_type == "lambda" ? "HTTP" : "HTTP"
  target_type = var.target_type
  vpc_id      = var.target_type == "lambda" ? null : var.vpc_id

  dynamic "health_check" {
    for_each = var.target_type == "lambda" ? [] : (var.health_check_enabled ? [1] : [])
    content {
      enabled             = var.health_check_enabled
      path                = var.health_check_path
      interval            = var.health_check_interval
      timeout             = var.health_check_timeout
      healthy_threshold   = var.health_check_healthy_threshold
      unhealthy_threshold = var.health_check_unhealthy_threshold
      matcher             = var.health_check_matcher
      port                = var.health_check_port
      protocol            = var.health_check_protocol
    }
  }

  tags = merge(var.tags, { Name = "${local.base_name}-http" })
}

# HTTPS Target Group (Only created if HTTPS is enabled)
resource "aws_lb_target_group" "https" {
  count       = var.enable_https ? 1 : 0
  name        = "${local.base_name}-https"
  port        = var.target_type == "lambda" ? null : var.target_http_port
  protocol    = var.target_type == "lambda" ? "HTTP" : "HTTPS"
  target_type = var.target_type
  vpc_id      = var.target_type == "lambda" ? null : var.vpc_id

  dynamic "health_check" {
    for_each = var.target_type == "lambda" ? [] : (var.health_check_enabled ? [1] : [])
    content {
      enabled             = var.health_check_enabled
      path                = var.health_check_path
      interval            = var.health_check_interval
      timeout             = var.health_check_timeout
      healthy_threshold   = var.health_check_healthy_threshold
      unhealthy_threshold = var.health_check_unhealthy_threshold
      matcher             = var.health_check_matcher
      port                = var.health_check_port
      protocol            = var.health_check_protocol
    }
  }

  tags = merge(var.tags, { Name = "${local.base_name}-https" })
}

############################################
# Listeners and Rules
############################################

# HTTP Listener (Redirects HTTP to HTTPS if enabled)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.http_port
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = var.enable_https ? [1] : []
    content {
      type = "redirect"
      redirect {
        protocol    = "HTTPS"
        port        = tostring(var.https_port)
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = var.enable_https ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.http[0].arn
    }
  }

  depends_on = [
    aws_lb_target_group.http
  ]
}

# HTTPS Listener (Only created if HTTPS is enabled)
resource "aws_lb_listener" "https" {
  count             = var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = var.https_port
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.https[0].arn
      }
    }
  }

  depends_on = [
    aws_lb_target_group.https
  ]
}

############################################
# Target Group Attachments
############################################

resource "aws_lb_target_group_attachment" "generic" {
  count = var.target_type == "lambda" ? 0 : length(var.targets)

  target_group_arn = var.enable_https ? aws_lb_target_group.https[0].arn : aws_lb_target_group.http[0].arn
  target_id        = var.targets[count.index]

  # Ensure port is only applied for instance and IP targets
  port = contains(["instance", "ip"], var.target_type) ? var.target_http_port : null

  # Ensure availability zone is applied only for IP targets outside VPC
  availability_zone = var.enable_availability_zone_all ? "all" : null
}

# Lambda target group attachment (only for Lambda targets)
resource "aws_lb_target_group_attachment" "lambda" {
  count = var.target_type == "lambda" ? length(var.targets) : 0

  target_group_arn = var.enable_https ? aws_lb_target_group.https[0].arn : aws_lb_target_group.http[0].arn
  target_id        = var.targets[count.index]
}
