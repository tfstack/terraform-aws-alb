# AWS Application Load Balancer (ALB) with EC2 Instances

This Terraform configuration provisions an **AWS Application Load Balancer (ALB)** along with the required **networking, security groups, and EC2 instances**. The ALB distributes traffic to EC2 instances running in private subnets.

## Features

- **VPC Setup**: Creates a VPC with public and private subnets.
- **EC2 Instances**: Deploys instances in private subnets.
- **Security Groups**: Configures security groups for ALB and instances.
- **ALB Deployment**: Provisions an ALB with target groups.
- **HTTPS Support**: Optional HTTPS listener with a provided certificate.

## Usage

### **Initialize and Apply**

```bash
terraform init
terraform plan
terraform apply
```

### **Destroy Resources**

```bash
terraform destroy
```

> **Warning:** Running this example creates AWS resources that incur costs.

## Inputs

| Name                   | Description                                        | Type     | Default              |
|------------------------|------------------------------------------------|----------|----------------------|
| `region`               | AWS region for deployment.                      | `string` | `ap-southeast-1`    |
| `enable_https`         | Enable HTTPS listener for ALB.                  | `bool`   | `false`              |
| `http_port`            | HTTP listener port.                              | `number` | `80`                 |
| `target_http_port`     | Port for target group.                           | `number` | `80`                 |
| `public_subnet_ids`    | List of public subnet IDs for ALB.               | `list(string)` | `[]`         |
| `targets`              | List of instance IDs to attach to ALB.          | `list(string)` | `[]`         |
| `target_type`          | Type of ALB target (`instance` or `ip`).        | `string` | `instance`          |

## Outputs

| Name                   | Description                                        |
|------------------------|------------------------------------------------|
| `alb_arn`              | ARN of the created ALB.                          |
| `alb_dns_name`         | DNS name of the ALB.                             |
| `target_group_arn`     | ARN of the target group.                         |
| `attached_targets`     | List of successfully attached targets.           |

## Resources Created

- **VPC** with public and private subnets
- **Internet Gateway & NAT Gateway** for routing
- **ALB with HTTP/HTTPS listeners**
- **EC2 instances in private subnets**
- **Security groups for ALB and EC2**

This configuration ensures a **highly available and secure load balancing setup** for your EC2 instances using an AWS ALB.
