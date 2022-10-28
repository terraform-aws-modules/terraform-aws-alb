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

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "random_pet" "this" {
  length = 2
}

data "aws_route53_zone" "this" {
  name = local.domain_name
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "alb-sg-${random_pet.this.id}"
  description = "Security group for example usage with ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

#module "log_bucket" {
#  source  = "terraform-aws-modules/s3-bucket/aws"
#  version = "~> 3.0"
#
#  bucket                         = "logs-${random_pet.this.id}"
#  acl                            = "log-delivery-write"
#  force_destroy                  = true
#  attach_elb_log_delivery_policy = true
#}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = local.domain_name # trimsuffix(data.aws_route53_zone.this.name, ".")
  zone_id     = data.aws_route53_zone.this.id
}

module "wildcard_cert" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = "*.${local.domain_name}" # trimsuffix(data.aws_route53_zone.this.name, ".")
  zone_id     = data.aws_route53_zone.this.id
}

##################################################################
# AWS Cognito User Pool
##################################################################
resource "aws_cognito_user_pool" "this" {
  name = "user-pool-${random_pet.this.id}"
}

resource "aws_cognito_user_pool_client" "this" {
  name                                 = "user-pool-client-${random_pet.this.id}"
  user_pool_id                         = aws_cognito_user_pool.this.id
  generate_secret                      = true
  allowed_oauth_flows                  = ["code", "implicit"]
  callback_urls                        = ["https://${local.domain_name}/callback"]
  allowed_oauth_scopes                 = ["email", "openid"]
  allowed_oauth_flows_user_pool_client = true
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = random_pet.this.id
  user_pool_id = aws_cognito_user_pool.this.id
}

##################################################################
# Application Load Balancer
##################################################################
module "alb" {
  source = "../../"

  name = "complete-alb-${random_pet.this.id}"

  load_balancer_type = "application"

  vpc_id          = data.aws_vpc.default.id
  security_groups = [module.security_group.security_group_id]
  subnets         = data.aws_subnets.all.ids

  #   # See notes in README (ref: https://github.com/terraform-providers/terraform-provider-aws/issues/7987)
  #   access_logs = {
  #     bucket = module.log_bucket.s3_bucket_id
  #   }

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
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
    {
      port        = 82
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
        session_cookie_name        = "session-${random_pet.this.id}"
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
        authorization_endpoint = "https://${local.domain_name}/auth"
        client_id              = "client_id"
        client_secret          = "client_secret"
        issuer                 = "https://${local.domain_name}"
        token_endpoint         = "https://${local.domain_name}/token"
        user_info_endpoint     = "https://${local.domain_name}/user_info"
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
          session_cookie_name        = "session-${random_pet.this.id}"
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
          authorization_endpoint = "https://${local.domain_name}/auth"
          client_id              = "client_id"
          client_secret          = "client_secret"
          issuer                 = "https://${local.domain_name}"
          token_endpoint         = "https://${local.domain_name}/token"
          user_info_endpoint     = "https://${local.domain_name}/user_info"
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

  function_name = "${random_pet.this.id}-with-allowed-triggers"
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

  function_name = "${random_pet.this.id}-without-allowed-triggers"
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
