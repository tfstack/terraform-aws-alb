# AWS Application Load Balancer (ALB) with Lambda Function

This Terraform configuration demonstrates how to use the **AWS ALB module** with **Lambda functions** as targets. This is a serverless approach that provides automatic scaling and cost efficiency.

## 🚀 Features

- **Serverless Architecture**: Lambda functions as ALB targets
- **Automatic Scaling**: Lambda scales automatically based on demand
- **Health Checks**: ALB health checks for Lambda function
- **Multiple Endpoints**: Different API endpoints handled by single Lambda
- **Cost Effective**: Pay only for actual usage
- **Simple Deployment**: No server management required

## 📋 Prerequisites

- AWS CLI configured
- Terraform installed
- Node.js (for Lambda function development)

## 🛠️ Usage

### 1. Package Lambda Function

```bash
# Make the package script executable
chmod +x package.sh

# Package the Lambda function
./package.sh
```

### 2. Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### 3. Test the Application

After deployment, you can test the endpoints:

```bash
# Get the ALB DNS name
ALB_DNS=$(terraform output -raw alb_dns_name)

# Test the main endpoint
curl http://$ALB_DNS

# Test health check
curl http://$ALB_DNS/health

# Test API endpoints
curl http://$ALB_DNS/api/hello
curl http://$ALB_DNS/api/info
```

### 4. Clean Up

```bash
# Destroy all resources
terraform destroy
```

## 🏗️ Architecture

```plaintext
Internet → ALB → Lambda Function
                ↓
            VPC with Public Subnets
```

## 📊 Resources Created

- **VPC** with public and private subnets
- **Internet Gateway & NAT Gateway** for routing
- **Application Load Balancer** with HTTP listener
- **Lambda Function** with IAM role and permissions
- **Target Group** configured for Lambda targets
- **Security Groups** for ALB access

## 🔧 Configuration

### Lambda Function

- **Runtime**: Node.js 20.x
- **Memory**: 128 MB
- **Timeout**: 30 seconds
- **Handler**: `index.handler`

### ALB Configuration

- **Protocol**: HTTP (port 80)
- **Target Type**: Lambda
- **Health Check**: `/health` endpoint
- **Health Check Interval**: 30 seconds
- **Healthy Threshold**: 2
- **Unhealthy Threshold**: 2

## 🌐 API Endpoints

| Endpoint | Description | Response |
|----------|-------------|----------|
| `/` | Welcome page with API info | JSON with available endpoints |
| `/health` | Health check endpoint | Status and timestamp |
| `/api/hello` | Hello endpoint | Greeting message |
| `/api/info` | Service information | Version and environment details |

## 💡 Benefits

1. **Serverless**: No server management required
2. **Scalable**: Automatic scaling based on demand
3. **Cost Effective**: Pay only for actual usage
4. **Simple**: Single Lambda handles multiple endpoints
5. **Reliable**: ALB provides high availability
6. **Secure**: IAM roles and security groups

## 🔍 Monitoring

- **CloudWatch Logs**: Lambda function logs
- **ALB Metrics**: Request count, latency, error rates
- **Lambda Metrics**: Invocation count, duration, errors

## ⚠️ Important Notes

- Lambda functions have a maximum execution time of 15 minutes
- ALB has a maximum idle timeout of 4000 seconds
- Lambda cold starts may affect initial response times
- Consider using Lambda Provisioned Concurrency for consistent performance

## 🎯 Use Cases

- **API Gateway Alternative**: Simple REST APIs
- **Microservices**: Lightweight service endpoints
- **Web Applications**: Serverless web apps
- **Backend Services**: API backends for mobile/web apps
- **Event Processing**: Real-time data processing

This example showcases how to effectively use the ALB module with serverless Lambda functions, providing a modern, scalable, and cost-effective solution for web applications and APIs.
