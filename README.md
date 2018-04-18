# terraform-aws-alb

A Terraform module containing common configurations for an AWS Application Load
Balancer (ALB) running over HTTP/HTTPS. Available through the [terraform registry](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws).

| Branch | Build status |
| --- | --- |
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
exhastive set of reasons. Alternatively, if using ALB with ECS look no further than
the [hashicorp example](https://github.com/terraform-providers/terraform-provider-aws/blob/master/examples/ecs-alb).

## Resources, inputs, outputs

[Resources](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws?tab=resources), [inputs](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws?tab=inputs), and [outputs](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws?tab=outputs) documented in the terraform registry.

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

## Testing

This module has been packaged with [awspec](https://github.com/k1LoW/awspec) tests through [kitchen](https://kitchen.ci/) and [kitchen-terraform](https://newcontext-oss.github.io/kitchen-terraform/). To run them:

1. Install [rvm](https://rvm.io/rvm/install) and the ruby version specified in the [Gemfile](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/Gemfile).
2. Install bundler and the gems from our Gemfile:

    ```bash
    gem install bundler && bundle install
    ```

3. Ensure your AWS environment is configured (i.e. credentials and region) for test and set TF_VAR_region to a valid AWS region (e.g. `export TF_VAR_region=${AWS_REGION}`).
4. Test using `bundle exec kitchen test` from the root of the repo.

## Contributing

Report issues/questions/feature requests on in the [Issues](https://github.com/terraform-aws-modules/terraform-aws-alb/issues) section.

Pull requests are welcome! Ideally create a feature branch and issue for every
individual change made. These are the steps:

1. Fork the repo to a personal space or org.
2. Create your feature branch from master (`git checkout -b my-new-feature`).
3. Commit your awesome changes (`git commit -am 'Added some feature'`).
4. Push to the branch (`git push origin my-new-feature`).
5. Create a new Pull Request and tell us about your changes.

## IAM Permissions

Testing and using this repo requires a minimum set of IAM permissions. Test permissions
are listed in the [alb_test_fixture README](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/examples/alb_test_fixture/README.md).

## Change log

The [changelog](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/CHANGELOG.md) captures all important release notes.

## Authors

Created and maintained by [Brandon O'Connor](https://github.com/brandoconnor) - brandon@atscale.run.
Many thanks to [the contributers listed here](https://github.com/terraform-aws-modules/terraform-aws-alb/graphs/contributors)!

## License

MIT Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/LICENSE) for full details.
