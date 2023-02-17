provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-alb"
    GithubOrg  = "terraform-aws-modules"
  }
}

##################################################################
# Network Load Balancer
##################################################################

module "nlb" {
  source = "../../"

  name = local.name

  load_balancer_type = "network"
  vpc_id             = module.vpc.vpc_id

  # Use `subnets` if you don't want to attach EIPs
  # subnets = module.vpc.private_subnets

  # Use `subnet_mapping` to attach EIPs
  subnet_mapping = [for i, eip in aws_eip.this : { allocation_id : eip.id, subnet_id : module.vpc.private_subnets[i] }]

  # # See notes in README (ref: https://github.com/terraform-providers/terraform-provider-aws/issues/7987)
  # access_logs = {
  #   bucket = module.log_bucket.s3_bucket_id
  # }

  # TCP_UDP, UDP, TCP
  http_tcp_listeners = [
    {
      port               = 81
      protocol           = "TCP_UDP"
      target_group_index = 0
    },
    {
      port               = 82
      protocol           = "UDP"
      target_group_index = 1
    },
    {
      port               = 83
      protocol           = "TCP"
      target_group_index = 2
    },
  ]

  #  TLS
  https_listeners = [
    {
      port               = 84
      protocol           = "TLS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 3
    },
  ]

  target_groups = [
    {
      name_prefix            = "tu1-"
      backend_protocol       = "TCP_UDP"
      backend_port           = 81
      target_type            = "instance"
      connection_termination = true
      preserve_client_ip     = true
      stickiness = {
        enabled = true
        type    = "source_ip"
      }
      tags = {
        tcp_udp = true
      }
    },
    {
      name_prefix      = "u1-"
      backend_protocol = "UDP"
      backend_port     = 82
      target_type      = "instance"
    },
    {
      name_prefix          = "t1-"
      backend_protocol     = "TCP"
      backend_port         = 83
      target_type          = "ip"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthz"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
      }
    },
    {
      name_prefix      = "t2-"
      backend_protocol = "TLS"
      backend_port     = 84
      target_type      = "instance"
    },
  ]

  tags = local.tags
}

################################################################################
# Supporting resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = local.tags
}

data "aws_route53_zone" "this" {
  name = var.domain_name
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = var.domain_name
  zone_id     = data.aws_route53_zone.this.id
}

resource "aws_eip" "this" {
  count = length(local.azs)
  vpc   = true
}
