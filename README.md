# AWS Application and Network Load Balancer (ALB & NLB) Terraform module

Terraform module which creates Application and Network Load Balancer resources on AWS.

## Usage

### Application Load Balancer

HTTP and HTTPS listeners with default actions:

```hcl
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "my-alb"

  load_balancer_type = "application"

  vpc_id             = "vpc-abcde012"
  subnets            = ["subnet-abcde012", "subnet-bcde012a"]
  security_groups    = ["sg-edcd9784", "sg-edcd9785"]

  access_logs = {
    bucket = "my-alb-logs"
  }

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = [
        {
          target_id = "i-0123456789abcdefg"
          port = 80
        },
        {
          target_id = "i-a1b2c3d4e5f6g7h8i"
          port = 8080
        }
      ]
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
  }
}
```

HTTP to HTTPS redirect and HTTPS cognito authentication:

```hcl
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "my-alb"

  load_balancer_type = "application"

  vpc_id             = "vpc-abcde012"
  subnets            = ["subnet-abcde012", "subnet-bcde012a"]
  security_groups    = ["sg-edcd9784", "sg-edcd9785"]

  access_logs = {
    bucket = "my-alb-logs"
  }

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTPS"
      backend_port     = 443
      target_type      = "instance"
    }
  ]

  https_listeners = [
    {
      port                 = 443
      protocol             = "HTTPS"
      certificate_arn      = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
      action_type          = "authenticate-cognito"
      target_group_index   = 0
      authenticate_cognito = {
        user_pool_arn       = "arn:aws:cognito-idp::123456789012:userpool/test-pool"
        user_pool_client_id = "6oRmFiS0JHk="
        user_pool_domain    = "test-domain-com"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  tags = {
    Environment = "Test"
  }
}
```

Cognito Authentication only on certain routes, with redirects for other routes:

```hcl
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "my-alb"

  load_balancer_type = "application"

  vpc_id             = "vpc-abcde012"
  subnets            = ["subnet-abcde012", "subnet-bcde012a"]
  security_groups    = ["sg-edcd9784", "sg-edcd9785"]

  access_logs = {
    bucket = "my-alb-logs"
  }

  target_groups = [
    {
      name_prefix      = "default"
      backend_protocol = "HTTPS"
      backend_port     = 443
      target_type      = "instance"
    }
  ]

  https_listeners = [
    {
      port                 = 443
      certificate_arn      = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
    }
  ]

  https_listener_rules = [
    {
      https_listener_index = 0
      priority             = 5000

      actions = [{
        type        = "redirect"
        status_code = "HTTP_302"
        host        = "www.youtube.com"
        path        = "/watch"
        query       = "v=dQw4w9WgXcQ"
        protocol    = "HTTPS"
      }]

      conditions = [{
        path_patterns = ["/onboarding", "/docs"]
      }]
    },
    {
      https_listener_index = 0
      priority             = 2

      actions = [
        {
          type = "authenticate-cognito"

          user_pool_arn       = "arn:aws:cognito-idp::123456789012:userpool/test-pool"
          user_pool_client_id = "6oRmFiS0JHk="
          user_pool_domain    = "test-domain-com"
        },
        {
          type               = "forward"
          target_group_index = 0
        }
      ]

      conditions = [{
        path_patterns = ["/protected-route", "private/*"]
      }]
    }
  ]
}
```

When you're using ALB Listener rules, make sure that every rule's `actions` block ends in a `forward`, `redirect`, or `fixed-response` action so that every rule will resolve to some sort of an HTTP response. Checkout the [AWS documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-update-rules.html) for more information.

### Network Load Balancer (TCP_UDP, UDP, TCP and TLS listeners)

```hcl
module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "my-nlb"

  load_balancer_type = "network"

  vpc_id  = "vpc-abcde012"
  subnets = ["subnet-abcde012", "subnet-bcde012a"]

  access_logs = {
    bucket = "my-nlb-logs"
  }

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "TCP"
      backend_port     = 80
      target_type      = "ip"
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "TLS"
      certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
  }
}
```

## Assumptions

It's recommended you use this module with [terraform-aws-vpc](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws), [terraform-aws-security-group](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws), and [terraform-aws-autoscaling](https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/).

## Notes

1. Terraform AWS provider >= v2.39.0 (via Terraform >= 0.12) has [issue #16674](https://github.com/hashicorp/terraform-provider-aws/issues/16674) related to "Provider produced inconsistent final plan". It means that S3 bucket has to be created before referencing it as an argument inside `access_logs = { bucket = "my-already-created-bucket-for-logs" }`, so this won't work: `access_logs = { bucket = module.log_bucket.s3_bucket_id }`.

## Conditional creation

Sometimes you need to have a way to create ALB resources conditionally but Terraform does not allow to use `count` inside `module` block, so the solution is to specify argument `create_lb`.

```hcl
# This LB will not be created
module "lb" {
 source = "terraform-aws-modules/alb/aws"

 create_lb = false
 # ... omitted
}
```

## Examples

- [Complete Application Load Balancer](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/examples/complete-alb)
- [Complete Network Load Balancer](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/examples/complete-nlb)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.40 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.40 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.frontend_http_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.frontend_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_certificate.https_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource |
| [aws_lb_listener_rule.http_tcp_listener_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_listener_rule.https_listener_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs"></a> [access\_logs](#input\_access\_logs) | Map containing access logging configuration for load balancer. | `map(string)` | `{}` | no |
| <a name="input_create_lb"></a> [create\_lb](#input\_create\_lb) | Controls if the Load Balancer should be created | `bool` | `true` | no |
| <a name="input_drop_invalid_header_fields"></a> [drop\_invalid\_header\_fields](#input\_drop\_invalid\_header\_fields) | Indicates whether invalid header fields are dropped in application load balancers. Defaults to false. | `bool` | `false` | no |
| <a name="input_enable_cross_zone_load_balancing"></a> [enable\_cross\_zone\_load\_balancing](#input\_enable\_cross\_zone\_load\_balancing) | Indicates whether cross zone load balancing should be enabled in application load balancers. | `bool` | `false` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false. | `bool` | `false` | no |
| <a name="input_enable_http2"></a> [enable\_http2](#input\_enable\_http2) | Indicates whether HTTP/2 is enabled in application load balancers. | `bool` | `true` | no |
| <a name="input_extra_ssl_certs"></a> [extra\_ssl\_certs](#input\_extra\_ssl\_certs) | A list of maps describing any extra SSL certificates to apply to the HTTPS listeners. Required key/values: certificate\_arn, https\_listener\_index (the index of the listener within https\_listeners which the cert applies toward). | `list(map(string))` | `[]` | no |
| <a name="input_http_tcp_listener_rules"></a> [http\_tcp\_listener\_rules](#input\_http\_tcp\_listener\_rules) | A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, http\_tcp\_listener\_index (default to http\_tcp\_listeners[count.index]) | `any` | `[]` | no |
| <a name="input_http_tcp_listener_rules_tags"></a> [http\_tcp\_listener\_rules\_tags](#input\_http\_tcp\_listener\_rules\_tags) | A map of tags to add to all http listener rules | `map(string)` | `{}` | no |
| <a name="input_http_tcp_listeners"></a> [http\_tcp\_listeners](#input\_http\_tcp\_listeners) | A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target\_group\_index (defaults to http\_tcp\_listeners[count.index]) | `any` | `[]` | no |
| <a name="input_http_tcp_listeners_tags"></a> [http\_tcp\_listeners\_tags](#input\_http\_tcp\_listeners\_tags) | A map of tags to add to all http listeners | `map(string)` | `{}` | no |
| <a name="input_https_listener_rules"></a> [https\_listener\_rules](#input\_https\_listener\_rules) | A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https\_listener\_index (default to https\_listeners[count.index]) | `any` | `[]` | no |
| <a name="input_https_listener_rules_tags"></a> [https\_listener\_rules\_tags](#input\_https\_listener\_rules\_tags) | A map of tags to add to all https listener rules | `map(string)` | `{}` | no |
| <a name="input_https_listeners"></a> [https\_listeners](#input\_https\_listeners) | A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate\_arn. Optional key/values: ssl\_policy (defaults to ELBSecurityPolicy-2016-08), target\_group\_index (defaults to https\_listeners[count.index]) | `any` | `[]` | no |
| <a name="input_https_listeners_tags"></a> [https\_listeners\_tags](#input\_https\_listeners\_tags) | A map of tags to add to all https listeners | `map(string)` | `{}` | no |
| <a name="input_idle_timeout"></a> [idle\_timeout](#input\_idle\_timeout) | The time in seconds that the connection is allowed to be idle. | `number` | `60` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | Boolean determining if the load balancer is internal or externally facing. | `bool` | `false` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack. | `string` | `"ipv4"` | no |
| <a name="input_lb_tags"></a> [lb\_tags](#input\_lb\_tags) | A map of tags to add to load balancer | `map(string)` | `{}` | no |
| <a name="input_listener_ssl_policy_default"></a> [listener\_ssl\_policy\_default](#input\_listener\_ssl\_policy\_default) | The security policy if using HTTPS externally on the load balancer. [See](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html). | `string` | `"ELBSecurityPolicy-2016-08"` | no |
| <a name="input_load_balancer_create_timeout"></a> [load\_balancer\_create\_timeout](#input\_load\_balancer\_create\_timeout) | Timeout value when creating the ALB. | `string` | `"10m"` | no |
| <a name="input_load_balancer_delete_timeout"></a> [load\_balancer\_delete\_timeout](#input\_load\_balancer\_delete\_timeout) | Timeout value when deleting the ALB. | `string` | `"10m"` | no |
| <a name="input_load_balancer_type"></a> [load\_balancer\_type](#input\_load\_balancer\_type) | The type of load balancer to create. Possible values are application or network. | `string` | `"application"` | no |
| <a name="input_load_balancer_update_timeout"></a> [load\_balancer\_update\_timeout](#input\_load\_balancer\_update\_timeout) | Timeout value when updating the ALB. | `string` | `"10m"` | no |
| <a name="input_name"></a> [name](#input\_name) | The resource name and Name tag of the load balancer. | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The resource name prefix and Name tag of the load balancer. Cannot be longer than 6 characters | `string` | `null` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | The security groups to attach to the load balancer. e.g. ["sg-edcd9784","sg-edcd9785"] | `list(string)` | `[]` | no |
| <a name="input_subnet_mapping"></a> [subnet\_mapping](#input\_subnet\_mapping) | A list of subnet mapping blocks describing subnets to attach to network load balancer | `list(map(string))` | `[]` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A list of subnets to associate with the load balancer. e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f'] | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_target_group_tags"></a> [target\_group\_tags](#input\_target\_group\_tags) | A map of tags to add to all target groups | `map(string)` | `{}` | no |
| <a name="input_target_groups"></a> [target\_groups](#input\_target\_groups) | A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend\_protocol, backend\_port | `any` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id where the load balancer and other resources will be deployed. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_http_tcp_listener_arns"></a> [http\_tcp\_listener\_arns](#output\_http\_tcp\_listener\_arns) | The ARN of the TCP and HTTP load balancer listeners created. |
| <a name="output_http_tcp_listener_ids"></a> [http\_tcp\_listener\_ids](#output\_http\_tcp\_listener\_ids) | The IDs of the TCP and HTTP load balancer listeners created. |
| <a name="output_https_listener_arns"></a> [https\_listener\_arns](#output\_https\_listener\_arns) | The ARNs of the HTTPS load balancer listeners created. |
| <a name="output_https_listener_ids"></a> [https\_listener\_ids](#output\_https\_listener\_ids) | The IDs of the load balancer listeners created. |
| <a name="output_lb_arn"></a> [lb\_arn](#output\_lb\_arn) | The ID and ARN of the load balancer we created. |
| <a name="output_lb_arn_suffix"></a> [lb\_arn\_suffix](#output\_lb\_arn\_suffix) | ARN suffix of our load balancer - can be used with CloudWatch. |
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | The DNS name of the load balancer. |
| <a name="output_lb_id"></a> [lb\_id](#output\_lb\_id) | The ID and ARN of the load balancer we created. |
| <a name="output_lb_zone_id"></a> [lb\_zone\_id](#output\_lb\_zone\_id) | The zone\_id of the load balancer to assist with creating DNS records. |
| <a name="output_target_group_arn_suffixes"></a> [target\_group\_arn\_suffixes](#output\_target\_group\_arn\_suffixes) | ARN suffixes of our target groups - can be used with CloudWatch. |
| <a name="output_target_group_arns"></a> [target\_group\_arns](#output\_target\_group\_arns) | ARNs of the target groups. Useful for passing to your Auto Scaling group. |
| <a name="output_target_group_attachments"></a> [target\_group\_attachments](#output\_target\_group\_attachments) | ARNs of the target group attachment IDs. |
| <a name="output_target_group_names"></a> [target\_group\_names](#output\_target\_group\_names) | Name of the target group. Useful for passing to your CodeDeploy Deployment Group. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Anton Babenko](https://github.com/antonbabenko) with help from [these awesome contributors](https://github.com/terraform-aws-modules/terraform-aws-alb/graphs/contributors).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/LICENSE) for full details.
