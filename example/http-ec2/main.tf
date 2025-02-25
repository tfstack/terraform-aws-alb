terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

# Fetch AWS Region & Availability Zones
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

data "http" "my_public_ip" {
  url = "http://ifconfig.me/ip"
}

# Generate Random Suffix
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

locals {
  azs                  = slice(data.aws_availability_zones.available.names, 0, 3)
  enable_dns_hostnames = true
  enable_https         = false
  name                 = "albtest"
  base_name            = local.suffix != "" ? "${local.name}-${local.suffix}" : local.name
  suffix               = random_string.suffix.result
  private_subnets      = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  region               = data.aws_region.current.name
  vpc_cidr             = "10.0.0.0/16"
  tags = {
    Environment = "dev"
    Project     = "example"
  }
}

############################################
# AWS VPC Module
############################################

module "aws_vpc" {
  source = "tfstack/vpc/aws"

  region             = local.region
  vpc_name           = local.base_name
  vpc_cidr           = local.vpc_cidr
  availability_zones = local.azs

  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  # Enable Internet Gateway & NAT Gateway
  # A single NAT gateway is used instead of multiple for cost efficiency.
  create_igw = true
  ngw_type   = "single"

  # eic_subnet               = "private"
  jumphost_ingress_cidrs   = ["${data.http.my_public_ip.response_body}/32"]
  jumphost_instance_create = false

  tags = local.tags
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
  name   = "${local.base_name}-web"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [module.aws_alb.alb_security_group_id]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = local.private_subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${local.base_name}-web" })
}

resource "aws_instance" "web" {
  count = length(module.aws_vpc.private_subnet_ids)

  ami           = data.aws_ami.amzn2023.id
  instance_type = "t3.micro"
  subnet_id     = module.aws_vpc.private_subnet_ids[count.index]

  vpc_security_group_ids = [
    # module.aws_vpc.eic_security_group_id,
    aws_security_group.web.id
  ]

  user_data_base64 = base64encode(file("${path.module}/external/cloud-init.yaml"))

  tags = merge(local.tags, { Name = "${local.base_name}-web-${count.index}" })
}

############################################
# AWS ALB Module
############################################

module "aws_alb" {
  source = "../.."

  name              = local.name
  suffix            = local.suffix
  region            = "ap-southeast-1"
  vpc_id            = module.aws_vpc.vpc_id
  public_subnet_ids = module.aws_vpc.public_subnet_ids

  enable_https        = local.enable_https
  http_port           = 80
  target_http_port    = 80
  targets             = aws_instance.web[*].id
  target_type         = "instance"
  public_subnet_cidrs = module.aws_vpc.public_subnet_cidrs
}

# Outputs
output "all_module_outputs" {
  description = "All outputs from the ALB module"
  value       = module.aws_alb
}
