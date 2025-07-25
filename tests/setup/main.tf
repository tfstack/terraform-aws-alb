terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

data "aws_availability_zones" "available" {}

# Generate a random suffix for resource naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

module "aws_vpc" {
  source = "tfstack/vpc/aws"

  vpc_name           = "test-alb-${random_string.suffix.result}"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets    = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  # Enable Internet Gateway & NAT Gateway
  create_igw = true
  ngw_type   = "single"

  jumphost_instance_create = false

  tags = { Name = "test-alb-${random_string.suffix.result}" }
}

data "aws_ami" "amzn2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_security_group" "web" {
  vpc_id = module.aws_vpc.vpc_id
  name   = "test-alb-${random_string.suffix.result}-web"

  # ingress {
  #   from_port       = 80
  #   to_port         = 80
  #   protocol        = "tcp"
  #   security_groups = [module.aws_alb.alb_security_group_id]
  # }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "test-alb-${random_string.suffix.result}-web" }
}

resource "aws_instance" "web" {
  count = length(module.aws_vpc.private_subnet_ids)

  ami           = data.aws_ami.amzn2023.id
  instance_type = "t3.micro"
  subnet_id     = module.aws_vpc.private_subnet_ids[count.index]

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  user_data_base64 = base64encode(file("${path.module}/external/cloud-init.yaml"))

  tags = { Name = "test-alb-${random_string.suffix.result}-web-${count.index}" }
}

output "suffix" {
  value = random_string.suffix.result
}

output "vpc_id" {
  value = module.aws_vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.aws_vpc.public_subnet_ids
}

output "aws_instance_ids" {
  value = aws_instance.web[*].id
}
