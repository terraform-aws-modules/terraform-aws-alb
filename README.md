# tf_aws_alb
A Terraform module containing common configurations for an AWS Application Load
Balancer (ALB) running over HTTP/HTTPS.

## Assumptions
* *You want to associate the ASG with a target group and ALB*
* You've created a Virtual Private Cloud (VPC) + subnets where you intend to put
this ALB and backing instances.
* You can fully bootstrap your instances using an AMI + user_data.
* You want to configure a listener for HTTPS
* You've uploaded an SSL certificate to AWS/IAM

The module supports both (mutually exclusive):
* Internal IP ALBs
* External IP ALBs

It's recommended you use this module with
[sg_https_only](https://github.com/terraform-community-modules/tf_aws_sg/tree/master/sg_https_only#sg_https_only-terraform-module) and [tf_aws_asg_elb](https://github.com/terraform-community-modules/tf_aws_asg_elb)

## Why ALB instad of ELB?
Admittedly, the use-case appears almost identical to how one would use an ELB
BUT we inherit a few bonuses by moving to ALB. Those are best outlined in [AWS's
documentation](https://aws.amazon.com/elasticloadbalancing/applicationloadbalancer/).
For an example of using ALB with ECS look no further than the [hashicorp example](https://github.com/terraform-providers/terraform-provider-aws/blob/master/examples/ecs-alb).

## Input Variables
* `alb_is_internal` - Determines if the ALB is externally facing or internal. (Optional; default: false)
* `alb_name` - Name of the ALB as it appears in the AWS console. (Optional; default: my-alb)
* `alb_protocols` - A comma delimited list of protocols the ALB will accept for incoming connections. Only HTTP and HTTPS are supported. (Optional; default: HTTPS)
* `alb_security_groups` - A comma delimited list of security groups to attach to the ALB. (Required)
* `aws_region` - Region to deploy our resources. (Required)
* `backend_port` - Port on which the backing instances serve traffic. (Optional; default: 80)
* `backend_protocol` - Protocol the backing instances use. (Optional; default: HTTP)
* `certificate_arn` - . (Required if using HTTPS in `alb_protocols`)
* `cookie_duration` - If sticky sessions via cookies are desired, set this variable to a value from 2 - 604800 seconds. (Optional)
* `health_check_path` - Path for the load balancer to health check instances. (Optional; default: /)
* `log_bucket` - S3 bucket where access logs should land. If not set it will be not leave logs. (Optional; default: "")
* `log_prefix` - S3 prefix within the `log_bucket` where logs should land. (Optional; default: "")
* `security_policy` - The security policy if using HTTPS externally on the ALB. See [AWS docs](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html).
* `subnets` - ALB will be created in the subnets in this list. (Required)
* `vpc_id` - Resources will be created in the VPC with this `id`. (Required)
* `tags` - A mapping of tags to assign to the resource.

## Outputs
* `alb_id` - `id` of the ALB created.
* `alb_dns_name` - DNS CNAME of the ALB created.
* `alb_zone_id` - Route53 `zone_id` of the newly minted ALB.
* `target_group_arn` - `arn` of the target group. Useful for passing to your Auto Scaling group module.
* `principal_account_id` - the id of the AWS root user within this region. See [docs here]('http://docs.aws.amazon.com/elasticloadbalancing/latest/classic/enable-access-logs.html#attach-bucket-policy').

## Usage example:
A full example leveraging other community modules is contained in the [examples/test_fixtures directory](examples/test_fixtures). Here's the gist of using it via the Terraform registry:
```
module "alb" {
  source              = "terraform-aws-modules/alb/aws"
  alb_security_groups = "${var.alb_security_groups}"
  certificate_arn     = "${var.certificate_arn}"
  log_bucket          = "${var.log_bucket}"
  log_prefix          = "${var.log_prefix}"
  subnets             = "${var.public_subnets}"
  vpc_id              = "${var.vpc_id}"

  tags {
    "Terraform" = "true"
    "Env"       = "${terraform.workspace}"
  }
}
```
3. Always `terraform plan` to see your change before running `terraform apply`.
4. Win the day!

## Testing
This module has been packaged with [awspec]('https://github.com/k1LoW/awspec') tests through test kitchen. To run them:
1. Install the prerequisites of rvm and ruby 2.4.0 via homebrew.
2. Install bundler and the gems from our Gemfile:
```
gem install bundler; bundle install
```
3. Configure variables in `test/fixtures/terraform.tfvars`. An example of how this should look is in [terraform.tfvars.example](test/fixtures/terraform.tfvars.example).
4. Test using `kitchen test` from the root of the repo.

## Contributing
Report issues/questions/feature requests on in the [Issues](https://github.com/terraform-aws-modules/terraform-aws-alb/issues) section.

Pull requests are welcome! Ideally create a feature branch and issue for every
individual change you make. These are the steps:

1. Fork the repo to a personal space or org.
2. Create your feature branch from master (`git checkout -b my-new-feature`).
4. Commit your awesome changes (`git commit -am 'Added some feature'`).
5. Push to the branch (`git push origin my-new-feature`).
6. Create a new Pull Request and tell us about your changes.

## Change log
The [changelog](CHANGELOG.md) captures all important release notes.

## Authors
Created and maintained by [Brandon O'Connor](https://github.com/brandoconnor) - brandon@atscale.run.

## License
MIT Licensed. See [LICENSE](LICENSE) for full details.
