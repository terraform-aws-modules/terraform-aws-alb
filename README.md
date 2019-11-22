# AWS Application and Network Load Balancer (ALB & NLB) Terraform module

Terraform module which creates Application and Network Load Balancer resources on AWS.

These types of resources are supported:

* [Load Balancer](https://www.terraform.io/docs/providers/aws/r/lb.html)
* [Load Balancer Listener](https://www.terraform.io/docs/providers/aws/r/lb_listener.html)
* [Load Balancer Listener Certificate](https://www.terraform.io/docs/providers/aws/r/lb_listener_certificate.html)
* [Target Group](https://www.terraform.io/docs/providers/aws/r/lb_target_group.html)

Not supported (yet):

* [Load Balancer Listener default actions](https://www.terraform.io/docs/providers/aws/r/lb_listener.html) - only `forward` is supported
* [Load Balancer Listener Rule](https://www.terraform.io/docs/providers/aws/r/lb_listener_rule.html)
* [Target Group Attachment](https://www.terraform.io/docs/providers/aws/r/lb_listener_rule.html)

## Terraform versions

Terraform 0.12. Pin module version to `~> v5.0`. Submit pull-requests to `master` branch.

Terraform 0.11. Pin module version to `~> v3.0`. Submit pull-requests to `terraform011` branch.

## Usage

### Application Load Balancer (HTTP and HTTPS listeners)

```hcl
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"
  
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
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
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

### Network Load Balancer (TCP_UDP, UDP, TCP and TLS listeners)

```hcl
module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"
  
  name = "my-nlb"

  load_balancer_type = "network"

  vpc_id  = "vpc-abcde012"
  subnets = ["subnet-abcde012", "subnet-bcde012a"]
  
  access_logs = {
    bucket = "my-nlb-logs"
  }

  target_groups = [
    {
      name_prefix      = "default"
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

1. Terraform AWS provider v2.39.0 (via Terraform 0.12) has [issue #7987](https://github.com/terraform-providers/terraform-provider-aws/issues/7987) related to "Provider produced inconsistent final plan". It means that S3 bucket has to be created before referencing it as an argument inside `access_logs = { bucket = "my-already-created-bucket-for-logs" }`, so this won't work: `access_logs = { bucket = module.log_bucket.this_s3_bucket_id }`.

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

* [Complete Application Load Balancer](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/examples/complete-alb)
* [Complete Network Load Balancer](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/examples/complete-nlb)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| access\_logs | Map containing access logging configuration for load balancer. | map(string) | `{}` | no |
| create\_lb | Controls if the Load Balancer should be created | bool | `"true"` | no |
| enable\_cross\_zone\_load\_balancing | Indicates whether cross zone load balancing should be enabled in application load balancers. | bool | `"false"` | no |
| enable\_deletion\_protection | If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false. | bool | `"false"` | no |
| enable\_http2 | Indicates whether HTTP/2 is enabled in application load balancers. | bool | `"true"` | no |
| extra\_ssl\_certs | A list of maps describing any extra SSL certificates to apply to the HTTPS listeners. Required key/values: certificate_arn, https_listener_index (the index of the listener within https_listeners which the cert applies toward). | list(map(string)) | `[]` | no |
| http\_tcp\_listeners | A list of maps describing the HTTP listeners for this ALB. Required key/values: port, protocol. Optional key/values: target_group_index (defaults to 0) | list(map(string)) | `[]` | no |
| https\_listeners | A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate_arn. Optional key/values: ssl_policy (defaults to ELBSecurityPolicy-2016-08), target_group_index (defaults to 0) | list(map(string)) | `[]` | no |
| idle\_timeout | The time in seconds that the connection is allowed to be idle. | number | `"60"` | no |
| internal | Boolean determining if the load balancer is internal or externally facing. | bool | `"false"` | no |
| ip\_address\_type | The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack. | string | `"ipv4"` | no |
| listener\_ssl\_policy\_default | The security policy if using HTTPS externally on the load balancer. [See](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html). | string | `"ELBSecurityPolicy-2016-08"` | no |
| load\_balancer\_create\_timeout | Timeout value when creating the ALB. | string | `"10m"` | no |
| load\_balancer\_delete\_timeout | Timeout value when deleting the ALB. | string | `"10m"` | no |
| load\_balancer\_type | The type of load balancer to create. Possible values are application or network. | string | `"application"` | no |
| load\_balancer\_update\_timeout | Timeout value when updating the ALB. | string | `"10m"` | no |
| log\_location\_prefix | S3 prefix within the log_bucket_name under which logs are stored. | string | `""` | no |
| name | The resource name and Name tag of the load balancer. | string | `"null"` | no |
| name\_prefix | The resource name prefix and Name tag of the load balancer. | string | `"null"` | no |
| security\_groups | The security groups to attach to the load balancer. e.g. ["sg-edcd9784","sg-edcd9785"] | list(string) | `[]` | no |
| subnet\_mapping | A list of subnet mapping blocks describing subnets to attach to network load balancer | list(map(string)) | `[]` | no |
| subnets | A list of subnets to associate with the load balancer. e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f'] | list(string) | `"null"` | no |
| tags | A map of tags to add to all resources | map(string) | `{}` | no |
| target\_groups | A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend_protocol, backend_port. Optional key/values are in the target_groups_defaults variable. | any | `[]` | no |
| vpc\_id | VPC id where the load balancer and other resources will be deployed. | string | `"null"` | no |

## Outputs

| Name | Description |
|------|-------------|
| http\_tcp\_listener\_arns | The ARN of the TCP and HTTP load balancer listeners created. |
| http\_tcp\_listener\_ids | The IDs of the TCP and HTTP load balancer listeners created. |
| https\_listener\_arns | The ARNs of the HTTPS load balancer listeners created. |
| https\_listener\_ids | The IDs of the load balancer listeners created. |
| target\_group\_arn\_suffixes | ARN suffixes of our target groups - can be used with CloudWatch. |
| target\_group\_arns | ARNs of the target groups. Useful for passing to your Auto Scaling group. |
| target\_group\_names | Name of the target group. Useful for passing to your CodeDeploy Deployment Group. |
| this\_lb\_arn | The ID and ARN of the load balancer we created. |
| this\_lb\_arn\_suffix | ARN suffix of our load balancer - can be used with CloudWatch. |
| this\_lb\_dns\_name | The DNS name of the load balancer. |
| this\_lb\_id | The ID and ARN of the load balancer we created. |
| this\_lb\_zone\_id | The zone_id of the load balancer to assist with creating DNS records. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module managed by [Anton Babenko](https://github.com/antonbabenko). Originally created and maintained by [Brandon O'Connor](https://github.com/brandoconnor) - brandon@atscale.run.
Many thanks to [the contributors listed here](https://github.com/terraform-aws-modules/terraform-aws-alb/graphs/contributors)!

## License

Apache 2 Licensed. See LICENSE for full details.
