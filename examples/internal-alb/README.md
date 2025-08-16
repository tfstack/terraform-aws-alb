# AWS Internal Application Load Balancer (ALB)

This Terraform configuration demonstrates how to deploy an **internal AWS Application Load Balancer (ALB)** using the new private subnet support. The ALB is deployed in private subnets and is not accessible from the internet.

## Key Features

- **Internal ALB**: Deployed in private subnets with `internal = true`
- **Private Subnet Deployment**: Uses `private_subnet_ids` instead of `public_subnet_ids`
- **VPC-Only Access**: ALB is only accessible from within the VPC
- **Secure Configuration**: Restricted access to private subnet CIDRs only

## Architecture

```plaintext
Internet Gateway
       ↓
   Public Subnets (10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24)
       ↓
   NAT Gateway
       ↓
   Private Subnets (10.0.101.0/24, 10.0.102.0/24, 10.0.103.0/24)
       ↓
   Internal ALB + EC2 Instances
```

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

## Key Differences from External ALB

| Aspect | External ALB | Internal ALB |
|--------|--------------|--------------|
| **Subnet Type** | `public_subnet_ids` | `private_subnet_ids` |
| **Internet Access** | Yes | No |
| **Security Groups** | Open to internet | Restricted to VPC |
| **Use Case** | Public-facing services | Internal services, microservices |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `internal` | Set to `true` for internal ALB | `bool` | `true` |
| `private_subnet_ids` | List of private subnet IDs | `list(string)` | Required |
| `allowed_http_cidrs` | Restricted to private subnet CIDRs | `list(string)` | `["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]` |

## Outputs

| Name | Description |
|------|-------------|
| `internal_alb_dns` | DNS name of the internal ALB |
| `note` | Important note about internal ALB access |

## Security Considerations

- **No Internet Access**: The ALB cannot be reached from outside the VPC
- **Restricted Ingress**: Only traffic from private subnets is allowed
- **Private Subnets**: ALB and instances are deployed in private subnets
- **NAT Gateway**: Instances can access internet via NAT Gateway for updates

## Common Use Cases

- **Microservices Architecture**: Internal service-to-service communication
- **API Gateway**: Internal API endpoints
- **Database Load Balancing**: Distributing database connections
- **Internal Web Applications**: Admin panels, monitoring dashboards
- **Multi-tier Applications**: Load balancing between application layers
