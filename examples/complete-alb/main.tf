provider "aws" {
  region = "eu-west-1"
}

locals {
  domain_name = "terraform-aws-modules.modules.tf"
}

##################################################################
# Data sources to get VPC and subnets
##################################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

resource "random_pet" "this" {
  length = 2
}

data "aws_route53_zone" "this" {
  name = local.domain_name
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "alb-sg-${random_pet.this.id}"
  description = "Security group for example usage with ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

//module "log_bucket" {
//  source  = "terraform-aws-modules/s3-bucket/aws"
//  version = "~> 1.0"
//
//  bucket                         = "logs-${random_pet.this.id}"
//  acl                            = "log-delivery-write"
//  force_destroy                  = true
//  attach_elb_log_delivery_policy = true
//}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 2.0"

  domain_name = local.domain_name # trimsuffix(data.aws_route53_zone.this.name, ".") # Terraform >= 0.12.17
  zone_id     = data.aws_route53_zone.this.id
}

##################################################################
# Application Load Balancer
##################################################################
module "alb" {
  source = "../../"

  name = "complete-alb-${random_pet.this.id}"

  load_balancer_type = "application"

  vpc_id          = data.aws_vpc.default.id
  security_groups = [module.security_group.this_security_group_id]
  subnets         = data.aws_subnet_ids.all.ids

  //  # See notes in README (ref: https://github.com/terraform-providers/terraform-provider-aws/issues/7987)
  //  access_logs = {
  //    bucket = module.log_bucket.this_s3_bucket_id
  //  }

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.this_acm_certificate_arn
      target_group_index = 1
    },
  ]

  target_groups = [
    {
      name_prefix          = "h1"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthz"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    },
    {
      name_prefix                        = "l1-"
      target_type                        = "lambda"
      lambda_multi_value_headers_enabled = true
    },
  ]

  tags = {
    Project = "Unknown"
  }
}
