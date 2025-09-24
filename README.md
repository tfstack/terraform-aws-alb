# terraform-aws-alb

Terraform module for deploying and managing an AWS Application Load Balancer (ALB) with enhanced features including internal load balancer support, configurable health checks, and flexible security group management.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.generic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_lb_target_group_attachment.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_egress_cidrs"></a> [allowed\_egress\_cidrs](#input\_allowed\_egress\_cidrs) | List of CIDR blocks for outbound traffic | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_allowed_http_cidrs"></a> [allowed\_http\_cidrs](#input\_allowed\_http\_cidrs) | List of CIDR blocks allowed for HTTP traffic | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_allowed_https_cidrs"></a> [allowed\_https\_cidrs](#input\_allowed\_https\_cidrs) | List of CIDR blocks allowed for HTTPS traffic | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ARN of an existing SSL certificate for HTTPS | `string` | `""` | no |
| <a name="input_enable_availability_zone_all"></a> [enable\_availability\_zone\_all](#input\_enable\_availability\_zone\_all) | Set availability\_zone to 'all' for IP targets outside VPC | `bool` | `false` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | Enable or disable deletion protection for the ALB | `bool` | `false` | no |
| <a name="input_enable_https"></a> [enable\_https](#input\_enable\_https) | Enable HTTPS listener (must provide a certificate ARN) | `bool` | `false` | no |
| <a name="input_existing_security_group_id"></a> [existing\_security\_group\_id](#input\_existing\_security\_group\_id) | ID of existing security group to use (required if use\_existing\_security\_group is true) | `string` | `""` | no |
| <a name="input_health_check_enabled"></a> [health\_check\_enabled](#input\_health\_check\_enabled) | Whether to enable health checks | `bool` | `true` | no |
| <a name="input_health_check_healthy_threshold"></a> [health\_check\_healthy\_threshold](#input\_health\_check\_healthy\_threshold) | Number of successful health checks before considering the target healthy | `number` | `3` | no |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | Health check interval in seconds | `number` | `30` | no |
| <a name="input_health_check_matcher"></a> [health\_check\_matcher](#input\_health\_check\_matcher) | HTTP codes to use when checking for a successful response from a target | `string` | `"200"` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | The health check endpoint for ALB target group | `string` | `"/"` | no |
| <a name="input_health_check_port"></a> [health\_check\_port](#input\_health\_check\_port) | Port to use to connect with the target | `string` | `"traffic-port"` | no |
| <a name="input_health_check_protocol"></a> [health\_check\_protocol](#input\_health\_check\_protocol) | Protocol to use to connect with the target | `string` | `"HTTP"` | no |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | Health check timeout in seconds | `number` | `5` | no |
| <a name="input_health_check_unhealthy_threshold"></a> [health\_check\_unhealthy\_threshold](#input\_health\_check\_unhealthy\_threshold) | Number of failed health checks before considering the target unhealthy | `number` | `3` | no |
| <a name="input_http_port"></a> [http\_port](#input\_http\_port) | The HTTP port for ALB security group | `number` | `80` | no |
| <a name="input_https_port"></a> [https\_port](#input\_https\_port) | The HTTPS port for ALB security group | `number` | `443` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | If true, the ALB will be internal (not internet-facing) | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name for the ALB and related resources | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of private subnet IDs for internal ALB (when internal = true) | `list(string)` | `[]` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | List of public subnet IDs for external ALB (when internal = false) | `list(string)` | `[]` | no |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | Optional suffix to append to the resource name | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_target_http_port"></a> [target\_http\_port](#input\_target\_http\_port) | The port the ALB forwards HTTP traffic to (Target Group) | `number` | `80` | no |
| <a name="input_target_type"></a> [target\_type](#input\_target\_type) | Type of target for ALB (instance, ip, lambda, alb) | `string` | `"instance"` | no |
| <a name="input_targets"></a> [targets](#input\_targets) | List of targets (EC2 instance IDs, IPs, Lambda ARNs, or ALB ARNs) | `list(string)` | `[]` | no |
| <a name="input_use_existing_security_group"></a> [use\_existing\_security\_group](#input\_use\_existing\_security\_group) | If true, use an existing security group instead of creating a new one | `bool` | `false` | no |
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
| <a name="output_alb_zone_id"></a> [alb\_zone\_id](#output\_alb\_zone\_id) | The canonical hosted zone ID of the ALB (to be used in a Route 53 Alias record) |
| <a name="output_attached_targets"></a> [attached\_targets](#output\_attached\_targets) | List of targets successfully attached to the target group |
| <a name="output_http_target_group_arn"></a> [http\_target\_group\_arn](#output\_http\_target\_group\_arn) | The ARN of the HTTP target group (only when HTTPS is disabled) |
| <a name="output_http_target_group_name"></a> [http\_target\_group\_name](#output\_http\_target\_group\_name) | The name of the HTTP target group (only when HTTPS is disabled) |
| <a name="output_https_target_group_arn"></a> [https\_target\_group\_arn](#output\_https\_target\_group\_arn) | The ARN of the HTTPS target group |
| <a name="output_https_target_group_name"></a> [https\_target\_group\_name](#output\_https\_target\_group\_name) | The name of the HTTPS target group |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | The ARN of the target group (HTTP or HTTPS based on configuration) |
<!-- END_TF_DOCS -->
