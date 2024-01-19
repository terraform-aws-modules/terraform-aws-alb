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

  script = <<EOF
#!/bin/bash

# create directory for crls
mkdir cert_files/
echo 01 > cert_files/cert_serial
echo 01 > cert_files/crl_number
touch cert_files/crl_index

# generate crl
openssl ca -gencrl -keyfile <(echo "${tls_private_key.root_ca.private_key_pem}") -cert <(echo "${tls_self_signed_cert.root_ca.cert_pem}") -out cert_files/crl.pem -config ca.conf

# revoke a client cert
openssl ca -revoke <(echo "${tls_locally_signed_cert.my_client_revoked.cert_pem}") -keyfile <(echo "${tls_private_key.root_ca.private_key_pem}") -cert <(echo "${tls_self_signed_cert.root_ca.cert_pem}") -config ca.conf

# regenerate crl after revoking a cert
openssl ca -gencrl -keyfile <(echo "${tls_private_key.root_ca.private_key_pem}") -cert <(echo "${tls_self_signed_cert.root_ca.cert_pem}") -out cert_files/crl.pem -config ca.conf

EOF
}

module "alb" {
  source = "../../"

  name    = local.name
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  # For example only
  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
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
    prefix = "access-logs"
  }

  connection_logs = {
    bucket  = module.log_bucket.s3_bucket_id
    enabled = true
    prefix  = "connection-logs"
  }

  listeners = {
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
      certificate_arn = module.acm.acm_certificate_arn
      mutual_authentication = {
        mode            = "verify"
        trust_store_arn = module.trust_store.trust_store_arn
      }

      forward = {
        target_group_key = "ex-instance"
      }

      rules = {
        ex-fixed-response = {
          priority = 3
          actions = [
            {
              type         = "fixed-response"
              content_type = "text/plain"
              status_code  = 200
              message_body = "This is a fixed response"
            }
          ]
          conditions = [{
            http_header = {
              http_header_name = "x-Gimme-Fixed-Response"
              values           = ["yes", "please", "right now"]
            }
          }]
        }
      }
    }
  }

  target_groups = {
    ex-instance = {
      name_prefix                       = "h1"
      protocol                          = "HTTP"
      port                              = 80
      target_type                       = "instance"
      deregistration_delay              = 10
      load_balancing_cross_zone_enabled = false

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

      protocol_version = "HTTP1"
      target_id        = aws_instance.this.id
      port             = 80
      tags = {
        InstanceTargetGroupTag = "baz"
      }
    }
  }

  # Route53 Record(s)
  route53_records = {
    A = {
      name    = local.name
      type    = "A"
      zone_id = data.aws_route53_zone.this.id
    }
    AAAA = {
      name    = local.name
      type    = "AAAA"
      zone_id = data.aws_route53_zone.this.id
    }
  }
}

module "trust_store" {
  source = "../../modules/lb_trust_store"

  name                             = "${local.name}-trust-store"
  ca_certificates_bundle_s3_bucket = module.certificate_bucket.s3_bucket_id
  ca_certificates_bundle_s3_key    = "ca_cert/RootCA.pem"
  create_trust_store_revocation    = true
  revocation_lists = {
    crl_1 = {
      revocations_s3_bucket = module.certificate_bucket.s3_bucket_id
      revocations_s3_key    = "crl/crl.pem"
    }
  }

  depends_on = [
    module.ca_cert_object,
    module.crl_object,
  ]
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

data "aws_route53_zone" "this" {
  name = var.domain_name
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "*.${var.domain_name}"
  zone_id     = data.aws_route53_zone.this.id
}

resource "null_resource" "generate_crl" {
  provisioner "local-exec" {
    command     = local.script
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [
    tls_locally_signed_cert.my_client_revoked
  ]
}

module "certificate_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket_prefix = "${local.name}-certificate-"
  force_destroy = true

  tags = local.tags
}

module "ca_cert_object" {
  source = "terraform-aws-modules/s3-bucket/aws//modules/object"

  bucket = module.certificate_bucket.s3_bucket_id
  key    = "ca_cert/RootCA.pem"

  content = tls_self_signed_cert.root_ca.cert_pem

  tags = local.tags
}

module "crl_object" {
  source = "terraform-aws-modules/s3-bucket/aws//modules/object"

  bucket = module.certificate_bucket.s3_bucket_id
  key    = "crl/crl.pem"

  file_source = "${path.module}/cert_files/crl.pem"

  tags = local.tags

  depends_on = [null_resource.generate_crl]
}

################################################################################
# Client/Server Certificates
################################################################################

# Root CA
resource "tls_private_key" "root_ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "root_ca" {
  private_key_pem = tls_private_key.root_ca.private_key_pem

  validity_period_hours = 43800

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]

  is_ca_certificate = true
  dns_names         = [var.domain_name, "*.${var.domain_name}"]

  subject {
    country      = "IE"
    province     = "Dublin"
    locality     = "Dublin"
    common_name  = var.domain_name
    organization = "terraform-aws-modules"
  }
}

# client cert
resource "tls_private_key" "my_client" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "my_client" {
  private_key_pem = tls_private_key.my_client.private_key_pem

  subject {
    country      = "IE"
    province     = "Dublin"
    locality     = "Dublin"
    common_name  = "my-client.${var.domain_name}"
    organization = "terraform-aws-modules"
  }
}

resource "tls_locally_signed_cert" "my_client" {
  cert_request_pem   = tls_cert_request.my_client.cert_request_pem
  ca_private_key_pem = tls_private_key.root_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root_ca.cert_pem

  validity_period_hours = 12
  set_subject_key_id    = true

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth"
  ]
}

# client cert to be revoked
resource "tls_private_key" "my_client_revoked" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "my_client_revoked" {
  private_key_pem = tls_private_key.my_client_revoked.private_key_pem

  subject {
    country      = "IE"
    province     = "Dublin"
    locality     = "Dublin"
    common_name  = "my-client-revoked.${var.domain_name}"
    organization = "terraform-aws-modules"
  }
}

resource "tls_locally_signed_cert" "my_client_revoked" {
  cert_request_pem   = tls_cert_request.my_client_revoked.cert_request_pem
  ca_private_key_pem = tls_private_key.root_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root_ca.cert_pem

  validity_period_hours = 12
  set_subject_key_id    = true

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth"
  ]
}
