# terraform-aws-alb

A Terraform module containing common configurations for an AWS Application Load
Balancer (ALB) running over HTTP/HTTPS. Available through the [terraform registry](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws).

| Branch | Build status                                                                                                                                                      |
| ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| master | [![build Status](https://travis-ci.org/terraform-aws-modules/terraform-aws-alb.svg?branch=master)](https://travis-ci.org/terraform-aws-modules/terraform-aws-alb) |

## Assumptions

* You want to create a set of resources around an application load balancer: namely associated target groups and listeners.
* You've created a Virtual Private Cloud (VPC) and subnets where you intend to put this ALB.
* You have one or more security groups to attach to the ALB.
* Additionally, if you plan to use an HTTPS listener, the ARN of an SSL certificate is required.

The module supports both (mutually exclusive):

* Internal ALBs
* External ALBs

It's recommended you use this module with [terraform-aws-vpc](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws),
[terraform-aws-security-group](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws), and
[terraform-aws-autoscaling](https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/).

Note:

It's strongly recommended that the autoscaling module is instantiated in the same
state as the ALB module as in flight changes to active target groups need to be propagated
to the ASG immediately or will result in failure. The value of `target_group[n][name]` also must change any time there are modifications to existing `target_groups`.

## Why ALB instead of ELB

The use-case presented here appears almost identical to how one would use an ELB
but we inherit a few bonuses by moving to ALB like the ability to leverage WAF.
[AWS's documentation](https://aws.amazon.com/elasticloadbalancing/applicationloadbalancer/) has a more
exhaustive set of reasons. Alternatively, if using ALB with ECS look no further than
the [Hashicorp example](https://github.com/terraform-providers/terraform-provider-aws/blob/master/examples/ecs-alb).

## Usage example

A full example leveraging other community modules is contained in the [examples/alb_test_fixture directory](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/examples/alb_test_fixture). Here's the gist of using it via the Terraform registry:

```hcl
module "alb" {
  source                        = "terraform-aws-modules/alb/aws"
  load_balancer_name            = "my-alb"
  security_groups               = ["sg-edcd9784", "sg-edcd9785"]
  log_bucket_name               = "logs-us-east-2-123456789012"
  log_location_prefix           = "my-alb-logs"
  subnets                       = ["subnet-abcde012", "subnet-bcde012a"]
  tags                          = "${map("Environment", "test")}"
  vpc_id                        = "vpc-abcde012"
  https_listeners               = "${list(map("certificate_arn", "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012", "port", 443))}"
  https_listeners_count         = "1"
  http_tcp_listeners            = "${list(map("port", "80", "protocol", "HTTP"))}"
  http_tcp_listeners_count      = "1"
  target_groups                 = "${list(map("name", "foo", "backend_protocol", "HTTP", "backend_port", "80"))}"
  target_groups_count           = "1"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| enable_deletion_protection | If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false. | string | `false` | no |
| enable_http2 | Indicates whether HTTP/2 is enabled in application load balancers. | string | `true` | no |
| extra_ssl_certs | A list of maps describing any extra SSL certificates to apply to the HTTPS listeners. Required key/values: certificate_arn, https_listener_index (the index of the listener within https_listeners which the cert applies toward). | list | `<list>` | no |
| extra_ssl_certs_count | A manually provided count/length of the extra_ssl_certs list of maps since the list cannot be computed. | string | `0` | no |
| http_tcp_listeners | A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, protocol. Optional key/values: target_group_index (defaults to 0) | list | `<list>` | no |
| http_tcp_listeners_count | A manually provided count/length of the http_tcp_listeners list of maps since the list cannot be computed. | string | `0` | no |
| https_listeners | A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate_arn. Optional key/values: ssl_policy (defaults to ELBSecurityPolicy-2016-08), target_group_index (defaults to 0) | list | `<list>` | no |
| https_listeners_count | A manually provided count/length of the https_listeners list of maps since the list cannot be computed. | string | `0` | no |
| idle_timeout | The time in seconds that the connection is allowed to be idle. | string | `60` | no |
| ip_address_type | The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack. | string | `ipv4` | no |
| listener_ssl_policy_default | The security policy if using HTTPS externally on the load balancer. See: https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html | string | `ELBSecurityPolicy-2016-08` | no |
| load_balancer_create_timeout | Timeout value when creating the ALB. | string | `10m` | no |
| load_balancer_delete_timeout | Timeout value when deleting the ALB. | string | `10m` | no |
| load_balancer_is_internal | Boolean determining if the load balancer is internal or externally facing. | string | `false` | no |
| load_balancer_name | The resource name and Name tag of the load balancer. | string | - | yes |
| load_balancer_update_timeout | Timeout value when updating the ALB. | string | `10m` | no |
| log_bucket_name | S3 bucket (externally created) for storing load balancer access logs. | string | - | yes |
| log_location_prefix | S3 prefix within the log_bucket_name under which logs are stored. | string | `` | no |
| security_groups | The security groups to attach to the load balancer. e.g. ["sg-edcd9784","sg-edcd9785"] | list | - | yes |
| subnets | A list of subnets to associate with the load balancer. e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f'] | list | - | yes |
| tags | A map of tags to add to all resources | string | `<map>` | no |
| target_groups | A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend_protocol, backend_port. Optional key/values are in the target_groups_defaults variable. | list | `<list>` | no |
| target_groups_count | A manually provided count/length of the target_groups list of maps since the list cannot be computed. | string | `0` | no |
| target_groups_defaults | Default values for target groups as defined by the list of maps. | map | `<map>` | no |
| vpc_id | VPC id where the load balancer and other resources will be deployed. | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| dns_name | The DNS name of the load balancer. |
| http_tcp_listener_arns | The ARN of the TCP and HTTP load balancer listeners created. |
| http_tcp_listener_ids | The IDs of the TCP and HTTP load balancer listeners created. |
| https_listener_arns | The ARNs of the HTTPS load balancer listeners created. |
| https_listener_ids | The IDs of the load balancer listeners created. |
| load_balancer_arn_suffix | ARN suffix of our load balancer - can be used with CloudWatch. |
| load_balancer_id | The ID and ARN of the load balancer we created. |
| load_balancer_zone_id | The zone_id of the load balancer to assist with creating DNS records. |
| target_group_arn_suffixes | ARN suffixes of our target groups - can be used with CloudWatch. |
| target_group_arns | ARNs of the target groups. Useful for passing to your Auto Scaling group. |
| target_group_names | Name of the target group. Useful for passing to your CodeDeploy Deployment Group. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Testing

This module has been packaged with [awspec](https://github.com/k1LoW/awspec) tests through [kitchen](https://kitchen.ci/) and [kitchen-terraform](https://newcontext-oss.github.io/kitchen-terraform/). To run them:

1.  Install [rvm](https://rvm.io/rvm/install) and the ruby version specified in the [Gemfile](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/Gemfile).
2.  Install bundler and the gems from our Gemfile:

    ```bash
    gem install bundler && bundle install
    ```

3.  Ensure your AWS environment is configured (i.e. credentials and region) for test and set TF_VAR_region to a valid AWS region (e.g. `export TF_VAR_region=${AWS_REGION}`).
4.  Test using `bundle exec kitchen test` from the root of the repo.

## Contributing

Report issues/questions/feature requests on in the [issues](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/new) section.

Full contributing [guidelines are covered here](https://github.com/terraform-aws-modules/terraform-aws-alb/blob/master/CONTRIBUTING.md).

## IAM Permissions

Testing and using this repo requires a minimum set of IAM permissions. Test permissions
are listed in the [alb_test_fixture README](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/examples/alb_test_fixture/README.md).

## Change log

The [changelog](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/CHANGELOG.md) captures all important release notes.

## Authors

Created and maintained by [Brandon O'Connor](https://github.com/brandoconnor) - brandon@atscale.run.
Many thanks to [the contributors listed here](https://github.com/terraform-aws-modules/terraform-aws-alb/graphs/contributors)!

## License

MIT Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/LICENSE) for full details.
