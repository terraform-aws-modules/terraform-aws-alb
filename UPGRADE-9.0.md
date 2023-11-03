# Upgrade from v8.x to v9.x

Please consult the `examples` directory for reference example configurations. If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- `target_groups` previously were defined by an array of target group definitions that were created using the `count` meta-argument. This has been replaced with a map of target group definitions that are created using the `for_each` meta-argument in order to provide better stability when adding/removing target group definitions.
- `target_groups` no longer support multiple targets per target group. There are alternate methods to achieve similar functionality such as weighted target groups or using an autoscaling group as a target when targetting EC2 instances.
- The previous methods for creating listeners have been removed in favor of one argument, `listeners`, which take a map of listener definitions that are created using the `for_each` meta-argument in order to provide better stability when adding/removing listener definitions. Previously the `target_group_index` was used to associate/reference a target group; that is now replaced with `target_group_key` which is the key of the target group definition in the `target_groups` map.
- `security_group_rules` has been replaced by `security_group_ingress_rules` and `security_group_egress_rules` to align with the new underlying resources.
- Minimum supported version of Terraform AWS provider updated to `v5.13` to support the latest features provided via the resources utilized.
- Minimum supported version of Terraform updated to `v1.0`
- The `Name` tag has been removed from resources

## Additional changes

### Added

- Security group attachment restrictions have been removed now that both ALB and NLB support security groups
- Support for creating Route53 records for ALB/NLB DNS names via the `route53_records` variable

### Modified

- `enable_cross_zone_load_balancing` now defaults to `true`
- `drop_invalid_header_fields` now defaults to `true`
- `enable_deletion_protection` now defaults to `true`
- `associate_web_acl` has been added to identify when a WAFv2 Web ACL should be associated with the ALB; previously this was accomplished by checking for the presence of a value passed to `web_acl_arn` which is known to cause issues when the value does not exist and is computed.

### Removed

- None

### Variable and output changes

1. Removed variables:

   - `target_group_tags`
   - `https_listener_rules_tags`
   - `http_tcp_listener_rules_tags`
   - `https_listeners_tags`
   - `http_tcp_listeners_tags`
   - `load_balancer_create_timeout` -> replaced with `timeouts`
   - `load_balancer_update_timeout` -> replaced with `timeouts`
   - `load_balancer_delete_timeout` -> replaced with `timeouts`

2. Renamed variables:

   - `create_lb` -> `create`

3. Added variables:

   - `customer_owned_ipv4_pool`
   - `default_port`
   - `default_protocol`
   - `route53_records`
   - `associate_web_acl`

4. Removed outputs:

   - `http_tcp_listener_arns` -> replaced with `listeners`
   - `http_tcp_listener_ids` -> replaced with `listeners`
   - `https_listener_arns` -> replaced with `listeners`
   - `https_listener_ids` -> replaced with `listeners`
   - `target_group_arns` -> replaced with `target_groups`
   - `target_group_arn_suffixes` -> replaced with `target_groups`
   - `target_group_names` -> replaced with `target_groups`
   - `target_group_attachments` -> replaced with `target_groups`

5. Renamed outputs:

   - Outputs previously prefixed with `lb_` have been renamed to remove this prefix (i.e. - `lb_arn` is now `arn`)

6. Added outputs:

   - `route53_records`

## Upgrade Migrations

### Before (v8.x) vs After (v9.x)

#### Before (v8.x)

```hcl
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.7.0"

  name    = local.name
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  # Security group
  security_group_rules = {
    ingress_all_http = {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP web traffic"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_all_https = {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS web traffic"
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

  # Listener(s)
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
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

  # Listener rule(s)
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

  # Target Group(s)
  target_groups = [
    {
      name_prefix      = "h1"
      protocol = "HTTP"
      port     = 80
      target_type      = "instance"

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
        }
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
}
```

#### After (v9.x)

```hcl
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.0.0"

  name    = local.name
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  # Security group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
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

  # Listener(s) w/ Listener Rule(s)
  listeners = {
    default = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "lambda-with-trigger"
      }
    }

    http-https-redirect = {
      port     = 82
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }

      rules = {
        fixed-response = {
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

        weighted-forward = {
          priority = 4
          actions = [{
            type = "weighted-forward"
            target_groups = [
              {
                target_group_key = "lambda-with-trigger"
                weight           = 2
              },
              {
                target_group_key = "instance"
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

        redirect = {
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

    http-weighted-target = {
      port     = 81
      protocol = "HTTP"
      weighted_forward = {
        target_groups = [
          {
            target_group_key = "lambda-with-trigger"
            weight           = 0
          },
          {
            target_group_key = "instance"
            weight           = 100
          }
        ]
      }
    }

    fixed-response = {
      port     = 83
      protocol = "HTTP"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed message"
        status_code  = "200"
      }
    }

    https = {
      port                        = 443
      protocol                    = "HTTPS"
      ssl_policy                  = "ELBSecurityPolicy-2016-08"
      certificate_arn             = module.acm.acm_certificate_arn
      additional_certificate_arns = [module.wildcard_cert.acm_certificate_arn]

      forward = {
        target_group_key = "lambda-with-trigger"
      }

      rules = {
        cognito = {
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
              target_group_key = "instance"
            }
          ]

          conditions = [{
            path_pattern = {
              values = ["/some/auth/required/route"]
            }
          }]
        }

        fixed-response = {
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

        weight-forward = {
          priority = 4
          actions = [{
            type = "weighted-forward"
            target_groups = [
              {
                target_group_key = "instance"
                weight           = 2
              },
              {
                target_group_key = "lambda-with-trigger"
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

        redirect = {
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

    cognito = {
      port            = 444
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-2016-08"
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
        target_group_key = "lambda-with-trigger"
      }

      rules = {
        oidc = {
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
              target_group_key = "lambda-with-trigger"
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

    oidc = {
      port            = 445
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-2016-08"
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
        target_group_key = "lambda-with-trigger"
      }
    }
  }

  # Target Group(s)
  target_groups = {
    instance = {
      name_prefix      = "h1"
      protocol = "HTTP"
      port     = 80
      target_type      = "instance"

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
    }
    lambda-with-trigger = {
      name_prefix                        = "l1-"
      target_type                        = "lambda"
      lambda_multi_value_headers_enabled = true
      target_id                          = module.lambda_with_allowed_triggers.lambda_function_arn
    }
    lambda-without-trigger = {
      name_prefix              = "l2-"
      target_type              = "lambda"
      target_id                = module.lambda_without_allowed_triggers.lambda_function_arn
      attach_lambda_permission = true
    }
  }
}
```

## Terraform State Moves

### Listener(s)

Each listener will need to be migrated using the index position in v8.x to the key of the listener in v9.x - see example state move commands below:

```sh
terraform state mv 'module.alb.aws_lb_listener.frontend_http_tcp[0]' 'module.alb.aws_lb_listener.this["default"]'
terraform state mv 'module.alb.aws_lb_listener.frontend_http_tcp[1]' 'module.alb.aws_lb_listener.this["http-weighted-target"]'
terraform state mv 'module.alb.aws_lb_listener.frontend_http_tcp[2]' 'module.alb.aws_lb_listener.this["http-https-redirect"]'
terraform state mv 'module.alb.aws_lb_listener.frontend_http_tcp[3]' 'module.alb.aws_lb_listener.this["fixed-response"]'

terraform state mv 'module.alb.aws_lb_listener.frontend_https[0]' 'module.alb.aws_lb_listener.this["https"]'
terraform state mv 'module.alb.aws_lb_listener.frontend_https[1]' 'module.alb.aws_lb_listener.this["cognito"]'
terraform state mv 'module.alb.aws_lb_listener.frontend_https[2]' 'module.alb.aws_lb_listener.this["oidc"]'
```

### Listener Rule(s)

Each listener rule will need to be migrated using the index position in v8.x to the key of the listener rule in v9.x - see example state move commands below:

```sh
# HTTP
terraform state mv 'module.alb.aws_lb_listener_rule.http_tcp_listener_rule[0]' 'module.alb.aws_lb_listener_rule.this["http-https-redirect/fixed-response"]'
terraform state mv 'module.alb.aws_lb_listener_rule.http_tcp_listener_rule[1]' 'module.alb.aws_lb_listener_rule.this["http-https-redirect/weighted-forward"]'
terraform state mv 'module.alb.aws_lb_listener_rule.http_tcp_listener_rule[2]' 'module.alb.aws_lb_listener_rule.this["http-https-redirect/redirect"]'

# HTTPS
terraform state mv 'module.alb.aws_lb_listener_rule.https_listener_rule[0]' 'module.alb.aws_lb_listener_rule.this["https/cognito"]'
terraform state mv 'module.alb.aws_lb_listener_rule.https_listener_rule[1]' 'module.alb.aws_lb_listener_rule.this["cognito/oidc"]'
terraform state mv 'module.alb.aws_lb_listener_rule.https_listener_rule[2]' 'module.alb.aws_lb_listener_rule.this["https/fixed-response"]'
terraform state mv 'module.alb.aws_lb_listener_rule.https_listener_rule[3]' 'module.alb.aws_lb_listener_rule.this["https/weight-forward"]'
terraform state mv 'module.alb.aws_lb_listener_rule.https_listener_rule[4]' 'module.alb.aws_lb_listener_rule.this["https/redirect"]'
```

### Additional SSL Certificate(s)

Each additional SSL certificate will need to be migrated using the index position in v8.x to the <key/index> of the additional SSL certificate in v9.x - see example state move commands below:

```sh
terraform state mv 'module.alb.aws_lb_listener_certificate.https_listener[0]' 'module.alb.aws_lb_listener_certificate.this["https/0"]'
```

### Target Group(s)

Each target group will need to be migrated using the index position in v8.x to the key of the target group in v9.x - see example state move commands below:

```sh
terraform state mv 'module.alb.aws_lb_target_group.main[0]' 'module.alb.aws_lb_target_group.this["instance"]'
terraform state mv 'module.alb.aws_lb_target_group.main[1]' 'module.alb.aws_lb_target_group.this["lambda-with-trigger"]'
terraform state mv 'module.alb.aws_lb_target_group.main[2]' 'module.alb.aws_lb_target_group.this["lambda-without-trigger"]'
```

### Lambda Permission(s)

Each lambda permission will need to be migrated using the <index.key> position in v8.x to the key of the lambda permission in v9.x - see example state move commands below:

```sh
terraform state mv 'module.alb.aws_lambda_permission.lb["2.lambda_without_allowed_triggers"]' 'module.alb.aws_lambda_permission.this["lambda-without-trigger"]'
```

### Security Group Rule(s)

The security group rules have been changed from the `aws_security_group_rule` resource to the new `aws_vpc_security_group_ingress_rule`/`aws_vpc_security_group_egress_rule` resources.
If you do not wish for the rules to be recreated during the upgrade, you will need to remove the existing rules from the Terraform state, and re-import (you cannot `terrraform state mv` across
different resource types). For example, for one rule, you would perform the following snippet:

Example of security group rules for v8.x

```hcl
  security_group_rules = {
    ingress_all_http = {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP web traffic"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
```

Example of security group rules for v8.x

```hcl
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
```

```sh
terraform state rm 'aws_security_group_rule.this["ingress_all_http"]'
terraform import 'aws_vpc_security_group_ingress_rule.this["all_http"]' sgr-xxx # ensure the key matches your updated implementation
```
