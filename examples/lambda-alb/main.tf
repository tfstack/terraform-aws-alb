############################################
# Provider Configuration
############################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

############################################
# Random Suffix for Resource Names
############################################

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

############################################
# Local Variables
############################################

locals {
  azs                  = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  enable_dns_hostnames = true
  enable_https         = false

  name            = "lambda"
  base_name       = local.suffix != "" ? "${local.name}-${local.suffix}" : local.name
  suffix          = random_string.suffix.result
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  region          = "ap-southeast-2"
  vpc_cidr        = "10.0.0.0/16"
  tags = {
    Environment = "dev"
    Project     = "lambda-alb-example"
  }
}

############################################
# VPC Configuration
############################################

module "vpc" {
  source = "cloudbuildlab/vpc/aws"

  vpc_name           = local.base_name
  vpc_cidr           = local.vpc_cidr
  availability_zones = local.azs

  public_subnet_cidrs  = local.public_subnets
  private_subnet_cidrs = local.private_subnets

  # Enable Internet Gateway & NAT Gateway
  create_igw       = true
  nat_gateway_type = "single"

  tags = local.tags
}

############################################
# Lambda Function
############################################

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${local.base_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

# IAM Policy for Lambda execution
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "api" {
  filename      = "lambda_function.zip"
  function_name = "${local.base_name}-api"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.handler"
  runtime       = "nodejs20.x"
  timeout       = 30
  memory_size   = 128

  environment {
    variables = {
      ENVIRONMENT = "dev"
    }
  }

  tags = local.tags
}

# Lambda Permission for ALB
resource "aws_lambda_permission" "alb" {
  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = "arn:aws:elasticloadbalancing:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:targetgroup/lambda-${random_string.suffix.result}-http/*"
}

############################################
# AWS ALB Module
############################################

module "aws_alb" {
  source = "../.."

  name              = local.name
  suffix            = random_string.suffix.result
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids

  enable_https     = false
  http_port        = 80
  target_http_port = 80
  target_type      = "lambda"
  targets          = [aws_lambda_function.api.arn]

  # Health check configuration for Lambda (disabled)
  health_check_enabled = false

  tags = local.tags

  depends_on = [aws_lambda_permission.alb]
}

############################################
# Outputs
############################################

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.aws_alb.alb_dns
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = module.aws_alb.alb_arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.api.function_name
}

output "test_command" {
  description = "Command to test the ALB"
  value       = "curl -v http://${module.aws_alb.alb_dns}"
}

output "health_check_command" {
  description = "Command to test the health check endpoint"
  value       = "curl -v http://${module.aws_alb.alb_dns}/health"
}
