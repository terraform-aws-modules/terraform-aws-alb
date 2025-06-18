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
# Application Load Balancer
##################################################################

module "alb" {
  source = "../../"

  name    = local.name
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  # For example only
  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 82
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 445
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

  ipam_pools = {
    ipv4_ipam_pool_id = aws_vpc_ipam_pool.this.id
  }

  minimum_load_balancer_capacity = {
    capacity_units = 10
  }

  client_keep_alive = 7200

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }

      rules = {
        ex-fixed-response = {
          priority = 3
          actions = [{
            type         = "fixed-response"
            content_type = "text/plain"
            status_code  = 200
            message_body = "This is a fixed response"
          }]

          conditions = [{
            http_header = {
              http_header_name = "x-Gimme-Fixed-Response"
              values           = ["yes", "please", "right now"]
            }
          }]
        }

        ex-weighted-forward = {
          priority = 4
          actions = [{
            type = "weighted-forward"
            target_groups = [
              {
                target_group_key = "ex-lambda-with-trigger"
                weight           = 2
              },
              {
                target_group_key = "ex-instance"
                weight           = 1
              }
            ]
            stickiness = {
              enabled  = true
              duration = 3600
            }
          }]

          conditions = [{
            query_string = {
              key   = "weighted"
              value = "true"
            }
          }]
        }

        ex-redirect = {
          priority = 5000
          actions = [{
            type        = "redirect"
            status_code = "HTTP_302"
            host        = "www.youtube.com"
            path        = "/watch"
            query       = "v=dQw4w9WgXcQ"
            protocol    = "HTTPS"
          }]

          conditions = [{
            query_string = [{
              key   = "video"
              value = "random"
              },
              {
                key   = "image"
                value = "next"
            }]
          }]
        }
      }
    }

    ex-http-weighted-target = {
      port     = 81
      protocol = "HTTP"
      weighted_forward = {
        target_groups = [
          {
            target_group_key = "ex-lambda-with-trigger"
            weight           = 60
          },
          {
            target_group_key = "ex-instance"
            weight           = 40
          }
        ]
      }
    }

    ex-fixed-response = {
      port     = 82
      protocol = "HTTP"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed message"
        status_code  = "200"
      }
    }

    ex-https = {
      port                        = 443
      protocol                    = "HTTPS"
      ssl_policy                  = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
      certificate_arn             = module.acm.acm_certificate_arn
      additional_certificate_arns = [module.wildcard_cert.acm_certificate_arn]

      forward = {
        target_group_key = "ex-instance"
      }

      rules = {
        ex-cognito = {
          actions = [
            {
              type                       = "authenticate-cognito"
              on_unauthenticated_request = "authenticate"
              session_cookie_name        = "session-${local.name}"
              session_timeout            = 3600
              user_pool_arn              = aws_cognito_user_pool.this.arn
              user_pool_client_id        = aws_cognito_user_pool_client.this.id
              user_pool_domain           = aws_cognito_user_pool_domain.this.domain
            },
            {
              type             = "forward"
              target_group_key = "ex-instance"
            }
          ]

          conditions = [{
            path_pattern = {
              values = ["/some/auth/required/route"]
            }
          }]
        }

        ex-fixed-response = {
          priority = 3
          actions = [{
            type         = "fixed-response"
            content_type = "text/plain"
            status_code  = 200
            message_body = "This is a fixed response"
          }]

          conditions = [{
            http_header = {
              http_header_name = "x-Gimme-Fixed-Response"
              values           = ["yes", "please", "right now"]
            }
          }]
        }

        ex-weighted-forward = {
          priority = 4
          actions = [{
            type = "weighted-forward"
            target_groups = [
              {
                target_group_key = "ex-instance"
                weight           = 2
              },
              {
                target_group_key = "ex-lambda-with-trigger"
                weight           = 1
              }
            ]
            stickiness = {
              enabled  = true
              duration = 3600
            }
          }]

          conditions = [{
            query_string = {
              key   = "weighted"
              value = "true"
            },
            path_pattern = {
              values = ["/some/path"]
            }
          }]
        }

        ex-redirect = {
          priority = 5000
          actions = [{
            type        = "redirect"
            status_code = "HTTP_302"
            host        = "www.youtube.com"
            path        = "/watch"
            query       = "v=dQw4w9WgXcQ"
            protocol    = "HTTPS"
          }]

          conditions = [{
            query_string = {
              key   = "video"
              value = "random"
            }
          }]
        }
      }
    }

    ex-cognito = {
      port            = 444
      protocol        = "HTTPS"
      certificate_arn = module.acm.acm_certificate_arn

      authenticate_cognito = {
        authentication_request_extra_params = {
          display = "page"
          prompt  = "login"
        }
        on_unauthenticated_request = "authenticate"
        session_cookie_name        = "session-${local.name}"
        session_timeout            = 3600
        user_pool_arn              = aws_cognito_user_pool.this.arn
        user_pool_client_id        = aws_cognito_user_pool_client.this.id
        user_pool_domain           = aws_cognito_user_pool_domain.this.domain
      }

      forward = {
        target_group_key = "ex-instance"
      }

      rules = {
        ex-oidc = {
          priority = 2

          actions = [
            {
              type = "authenticate-oidc"
              authentication_request_extra_params = {
                display = "page"
                prompt  = "login"
              }
              authorization_endpoint = "https://${var.domain_name}/auth"
              client_id              = "client_id"
              client_secret          = "client_secret"
              issuer                 = "https://${var.domain_name}"
              token_endpoint         = "https://${var.domain_name}/token"
              user_info_endpoint     = "https://${var.domain_name}/user_info"
            },
            {
              type             = "forward"
              target_group_key = "ex-lambda-with-trigger"
            }
          ]

          conditions = [{
            host_header = {
              values = ["foobar.com"]
            }
          }]
        }
      }
    }

    ex-oidc = {
      port            = 445
      protocol        = "HTTPS"
      certificate_arn = module.acm.acm_certificate_arn
      action_type     = "authenticate-oidc"
      authenticate_oidc = {
        authentication_request_extra_params = {
          display = "page"
          prompt  = "login"
        }
        authorization_endpoint = "https://${var.domain_name}/auth"
        client_id              = "client_id"
        client_secret          = "client_secret"
        issuer                 = "https://${var.domain_name}"
        token_endpoint         = "https://${var.domain_name}/token"
        user_info_endpoint     = "https://${var.domain_name}/user_info"
      }

      forward = {
        target_group_key = "ex-instance"
      }
    }

    ex-response-headers = {
      port            = "443"
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
      certificate_arn = module.acm.acm_certificate_arn

      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed message"
        status_code  = "200"
      }

      routing_http_response_server_enabled                                = false
      routing_http_response_strict_transport_security_header_value        = "max-age=31536000; includeSubDomains; preload"
      routing_http_response_access_control_allow_origin_header_value      = "https://example.com"
      routing_http_response_access_control_allow_methods_header_value     = "TRACE,GET"
      routing_http_response_access_control_allow_headers_header_value     = "Accept-Language,Content-Language"
      routing_http_response_access_control_allow_credentials_header_value = "true"
      routing_http_response_access_control_expose_headers_header_value    = "Cache-Control"
      routing_http_response_access_control_max_age_header_value           = 86400
      routing_http_response_content_security_policy_header_value          = "*"
      routing_http_response_x_content_type_options_header_value           = "nosniff"
      routing_http_response_x_frame_options_header_value                  = "SAMEORIGIN"
    }

    ex-request-headers = {
      port            = "443"
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
      certificate_arn = module.acm.acm_certificate_arn

      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed message"
        status_code  = "200"
      }

      routing_http_request_x_amzn_tls_version_header_name                   = "X-Amzn-Tls-Version-Custom"
      routing_http_request_x_amzn_tls_cipher_suite_header_name              = "X-Amzn-Tls-Cipher-Suite-Custom"
      routing_http_request_x_amzn_mtls_clientcert_header_name               = "X-Amzn-Mtls-Clientcert-Custom"
      routing_http_request_x_amzn_mtls_clientcert_serial_number_header_name = "X-Amzn-Mtls-Clientcert-Serial-Number-Custom"
      routing_http_request_x_amzn_mtls_clientcert_issuer_header_name        = "X-Amzn-Mtls-Clientcert-Issuer-Custom"
      routing_http_request_x_amzn_mtls_clientcert_subject_header_name       = "X-Amzn-Mtls-Clientcert-Subject-Custom"
      routing_http_request_x_amzn_mtls_clientcert_validity_header_name      = "X-Amzn-Mtls-Clientcert-Validity-Custom"
      routing_http_request_x_amzn_mtls_clientcert_leaf_header_name          = "X-Amzn-Mtls-Clientcert-Leaf-Custom"
    }
  }

  target_groups = {
    ex-instance = {
      name_prefix                       = "h1"
      protocol                          = "HTTP"
      port                              = 80
      target_type                       = "instance"
      deregistration_delay              = 10
      load_balancing_algorithm_type     = "weighted_random"
      load_balancing_anomaly_mitigation = "on"
      load_balancing_cross_zone_enabled = false

      target_group_health = {
        dns_failover = {
          minimum_healthy_targets_count = 2
        }
        unhealthy_state_routing = {
          minimum_healthy_targets_percentage = 50
        }
      }

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

    ex-lambda-with-trigger = {
      name_prefix                        = "l1-"
      target_type                        = "lambda"
      lambda_multi_value_headers_enabled = true
      target_id                          = module.lambda_with_allowed_triggers.lambda_function_arn
    }

    ex-lambda-without-trigger = {
      name_prefix              = "l2-"
      target_type              = "lambda"
      target_id                = module.lambda_without_allowed_triggers.lambda_function_arn
      attach_lambda_permission = true
    }
  }

  additional_target_group_attachments = {
    ex-instance-other = {
      target_group_key = "ex-instance"
      target_type      = "instance"
      target_id        = aws_instance.other.id
      port             = "80"
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

  tags = local.tags
}

module "alb_disabled" {
  source = "../../"

  create = false
}

################################################################################
# Using packaged function from Lambda module
################################################################################

locals {
  package_url = "https://raw.githubusercontent.com/terraform-aws-modules/terraform-aws-lambda/master/examples/fixtures/python3.8-zip/existing_package.zip"
  downloaded  = "downloaded_package_${md5(local.package_url)}.zip"
}

resource "null_resource" "download_package" {
  triggers = {
    downloaded = local.downloaded
  }

  provisioner "local-exec" {
    command = "curl -L -o ${local.downloaded} ${local.package_url}"
  }
}

module "lambda_with_allowed_triggers" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 6.0"

  function_name = "${local.name}-with-allowed-triggers"
  description   = "My awesome lambda function (with allowed triggers)"
  handler       = "index.lambda_handler"
  runtime       = "python3.8"

  publish                = true
  create_package         = false
  local_existing_package = local.downloaded

  allowed_triggers = {
    AllowExecutionFromELB = {
      service    = "elasticloadbalancing"
      source_arn = module.alb.target_groups["ex-lambda-with-trigger"].arn
    }
  }

  depends_on = [null_resource.download_package]
}

module "lambda_without_allowed_triggers" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 6.0"

  function_name = "${local.name}-without-allowed-triggers"
  description   = "My awesome lambda function (without allowed triggers)"
  handler       = "index.lambda_handler"
  runtime       = "python3.8"

  publish                = true
  create_package         = false
  local_existing_package = local.downloaded

  # Allowed triggers will be managed by ALB module
  allowed_triggers = {}

  depends_on = [null_resource.download_package]
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

module "wildcard_cert" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "*.${var.domain_name}"
  zone_id     = data.aws_route53_zone.this.id
}

data "aws_ssm_parameter" "al2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "this" {
  ami           = data.aws_ssm_parameter.al2.value
  instance_type = "t3.nano"
  subnet_id     = element(module.vpc.private_subnets, 0)
}

resource "aws_instance" "other" {
  ami           = data.aws_ssm_parameter.al2.value
  instance_type = "t3.nano"
  subnet_id     = element(module.vpc.private_subnets, 0)
}

##################################################################
# AWS Cognito User Pool
##################################################################

resource "aws_cognito_user_pool" "this" {
  name = "user-pool-${local.name}"
}

resource "aws_cognito_user_pool_client" "this" {
  name                                 = "user-pool-client-${local.name}"
  user_pool_id                         = aws_cognito_user_pool.this.id
  generate_secret                      = true
  allowed_oauth_flows                  = ["code", "implicit"]
  callback_urls                        = ["https://${var.domain_name}/callback"]
  allowed_oauth_scopes                 = ["email", "openid"]
  allowed_oauth_flows_user_pool_client = true
}

resource "random_string" "this" {
  length  = 5
  upper   = false
  special = false
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = "${local.name}-${random_string.this.result}"
  user_pool_id = aws_cognito_user_pool.this.id
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

##################################################################
# AWS VPC IPAM
##################################################################

resource "aws_vpc_ipam" "this" {
  operating_regions {
    region_name = local.region
  }
}

resource "aws_vpc_ipam_pool" "this" {
  address_family                    = "ipv4"
  ipam_scope_id                     = aws_vpc_ipam.this.public_default_scope_id
  locale                            = local.region
  allocation_default_netmask_length = 30

  public_ip_source = "amazon"
  aws_service      = "ec2"
}

resource "aws_vpc_ipam_pool_cidr" "this" {
  ipam_pool_id   = aws_vpc_ipam_pool.this.id
  netmask_length = 30
}
