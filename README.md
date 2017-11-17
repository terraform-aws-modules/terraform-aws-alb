# terraform-aws-alb
A Terraform module containing common configurations for an AWS Application Load
Balancer (ALB) running over HTTP/HTTPS. Available through the [terraform registry](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws).

| Branch | Build status |
| --- | --- |
| master | [![build Status](https://travis-ci.org/terraform-aws-modules/terraform-aws-alb.svg?branch=master)](https://travis-ci.org/terraform-aws-modules/terraform-aws-alb) |

## Assumptions
* You want to create a set of resources for the ALB: namely an associated target group and listener.
* You've created a Virtual Private Cloud (VPC) + subnets where you intend to put
this ALB.
* You have one or more security groups to attach to the ALB.
* You want to configure a listener for HTTPS/HTTP
* You've uploaded an SSL certificate to AWS IAM if using HTTPS

The module supports both (mutually exclusive):
* Internal IP ALBs
* External IP ALBs

It's recommended you use this module with [terraform-aws-vpc](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws),
[terraform-aws-security-group](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws), and
[terraform-aws-autoscaling](https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/).

## Why ALB instead of ELB?
The use-case presented here appears almost identical to how one would use an ELB
but we inherit a few bonuses by moving to ALB. Those are best outlined in [AWS's
documentation](https://aws.amazon.com/elasticloadbalancing/applicationloadbalancer/).
For an example of using ALB with ECS look no further than the [hashicorp example](https://github.com/terraform-providers/terraform-provider-aws/blob/master/examples/ecs-alb).

## Resources, inputs, outputs
[Resources](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws?tab=resources), [inputs](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws?tab=inputs), and [outputs](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws?tab=outputs) documented in the terraform registry.

## Usage example
A full example leveraging other community modules is contained in the [examples/test_fixtures directory](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/examples/test_fixtures). Here's the gist of using it via the Terraform registry:
```
module "alb" {
  source                        = "terraform-aws-modules/alb/aws"
  alb_name                      = "my-alb"
  region                        = "us-east-2"
  alb_security_groups           = ["sg-edcd9784", "sg-edcd9785"]
  vpc_id                        = "vpc-abcde012"
  subnets                       = ["subnet-abcde012", "subnet-bcde012a"]
  alb_protocols                 = ["HTTPS"]
  certificate_arn               = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
  create_log_bucket             = true
  enable_logging                = true
  log_bucket_name               = "logs-us-east-2-123456789012"
  log_location_prefix           = "my-alb-logs"
  health_check_path             = "/"

  tags {
    "Terraform" = "true"
    "Env"       = "${terraform.workspace}"
  }
}
```
3. Always `terraform plan` to see your change before running `terraform apply`.
4. Win the day!

## Testing
This module has been packaged with [awspec](https://github.com/k1LoW/awspec) tests through test kitchen. To run them:
1. Install [rvm](https://rvm.io/rvm/install) and the ruby version specified in the [Gemfile](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/Gemfile).
2. Install bundler and the gems from our Gemfile:
```
gem install bundler; bundle install
```
3. Ensure your AWS environment is configured (i.e. credentials and region) for test and set TF_VAR_region to a valid AWS region (e.g. `export TF_VAR_region=${AWS_REGION}`).
4. Test using `kitchen test` from the root of the repo.

## Contributing
Report issues/questions/feature requests on in the [Issues](https://github.com/terraform-aws-modules/terraform-aws-alb/issues) section.

Pull requests are welcome! Ideally create a feature branch and issue for every
individual change made. These are the steps:

1. Fork the repo to a personal space or org.
2. Create your feature branch from master (`git checkout -b my-new-feature`).
4. Commit your awesome changes (`git commit -am 'Added some feature'`).
5. Push to the branch (`git push origin my-new-feature`).
6. Create a new Pull Request and tell us about your changes.

## IAM Permissions
Testing and using this repo requires a minimum set of IAM permissions. Test permissions
are listed in the [test_fixtures README](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/examples/test_fixtures/README.md).

## Change log
The [changelog](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/CHANGELOG.md) captures all important release notes.

## Authors
Created and maintained by [Brandon O'Connor](https://github.com/brandoconnor) - brandon@atscale.run.
Many thanks to [the contributers listed here](https://github.com/terraform-aws-modules/terraform-aws-alb/graphs/contributors)!

## License
MIT Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/LICENSE) for full details.
