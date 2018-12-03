/**
* # terraform-aws-alb

* A Terraform module containing common configurations for an AWS Application Load
Balancer (ALB) running over HTTP/HTTPS. Available through the [Terraform registry](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws).

* | Branch | Build status                                                                                                                                                      |
* | ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
* | master | [![build Status](https://travis-ci.org/terraform-aws-modules/terraform-aws-alb.svg?branch=master)](https://travis-ci.org/terraform-aws-modules/terraform-aws-alb) |

* ## Assumptions

** You want to create a set of resources around an application load balancer: namely associated target groups and listeners.
** You've created a Virtual Private Cloud (VPC) and subnets where you intend to put this ALB.
** You have one or more security groups to attach to the ALB.
** Additionally, if you plan to use an HTTPS listener, the ARN of an SSL certificate is required.

* The module supports both (mutually exclusive):

** Internal ALBs
** External ALBs

* It's recommended you use this module with [terraform-aws-vpc](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws),
* [terraform-aws-security-group](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws), and
* [terraform-aws-autoscaling](https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/).

* Note:

* It's strongly recommended that the autoscaling module is instantiated in the same
* state as the ALB module as in flight changes to active target groups need to be propagated
* to the ASG immediately or will result in failure. The value of `target_group[n][name]` also must change any time there are modifications to existing `target_groups`.

* ## Why ALB instead of ELB

* ALB has the ability to replace what several ELBs can do by routing based on URI matchers.
* Additionally, operating at layer 7 opens the ability to shape traffic using WAF.
* [AWS's documentation](https://aws.amazon.com/elasticloadbalancing/applicationloadbalancer/) has a more
* exhaustive set of reasons. Alternatively, if using ALB with ECS look no further than
* the [HashiCorp example](https://github.com/terraform-providers/terraform-provider-aws/blob/master/examples/ecs-alb).

* ## Usage example

* A full example leveraging other community modules is contained in the [examples/alb_test_fixture directory](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/examples/alb_test_fixture). Here's the gist of using it via the Terraform registry:

* ```hcl
* module "alb" {
*   source                        = "terraform-aws-modules/alb/aws"
*   load_balancer_name            = "my-alb"
*   security_groups               = ["sg-edcd9784", "sg-edcd9785"]
*   log_bucket_name               = "logs-us-east-2-123456789012"
*   log_location_prefix           = "my-alb-logs"
*   subnets                       = ["subnet-abcde012", "subnet-bcde012a"]
*   tags                          = "${map("Environment", "test")}"
*   vpc_id                        = "vpc-abcde012"
*   https_listeners               = "${list(map("certificate_arn", "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012", "port", 443))}"
*   https_listeners_count         = "1"
*   http_tcp_listeners            = "${list(map("port", "80", "protocol", "HTTP"))}"
*   http_tcp_listeners_count      = "1"
*   target_groups                 = "${list(map("name", "foo", "backend_protocol", "HTTP", "backend_port", "80"))}"
*   target_groups_count           = "1"
* }
* ```

* ## Testing

* This module has been packaged with [awspec](https://github.com/k1LoW/awspec) tests through [kitchen](https://kitchen.ci/) and [kitchen-terraform](https://newcontext-oss.github.io/kitchen-terraform/). To run them:

* 1. Install [rvm](https://rvm.io/rvm/install) and the ruby version specified in the [Gemfile](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/Gemfile).
* 2. Install bundler and the gems from our Gemfile:
*
*     ```bash
*     gem install bundler && bundle install
*     ```
*
* 3. Ensure your AWS environment is configured (i.e. credentials and region) for test and set TF_VAR_region to a valid AWS region (e.g. `export TF_VAR_region=${AWS_REGION}`).
* 4. Test using `bundle exec kitchen test` from the root of the repo.

* ## Doc generation

* Documentation should be modified within `main.tf` and generated using [terraform-docs](https://github.com/segmentio/terraform-docs).
* Generate them like so:

* ```bash
* terraform-docs md ./ | cat -s | sed '${/^$/d;}' > README.md
* ```

* ## Contributing

* Report issues/questions/feature requests on in the [issues](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/new) section.

* Full contributing [guidelines are covered here](https://github.com/terraform-aws-modules/terraform-aws-alb/blob/master/CONTRIBUTING.md).

* ## IAM Permissions

* Testing and using this repo requires a minimum set of IAM permissions. Test permissions
* are listed in the [alb_test_fixture README](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/examples/alb_test_fixture/README.md).

* ## Change log

* The [changelog](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/CHANGELOG.md) captures all important release notes.

* ## Authors

* Created and maintained by [Brandon O'Connor](https://github.com/brandoconnor) - brandon@atscale.run.
* Many thanks to [the contributors listed here](https://github.com/terraform-aws-modules/terraform-aws-alb/graphs/contributors)!

* ## License

* MIT Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/LICENSE) for full details.
*/

