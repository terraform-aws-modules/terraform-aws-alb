provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  region = "eu-west-1"
  name   = "ex-${basename(path.cwd)}"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-alb"
  }
}

##################################################################
# Network Load Balancer
##################################################################

module "nlb" {
  source = "../../"

  name = local.name

  load_balancer_type               = "network"
  vpc_id                           = module.vpc.vpc_id
  dns_record_client_routing_policy = "availability_zone_affinity"

  # https://github.com/hashicorp/terraform-provider-aws/issues/17281
  # subnets = module.vpc.private_subnets

  # Use `subnet_mapping` to attach EIPs
  subnet_mapping = [for i, eip in aws_eip.this :
    {
      allocation_id = eip.id
      subnet_id     = module.vpc.private_subnets[i]
    }
  ]

  # For example only
  enable_deletion_protection = false

  # Security Group
  enforce_security_group_inbound_rules_on_private_link_traffic = "off"
  security_group_ingress_rules = {
    all_tcp = {
      from_port   = 80
      to_port     = 84
      ip_protocol = "tcp"
      description = "TCP traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_udp = {
      from_port   = 80
      to_port     = 84
      ip_protocol = "udp"
      description = "UDP traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  access_logs = {
    bucket = module.log_bucket.s3_bucket_id
  }

  listeners = {
    ex-one = {
      port     = 81
      protocol = "TCP_UDP"
      forward = {
        target_group_key = "ex-target-one"
      }
    }

    ex-two = {
      port     = 82
      protocol = "UDP"
      forward = {
        target_group_key = "ex-target-two"
      }
    }

    ex-three = {
      port                     = 83
      protocol                 = "TCP"
      tcp_idle_timeout_seconds = 60
      forward = {
        target_group_key = "ex-target-three"
      }
    }

    ex-four = {
      port            = 84
      protocol        = "TLS"
      certificate_arn = module.acm.acm_certificate_arn
      forward = {
        target_group_key = "ex-target-four"
      }
    }
  }

  target_groups = {
    ex-target-one = {
      name_prefix            = "t1-"
      protocol               = "TCP_UDP"
      port                   = 81
      target_type            = "instance"
      target_id              = aws_instance.this.id
      connection_termination = true
      preserve_client_ip     = true

      stickiness = {
        type = "source_ip"
      }

      tags = {
        tcp_udp = true
      }
    }

    ex-target-two = {
      name_prefix = "t2-"
      protocol    = "UDP"
      port        = 82
      target_type = "instance"
      target_id   = aws_instance.this.id
    }

    ex-target-three = {
      name_prefix          = "t3-"
      protocol             = "TCP"
      port                 = 83
      target_type          = "ip"
      target_id            = aws_instance.this.private_ip
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
    }

    ex-target-four = {
      name_prefix = "t4-"
      protocol    = "TLS"
      port        = 84
      target_type = "instance"
      target_id   = aws_instance.this.id
      target_health_state = {
        enable_unhealthy_connection_termination = false
        unhealthy_draining_interval             = 600
      }
    }
  }

  tags = local.tags
}

################################################################################
# Supporting resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  tags = local.tags
}

data "aws_route53_zone" "this" {
  name = var.domain_name
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = var.domain_name
  zone_id     = data.aws_route53_zone.this.id
}

resource "aws_eip" "this" {
  count = length(local.azs)

  domain = "vpc"
}

data "aws_ssm_parameter" "al2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "this" {
  ami           = data.aws_ssm_parameter.al2.value
  instance_type = "t3.nano"
  subnet_id     = element(module.vpc.private_subnets, 0)
}

module "log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket_prefix = "${local.name}-logs-"
  acl           = "log-delivery-write"

  # For example only
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_elb_log_delivery_policy = true # Required for ALB logs
  attach_lb_log_delivery_policy  = true # Required for ALB/NLB logs

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  tags = local.tags
}
