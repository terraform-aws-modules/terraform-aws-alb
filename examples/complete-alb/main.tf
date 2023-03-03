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
# Application Load Balancer
##################################################################

module "alb" {
  source = "../../"

  name = local.name

  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  # Attach security groups
  security_groups = [module.vpc.default_security_group_id]
  # Attach rules to the created security group
  security_group_rules = {
    ingress_all_http = {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP web traffic"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_all_icmp = {
      type        = "ingress"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      description = "ICMP"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # # See notes in README (ref: https://github.com/terraform-providers/terraform-provider-aws/issues/7987)
  # access_logs = {
  #   bucket = module.log_bucket.s3_bucket_id
  # }

  http_tcp_listeners = [
    # Forward action is default, either when defined or undefined
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
      # action_type        = "forward"
    },
    {
      port        = 81
      protocol    = "HTTP"
      action_type = "forward"
      forward = {
        target_groups = [
          {
            target_group_index = 0
            weight             = 100
          },
          {
            target_group_index = 1
            weight             = 0
          }
        ]
      }
    },
    {
      port        = 82
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
    {
      port        = 83
      protocol    = "HTTP"
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed message"
        status_code  = "200"
      }
    },
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 1
    },
    # Authentication actions only allowed with HTTPS
    {
      port               = 444
      protocol           = "HTTPS"
      action_type        = "authenticate-cognito"
      target_group_index = 1
      certificate_arn    = module.acm.acm_certificate_arn
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
    },
    {
      port               = 445
      protocol           = "HTTPS"
      action_type        = "authenticate-oidc"
      target_group_index = 1
      certificate_arn    = module.acm.acm_certificate_arn
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
    },
  ]

  extra_ssl_certs = [
    {
      https_listener_index = 0
      certificate_arn      = module.wildcard_cert.acm_certificate_arn
    }
  ]

  https_listener_rules = [
    {
      https_listener_index = 0

      actions = [
        {
          type = "authenticate-cognito"

          on_unauthenticated_request = "authenticate"
          session_cookie_name        = "session-${local.name}"
          session_timeout            = 3600
          user_pool_arn              = aws_cognito_user_pool.this.arn
          user_pool_client_id        = aws_cognito_user_pool_client.this.id
          user_pool_domain           = aws_cognito_user_pool_domain.this.domain
        },
        {
          type               = "forward"
          target_group_index = 0
        }
      ]

      conditions = [{
        path_patterns = ["/some/auth/required/route"]
      }]
    },
    {
      https_listener_index = 1
      priority             = 2

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
          type               = "forward"
          target_group_index = 1
        }
      ]

      conditions = [{
        host_headers = ["foobar.com"]
      }]
    },
    {
      https_listener_index = 0
      priority             = 3
      actions = [{
        type         = "fixed-response"
        content_type = "text/plain"
        status_code  = 200
        message_body = "This is a fixed response"
      }]

      conditions = [{
        http_headers = [{
          http_header_name = "x-Gimme-Fixed-Response"
          values           = ["yes", "please", "right now"]
        }]
      }]
    },
    {
      https_listener_index = 0
      priority             = 4

      actions = [{
        type = "weighted-forward"
        target_groups = [
          {
            target_group_index = 1
            weight             = 2
          },
          {
            target_group_index = 0
            weight             = 1
          }
        ]
        stickiness = {
          enabled  = true
          duration = 3600
        }
      }]

      conditions = [{
        query_strings = [{
          key   = "weighted"
          value = "true"
        }]
      }]
    },
    {
      https_listener_index = 0
      priority             = 5000
      actions = [{
        type        = "redirect"
        status_code = "HTTP_302"
        host        = "www.youtube.com"
        path        = "/watch"
        query       = "v=dQw4w9WgXcQ"
        protocol    = "HTTPS"
      }]

      conditions = [{
        query_strings = [{
          key   = "video"
          value = "random"
        }]
      }]
    },
  ]

  http_tcp_listener_rules = [
    {
      http_tcp_listener_index = 0
      priority                = 3
      actions = [{
        type         = "fixed-response"
        content_type = "text/plain"
        status_code  = 200
        message_body = "This is a fixed response"
      }]

      conditions = [{
        http_headers = [{
          http_header_name = "x-Gimme-Fixed-Response"
          values           = ["yes", "please", "right now"]
        }]
      }]
    },
    {
      http_tcp_listener_index = 0
      priority                = 4

      actions = [{
        type = "weighted-forward"
        target_groups = [
          {
            target_group_index = 1
            weight             = 2
          },
          {
            target_group_index = 0
            weight             = 1
          }
        ]
        stickiness = {
          enabled  = true
          duration = 3600
        }
      }]

      conditions = [{
        query_strings = [{
          key   = "weighted"
          value = "true"
        }]
      }]
    },
    {
      http_tcp_listener_index = 0
      priority                = 5000
      actions = [{
        type        = "redirect"
        status_code = "HTTP_302"
        host        = "www.youtube.com"
        path        = "/watch"
        query       = "v=dQw4w9WgXcQ"
        protocol    = "HTTPS"
      }]

      conditions = [{
        query_strings = [{
          key   = "video"
          value = "random"
        }]
      }]
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
      protocol_version = "HTTP1"
      targets = {
        my_ec2 = {
          target_id = aws_instance.this.id
          port      = 80
        },
        my_ec2_again = {
          target_id = aws_instance.this.id
          port      = 8080
        }
      }
      tags = {
        InstanceTargetGroupTag = "baz"
      }
    },
    {
      name_prefix                        = "l1-"
      target_type                        = "lambda"
      lambda_multi_value_headers_enabled = true
      targets = {
        lambda_with_allowed_triggers = {
          target_id = module.lambda_with_allowed_triggers.lambda_function_arn
        }
      }
    },
    {
      name_prefix = "l2-"
      target_type = "lambda"
      targets = {
        lambda_without_allowed_triggers = {
          target_id                = module.lambda_without_allowed_triggers.lambda_function_arn
          attach_lambda_permission = true
        }
      }
    },
  ]

  tags = {
    Project = "Unknown"
  }

  lb_tags = {
    MyLoadBalancer = "foo"
  }

  target_group_tags = {
    MyGlobalTargetGroupTag = "bar"
  }

  https_listener_rules_tags = {
    MyLoadBalancerHTTPSListenerRule = "bar"
  }

  https_listeners_tags = {
    MyLoadBalancerHTTPSListener = "bar"
  }

  http_tcp_listeners_tags = {
    MyLoadBalancerTCPListener = "bar"
  }
}

#########################
# LB will not be created
#########################

module "lb_disabled" {
  source = "../../"

  create_lb = false
}

##################
# Extra resources
##################

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.nano"
  subnet_id     = element(module.vpc.private_subnets, 0)
}

#############################################
# Using packaged function from Lambda module
#############################################

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
  version = "~> 3.0"

  function_name = "${local.name}-with-allowed-triggers"
  description   = "My awesome lambda function (with allowed triggers)"
  handler       = "index.lambda_handler"
  runtime       = "python3.8"

  publish = true

  create_package         = false
  local_existing_package = local.downloaded

  allowed_triggers = {
    AllowExecutionFromELB = {
      service    = "elasticloadbalancing"
      source_arn = module.alb.target_group_arns[1] # index should match the correct target_group
    }
  }

  depends_on = [null_resource.download_package]
}

module "lambda_without_allowed_triggers" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 3.0"

  function_name = "${local.name}-without-allowed-triggers"
  description   = "My awesome lambda function (without allowed triggers)"
  handler       = "index.lambda_handler"
  runtime       = "python3.8"

  publish = true

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

module "wildcard_cert" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = "*.${var.domain_name}"
  zone_id     = data.aws_route53_zone.this.id
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

resource "aws_cognito_user_pool_domain" "this" {
  domain       = local.name
  user_pool_id = aws_cognito_user_pool.this.id
}
