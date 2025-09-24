# General Configuration
variable "name" {
  description = "Base name for the ALB and related resources"
  type        = string

  validation {
    condition     = var.suffix != "" ? length("${var.name}-${var.suffix}") <= 28 : length(var.name) <= 28
    error_message = "The combined name (name + suffix) must be 28 characters or less to allow for target group suffixes (-http/-https). Current length: ${var.suffix != "" ? length("${var.name}-${var.suffix}") : length(var.name)} characters."
  }
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

# Internal Load Balancer Support
variable "internal" {
  description = "If true, the ALB will be internal (not internet-facing)"
  type        = bool
  default     = false
}

# Networking
variable "vpc_id" {
  description = "The VPC ID where the ALB will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for external ALB (when internal = false)"
  type        = list(string)
  default     = []

  validation {
    condition     = var.internal == true || (var.internal == false && length(var.public_subnet_ids) > 0)
    error_message = "public_subnet_ids must be provided when internal is false."
  }
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for internal ALB (when internal = true)"
  type        = list(string)
  default     = []

  validation {
    condition     = var.internal == false || (var.internal == true && length(var.private_subnet_ids) > 0)
    error_message = "private_subnet_ids must be provided when internal is true."
  }
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



# Enhanced Health Check Configuration
variable "health_check_enabled" {
  description = "Whether to enable health checks"
  type        = bool
  default     = true
}

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

variable "health_check_matcher" {
  description = "HTTP codes to use when checking for a successful response from a target"
  type        = string
  default     = "200"
}

variable "health_check_port" {
  description = "Port to use to connect with the target"
  type        = string
  default     = "traffic-port"
}

variable "health_check_protocol" {
  description = "Protocol to use to connect with the target"
  type        = string
  default     = "HTTP"
  validation {
    condition     = contains(["HTTP", "HTTPS", "TCP"], var.health_check_protocol)
    error_message = "Health check protocol must be one of: HTTP, HTTPS, TCP."
  }
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

# Existing Security Group Support
variable "use_existing_security_group" {
  description = "If true, use an existing security group instead of creating a new one"
  type        = bool
  default     = false
}

variable "existing_security_group_id" {
  description = "ID of existing security group to use (required if use_existing_security_group is true)"
  type        = string
  default     = ""

  validation {
    condition     = var.use_existing_security_group == false || (var.use_existing_security_group == true && var.existing_security_group_id != "")
    error_message = "You must provide a valid 'existing_security_group_id' when 'use_existing_security_group' is enabled."
  }
}

# Target Group Settings
variable "targets" {
  description = "List of targets (EC2 instance IDs, IPs, Lambda ARNs, or ALB ARNs)"
  type        = list(string)
  default     = []
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

variable "enable_availability_zone_all" {
  description = "Set availability_zone to 'all' for IP targets outside VPC"
  type        = bool
  default     = false
}
