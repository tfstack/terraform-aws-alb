############################################
# Outputs for AWS ALB Module
############################################

# ALB ARN
output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.this.arn
}

# ALB DNS Name (Used to access the load balancer)
output "alb_dns" {
  description = "The DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

# ALB Zone ID (for Route53 alias records)
output "alb_zone_id" {
  description = "The canonical hosted zone ID of the ALB (to be used in a Route 53 Alias record)"
  value       = aws_lb.this.zone_id
}

# ALB Security Group
output "alb_security_group_id" {
  description = "The security group ID assigned to the ALB"
  value       = var.use_existing_security_group ? var.existing_security_group_id : aws_security_group.this[0].id
}

# ALB HTTP Listener ARN
output "alb_http_listener_arn" {
  description = "The ARN of the ALB HTTP listener"
  value       = aws_lb_listener.http.arn
}

# ALB HTTPS Listener ARN (Only if HTTPS is enabled)
output "alb_https_listener_arn" {
  description = "The ARN of the ALB HTTPS listener"
  value       = var.enable_https ? aws_lb_listener.https[0].arn : null
}

# HTTP Target Group ARN (Only if HTTPS is disabled)
output "http_target_group_arn" {
  description = "The ARN of the HTTP target group (only when HTTPS is disabled)"
  value       = length(aws_lb_target_group.http) > 0 ? aws_lb_target_group.http[0].arn : null
}

# HTTPS Target Group ARN
output "https_target_group_arn" {
  description = "The ARN of the HTTPS target group"
  value       = var.enable_https ? aws_lb_target_group.https[0].arn : null
}

# HTTP Target Group Name (Only if HTTPS is disabled)
output "http_target_group_name" {
  description = "The name of the HTTP target group (only when HTTPS is disabled)"
  value       = length(aws_lb_target_group.http) > 0 ? aws_lb_target_group.http[0].name : null
}

# HTTPS Target Group Name
output "https_target_group_name" {
  description = "The name of the HTTPS target group"
  value       = var.enable_https ? aws_lb_target_group.https[0].name : null
}

output "alb_test_command" {
  description = "Command to test the ALB's HTTP response"
  value       = "curl -v http://${aws_lb.this.dns_name}"
}

output "alb_target_health_command" {
  description = "Command to check the ALB target group health"
  value       = "aws elbv2 describe-target-health --target-group-arn ${length(aws_lb_target_group.http) > 0 ? aws_lb_target_group.http[0].arn : aws_lb_target_group.https[0].arn}"
}

output "attached_targets" {
  description = "List of targets successfully attached to the target group"
  value       = try(aws_lb_target_group_attachment.generic[*].target_id, [])
}

# Target Group ARN (Generic)
output "target_group_arn" {
  description = "The ARN of the target group (HTTP or HTTPS based on configuration)"
  value       = var.enable_https ? aws_lb_target_group.https[0].arn : aws_lb_target_group.http[0].arn
}
