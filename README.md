# terraform-aws-alb

Terraform module for deploying and managing an AWS Application Load Balancer (ALB)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.84.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.84.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.http](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.https](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.generic](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/lb_target_group_attachment) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/security_group) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_egress_cidrs"></a> [allowed\_egress\_cidrs](#input\_allowed\_egress\_cidrs) | List of CIDR blocks for outbound traffic | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_allowed_http_cidrs"></a> [allowed\_http\_cidrs](#input\_allowed\_http\_cidrs) | List of CIDR blocks allowed for HTTP traffic | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_allowed_https_cidrs"></a> [allowed\_https\_cidrs](#input\_allowed\_https\_cidrs) | List of CIDR blocks allowed for HTTPS traffic | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ARN of an existing SSL certificate for HTTPS | `string` | `""` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | Enable or disable deletion protection for the ALB | `bool` | `false` | no |
| <a name="input_enable_https"></a> [enable\_https](#input\_enable\_https) | Enable HTTPS listener (must provide a certificate ARN) | `bool` | `false` | no |
| <a name="input_health_check_healthy_threshold"></a> [health\_check\_healthy\_threshold](#input\_health\_check\_healthy\_threshold) | Number of successful health checks before considering the target healthy | `number` | `3` | no |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | Health check interval in seconds | `number` | `30` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | The health check endpoint for ALB target group | `string` | `"/"` | no |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | Health check timeout in seconds | `number` | `5` | no |
| <a name="input_health_check_unhealthy_threshold"></a> [health\_check\_unhealthy\_threshold](#input\_health\_check\_unhealthy\_threshold) | Number of failed health checks before considering the target unhealthy | `number` | `3` | no |
| <a name="input_http_port"></a> [http\_port](#input\_http\_port) | The HTTP port for ALB security group | `number` | `80` | no |
| <a name="input_https_port"></a> [https\_port](#input\_https\_port) | The HTTPS port for ALB security group | `number` | `443` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name for the ALB and related resources | `string` | n/a | yes |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | List of public subnet CIDRs to validate IP targets | `list(string)` | `[]` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | List of public subnet IDs where the ALB will be deployed | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region for the provider. Defaults to ap-southeast-2 if not specified. | `string` | `"ap-southeast-2"` | no |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | Optional suffix to append to the resource name | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_target_http_port"></a> [target\_http\_port](#input\_target\_http\_port) | The port the ALB forwards HTTP traffic to (Target Group) | `number` | `80` | no |
| <a name="input_target_https_port"></a> [target\_https\_port](#input\_target\_https\_port) | The port the ALB forwards HTTPS traffic to (Target Group) | `number` | `443` | no |
| <a name="input_target_type"></a> [target\_type](#input\_target\_type) | Type of target for ALB (instance, ip, lambda, alb) | `string` | `"instance"` | no |
| <a name="input_targets"></a> [targets](#input\_targets) | List of targets (EC2 instance IDs, IPs, Lambda ARNs, or ALB ARNs) | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID where the ALB will be deployed | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | The ARN of the ALB |
| <a name="output_alb_dns"></a> [alb\_dns](#output\_alb\_dns) | The DNS name of the ALB |
| <a name="output_alb_http_listener_arn"></a> [alb\_http\_listener\_arn](#output\_alb\_http\_listener\_arn) | The ARN of the ALB HTTP listener |
| <a name="output_alb_https_listener_arn"></a> [alb\_https\_listener\_arn](#output\_alb\_https\_listener\_arn) | The ARN of the ALB HTTPS listener |
| <a name="output_alb_security_group_id"></a> [alb\_security\_group\_id](#output\_alb\_security\_group\_id) | The security group ID assigned to the ALB |
| <a name="output_alb_target_health_command"></a> [alb\_target\_health\_command](#output\_alb\_target\_health\_command) | Command to check the ALB target group health |
| <a name="output_alb_test_command"></a> [alb\_test\_command](#output\_alb\_test\_command) | Command to test the ALB's HTTP response |
| <a name="output_attached_targets"></a> [attached\_targets](#output\_attached\_targets) | List of targets successfully attached to the target group |
| <a name="output_http_target_group_arn"></a> [http\_target\_group\_arn](#output\_http\_target\_group\_arn) | The ARN of the HTTP target group (only when HTTPS is disabled) |
| <a name="output_https_target_group_arn"></a> [https\_target\_group\_arn](#output\_https\_target\_group\_arn) | The ARN of the HTTPS target group |
