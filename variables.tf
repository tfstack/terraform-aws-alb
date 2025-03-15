# General Configuration
variable "region" {
  description = "(Deprecated) AWS region for the provider. Defaults to ap-southeast-2 if not specified."
  type        = string
  default     = "ap-southeast-2"

  validation {
    condition     = can(regex("^([a-z]{2}-[a-z]+-\\d{1})$", var.region))
    error_message = "Invalid AWS region format. Example: 'us-east-1', 'ap-southeast-2'."
  }
}
variable "name" {
  description = "Base name for the ALB and related resources"
  type        = string
}

variable "suffix" {
  description = "Optional suffix to append to the resource name"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Networking
variable "vpc_id" {
  description = "The VPC ID where the ALB will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs where the ALB will be deployed"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs to validate IP targets"
  type        = list(string)
  default     = []
}

# ALB Listener & Ports
variable "http_port" {
  description = "The HTTP port for ALB security group"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "The HTTPS port for ALB security group"
  type        = number
  default     = 443
}

variable "target_http_port" {
  description = "The port the ALB forwards HTTP traffic to (Target Group)"
  type        = number
  default     = 80
}

variable "target_https_port" {
  description = "The port the ALB forwards HTTPS traffic to (Target Group)"
  type        = number
  default     = 443
}

# Health Check Settings
variable "health_check_path" {
  description = "The health check endpoint for ALB target group"
  type        = string
  default     = "/"
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Number of successful health checks before considering the target healthy"
  type        = number
  default     = 3
}

variable "health_check_unhealthy_threshold" {
  description = "Number of failed health checks before considering the target unhealthy"
  type        = number
  default     = 3
}

# Security & Access Control
variable "allowed_http_cidrs" {
  description = "List of CIDR blocks allowed for HTTP traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_https_cidrs" {
  description = "List of CIDR blocks allowed for HTTPS traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_egress_cidrs" {
  description = "List of CIDR blocks for outbound traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_deletion_protection" {
  description = "Enable or disable deletion protection for the ALB"
  type        = bool
  default     = false
}

variable "enable_https" {
  description = "Enable HTTPS listener (must provide a certificate ARN)"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ARN of an existing SSL certificate for HTTPS"
  type        = string
  default     = ""

  validation {
    condition     = var.enable_https == false || (var.enable_https == true && var.certificate_arn != "")
    error_message = "You must provide a valid 'certificate_arn' when 'enable_https' is enabled."
  }
}

# Target Group Settings
variable "targets" {
  description = "List of targets (EC2 instance IDs, IPs, Lambda ARNs, or ALB ARNs)"
  type        = list(string)

  validation {
    condition     = length(var.targets) > 0
    error_message = "At least one target must be specified."
  }
}

variable "target_type" {
  description = "Type of target for ALB (instance, ip, lambda, alb)"
  type        = string
  default     = "instance"

  validation {
    condition     = contains(["instance", "ip", "lambda", "alb"], var.target_type)
    error_message = "Allowed values for target_type are 'instance', 'ip', 'lambda', or 'alb'."
  }
}
