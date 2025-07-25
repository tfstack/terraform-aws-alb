# Test HTTP ALB Configuration
run "http_alb_basic" {
  command = plan

  variables {
    name                             = "test-http-alb"
    vpc_id                           = "vpc-12345678"
    public_subnet_ids                = ["subnet-12345678", "subnet-87654321"]
    enable_https                     = false
    http_port                        = 80
    target_http_port                 = 80
    targets                          = ["i-12345678", "i-87654321"]
    target_type                      = "instance"
    allowed_http_cidrs               = ["0.0.0.0/0"]
    allowed_egress_cidrs             = ["0.0.0.0/0"]
    health_check_path                = "/"
    health_check_interval            = 30
    health_check_timeout             = 5
    health_check_healthy_threshold   = 3
    health_check_unhealthy_threshold = 3
    enable_deletion_protection       = false
    internal                         = false
    tags = {
      Environment = "test"
      Project     = "alb-test"
    }
  }

  assert {
    condition     = var.name == "test-http-alb"
    error_message = "ALB name should be test-http-alb"
  }

  assert {
    condition     = var.enable_https == false
    error_message = "HTTPS should be disabled"
  }

  assert {
    condition     = var.target_type == "instance"
    error_message = "Target type should be instance"
  }

  assert {
    condition     = var.internal == false
    error_message = "ALB should be external (not internal)"
  }
}

run "https_alb_basic" {
  command = plan

  variables {
    name                             = "test-https-alb"
    vpc_id                           = "vpc-12345678"
    public_subnet_ids                = ["subnet-12345678", "subnet-87654321"]
    enable_https                     = true
    certificate_arn                  = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
    http_port                        = 80
    https_port                       = 443
    target_http_port                 = 80
    targets                          = ["i-12345678", "i-87654321"]
    target_type                      = "instance"
    allowed_http_cidrs               = ["0.0.0.0/0"]
    allowed_https_cidrs              = ["0.0.0.0/0"]
    allowed_egress_cidrs             = ["0.0.0.0/0"]
    health_check_path                = "/health"
    health_check_interval            = 30
    health_check_timeout             = 5
    health_check_healthy_threshold   = 2
    health_check_unhealthy_threshold = 2
    health_check_matcher             = "200,302"
    health_check_port                = "traffic-port"
    health_check_protocol            = "HTTP"
    enable_deletion_protection       = false
    internal                         = false
    tags = {
      Environment = "test"
      Project     = "alb-https-test"
    }
  }

  assert {
    condition     = var.enable_https == true
    error_message = "HTTPS should be enabled"
  }

  assert {
    condition     = var.certificate_arn != ""
    error_message = "Certificate ARN should be provided when HTTPS is enabled"
  }

  assert {
    condition     = var.health_check_matcher == "200,302"
    error_message = "Health check matcher should be 200,302"
  }
}

run "internal_alb_basic" {
  command = plan

  variables {
    name                             = "test-internal-alb"
    vpc_id                           = "vpc-12345678"
    public_subnet_ids                = ["subnet-12345678", "subnet-87654321"]
    enable_https                     = false
    http_port                        = 80
    target_http_port                 = 80
    targets                          = ["i-12345678", "i-87654321"]
    target_type                      = "instance"
    allowed_http_cidrs               = ["10.0.0.0/8"]
    allowed_egress_cidrs             = ["0.0.0.0/0"]
    health_check_enabled             = true
    health_check_path                = "/api/health"
    health_check_interval            = 60
    health_check_timeout             = 10
    health_check_healthy_threshold   = 2
    health_check_unhealthy_threshold = 3
    health_check_matcher             = "200"
    health_check_port                = "traffic-port"
    health_check_protocol            = "HTTP"
    enable_deletion_protection       = true
    internal                         = true
    tags = {
      Environment = "test"
      Project     = "alb-internal-test"
      Type        = "internal"
    }
  }

  assert {
    condition     = var.internal == true
    error_message = "ALB should be internal"
  }

  assert {
    condition     = var.health_check_enabled == true
    error_message = "Health check should be enabled"
  }

  assert {
    condition     = var.health_check_path == "/api/health"
    error_message = "Health check path should be /api/health"
  }
}

run "existing_security_group_alb" {
  command = plan

  variables {
    name                        = "test-existing-sg-alb"
    vpc_id                      = "vpc-12345678"
    public_subnet_ids           = ["subnet-12345678", "subnet-87654321"]
    enable_https                = false
    http_port                   = 80
    target_http_port            = 80
    targets                     = ["i-12345678", "i-87654321"]
    target_type                 = "instance"
    allowed_http_cidrs          = ["0.0.0.0/0"]
    allowed_egress_cidrs        = ["0.0.0.0/0"]
    use_existing_security_group = true
    existing_security_group_id  = "sg-12345678"
    health_check_enabled        = false
    enable_deletion_protection  = false
    internal                    = false
    tags = {
      Environment = "test"
      Project     = "alb-existing-sg-test"
    }
  }

  assert {
    condition     = var.use_existing_security_group == true
    error_message = "Should use existing security group"
  }

  assert {
    condition     = var.existing_security_group_id == "sg-12345678"
    error_message = "Existing security group ID should be sg-12345678"
  }

  assert {
    condition     = var.health_check_enabled == false
    error_message = "Health check should be disabled"
  }
}
