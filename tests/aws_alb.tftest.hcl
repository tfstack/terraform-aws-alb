# Run setup to create networking (VPC, subnets)
run "setup_vpc" {
  module {
    source = "./tests/setup"
  }
}

# Test HTTP ALB Configuration
run "test_alb_http_configuration" {
  variables {
    region               = "ap-southeast-1"
    vpc_id               = run.setup_vpc.vpc_id
    public_subnet_ids    = run.setup_vpc.public_subnet_ids
    name                 = "test-alb-${run.setup_vpc.suffix}"
    enable_https         = false
    http_port            = 80
    target_http_port     = 80
    targets              = run.setup_vpc.aws_instance_ids
    target_type          = "instance"
    allowed_http_cidrs   = ["0.0.0.0/0"]
    allowed_egress_cidrs = ["0.0.0.0/0"]
  }

  # Assert that ALB was created
  assert {
    condition     = aws_lb.this.id != null
    error_message = "ALB was not created."
  }

  # Assert that Security Group for ALB was created
  assert {
    condition     = length(aws_security_group.this) > 0
    error_message = "ALB Security Group was not created."
  }

  # Assert that HTTP Listener exists
  assert {
    condition     = aws_lb_listener.http.id != null
    error_message = "Expected an HTTP listener but found none."
  }

  # Assert that HTTP listener forwards to the correct Target Group
  assert {
    condition = anytrue([
      for action in aws_lb_listener.http.default_action :
      action.type == "forward" && action.target_group_arn == aws_lb_target_group.http[0].arn
    ])
    error_message = "HTTP Listener does not forward to the correct Target Group."
  }

  # Assert that HTTP Target Group was created correctly
  assert {
    condition     = length(aws_lb_target_group.http) == 1
    error_message = "Expected an HTTP Target Group but found none."
  }

  # Assert that ALB has public subnets assigned
  assert {
    condition     = length(aws_lb.this.subnets) == length(var.public_subnet_ids)
    error_message = "ALB is missing subnets in the configured region."
  }

  # Correct security group rule check
  assert {
    condition = anytrue([
      for rule in aws_security_group.this.ingress :
      rule.from_port == 80 && rule.to_port == 80 && rule.protocol == "tcp"
    ])
    error_message = "ALB Security Group does not allow HTTP traffic on port 80."
  }

  # Assert that at least one target is attached
  assert {
    condition     = length(aws_lb_target_group_attachment.generic) > 0
    error_message = "No targets are attached to the ALB Target Group."
  }
}
