# AWS Application and Network Load Balancer (ALB & NLB) Terraform module

Terraform module which creates Application and Network Load Balancer resources on AWS.

[![SWUbanner](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner2-direct.svg)](https://github.com/vshymanskyy/StandWithUkraine/blob/main/docs/README.md)

## Usage

When you're using ALB Listener rules, make sure that every rule's `actions` block ends in a `forward`, `redirect`, or `fixed-response` action so that every rule will resolve to some sort of an HTTP response. Checkout the [AWS documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-update-rules.html) for more information.

### Application Load Balancer

#### HTTP to HTTPS redirect

```hcl
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "my-alb"
  vpc_id  = "vpc-abcde012"
  subnets = ["subnet-abcde012", "subnet-bcde012a"]

  # Security Group
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
      cidr_ipv4   = "10.0.0.0/16"
    }
  }

  access_logs = {
    bucket = "my-alb-logs"
  }

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"

      forward = {
        target_group_key = "ex-instance"
      }
    }
  }

  target_groups = {
    ex-instance = {
      name_prefix      = "h1"
      protocol         = "HTTP"
      port             = 80
      target_type      = "instance"
      target_id        = "i-0f6d38a07d50d080f"
    }
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

#### Cognito authentication

```hcl
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  # Truncated for brevity ...

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-cognito = {
      port            = 444
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"

      authenticate_cognito = {
        authentication_request_extra_params = {
          display = "page"
          prompt  = "login"
        }
        on_unauthenticated_request = "authenticate"
        session_cookie_name        = "session-${local.name}"
        session_timeout            = 3600
        user_pool_arn              = "arn:aws:cognito-idp:us-west-2:123456789012:userpool/us-west-2_abcdefghi"
        user_pool_client_id        = "us-west-2_fak3p001B"
        user_pool_domain           = "https://fak3p001B.auth.us-west-2.amazoncognito.com"
      }

      forward = {
        target_group_key = "ex-instance"
      }

      rules = {
        ex-oidc = {
          priority = 2

          actions = [
            {
              authenticate-oidc = {
                authentication_request_extra_params = {
                  display = "page"
                  prompt  = "login"
                }
                authorization_endpoint = "https://foobar.com/auth"
                client_id              = "client_id"
                client_secret          = "client_secret"
                issuer                 = "https://foobar.com"
                token_endpoint         = "https://foobar.com/token"
                user_info_endpoint     = "https://foobar.com/user_info"
              }
            },
            {
              forward = {
                target_group_key = "ex-instance"
              }
            }
          ]
        }
      }
    }
  }
}
```

#### Cognito authentication on certain paths, redirects for others

```hcl
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  # Truncated for brevity ...

  listeners = {
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"

      forward = {
        target_group_key = "instance"
      }

      rules = {
        redirect = {
          priority = 5000
          actions = [{
            redirect = {
              status_code = "HTTP_302"
              host        = "www.youtube.com"
              path        = "/watch"
              query       = "v=dQw4w9WgXcQ"
              protocol    = "HTTPS"
            }
          }]

          conditions = [{
            path_pattern = {
              values = ["/onboarding", "/docs"]
            }
          }]
        }

        cognito = {
          priority = 2
          actions = [
            {
              authenticate-cognito = {
                user_pool_arn       = "arn:aws:cognito-idp::123456789012:userpool/test-pool"
                user_pool_client_id = "6oRmFiS0JHk="
                user_pool_domain    = "test-domain-com"
              }
            },
            {
              forward = {
                target_group_key = "instance"
              }
            }
          ]

          conditions = [{
            path_pattern = {
              values = ["/protected-route", "private/*"]
            }
          }]
        }
      }
    }
  }

  target_groups = {
    instance = {
      name_prefix = "default"
      protocol    = "HTTPS"
      port        = 443
      target_type = "instance"
      target_id   = "i-0f6d38a07d50d080f"
    }
  }
}
```

### Network Load Balancer

#### TCP_UDP, UDP, TCP and TLS listeners

```hcl
module "nlb" {
  source = "terraform-aws-modules/alb/aws"

  name               = "my-nlb"
  load_balancer_type = "network"
  vpc_id             = "vpc-abcde012"
  subnets            = ["subnet-abcde012", "subnet-bcde012a"]

  # Security Group
  enforce_security_group_inbound_rules_on_private_link_traffic = "on"
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
      cidr_ipv4   = "10.0.0.0/16"
    }
  }

  access_logs = {
    bucket = "my-nlb-logs"
  }

  listeners = {
    ex-tcp-udp = {
      port     = 81
      protocol = "TCP_UDP"
      forward = {
        target_group_key = "ex-target"
      }
    }

    ex-udp = {
      port     = 82
      protocol = "UDP"
      forward = {
        target_group_key = "ex-target"
      }
    }

    ex-tcp = {
      port     = 83
      protocol = "TCP"
      forward = {
        target_group_key = "ex-target"
      }
    }

    ex-tls = {
      port            = 84
      protocol        = "TLS"
      certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
      forward = {
        target_group_key = "ex-target"
      }
    }
  }

  target_groups = {
    ex-target = {
      name_prefix = "pref-"
      protocol    = "TCP"
      port        = 80
      target_type = "ip"
      target_id   = "10.0.47.1"
    }
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Conditional creation

The following values are provided to toggle on/off creation of the associated resources as desired:

```hcl
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  # Disable creation of the LB and all resources
  create = false

 # ... omitted
}
```

## Examples

- [Complete Application Load Balancer](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/examples/complete-alb)
- [Complete Network Load Balancer](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/examples/complete-nlb)

See [patterns.md](https://github.com/terraform-aws-modules/terraform-aws-alb/blob/master/docs/patterns.md) for additional configuration snippets for common usage patterns.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.19 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.19 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lambda_permission.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource |
| [aws_lb_listener_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_lb_target_group_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_wafv2_web_acl_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs"></a> [access\_logs](#input\_access\_logs) | Map containing access logging configuration for load balancer | <pre>object({<br/>    bucket  = string<br/>    enabled = optional(bool, true)<br/>    prefix  = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_additional_target_group_attachments"></a> [additional\_target\_group\_attachments](#input\_additional\_target\_group\_attachments) | Map of additional target group attachments to create. Use `target_group_key` to attach to the target group created in `target_groups` | <pre>map(object({<br/>    target_group_key  = string<br/>    target_id         = string<br/>    target_type       = optional(string)<br/>    port              = optional(number)<br/>    availability_zone = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_associate_web_acl"></a> [associate\_web\_acl](#input\_associate\_web\_acl) | Indicates whether a Web Application Firewall (WAF) ACL should be associated with the load balancer | `bool` | `false` | no |
| <a name="input_client_keep_alive"></a> [client\_keep\_alive](#input\_client\_keep\_alive) | Client keep alive value in seconds. The valid range is 60-604800 seconds. The default is 3600 seconds | `number` | `null` | no |
| <a name="input_connection_logs"></a> [connection\_logs](#input\_connection\_logs) | Map containing access logging configuration for load balancer | <pre>object({<br/>    bucket  = string<br/>    enabled = optional(bool, true)<br/>    prefix  = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created (affects nearly all resources) | `bool` | `true` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Determines if a security group is created | `bool` | `true` | no |
| <a name="input_customer_owned_ipv4_pool"></a> [customer\_owned\_ipv4\_pool](#input\_customer\_owned\_ipv4\_pool) | The ID of the customer owned ipv4 pool to use for this load balancer | `string` | `null` | no |
| <a name="input_default_port"></a> [default\_port](#input\_default\_port) | Default port used across the listener and target group | `number` | `80` | no |
| <a name="input_default_protocol"></a> [default\_protocol](#input\_default\_protocol) | Default protocol used across the listener and target group | `string` | `"HTTP"` | no |
| <a name="input_desync_mitigation_mode"></a> [desync\_mitigation\_mode](#input\_desync\_mitigation\_mode) | Determines how the load balancer handles requests that might pose a security risk to an application due to HTTP desync. Valid values are `monitor`, `defensive` (default), `strictest` | `string` | `null` | no |
| <a name="input_dns_record_client_routing_policy"></a> [dns\_record\_client\_routing\_policy](#input\_dns\_record\_client\_routing\_policy) | Indicates how traffic is distributed among the load balancer Availability Zones. Possible values are any\_availability\_zone (default), availability\_zone\_affinity, or partial\_availability\_zone\_affinity. Only valid for network type load balancers | `string` | `null` | no |
| <a name="input_drop_invalid_header_fields"></a> [drop\_invalid\_header\_fields](#input\_drop\_invalid\_header\_fields) | Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (`true`) or routed to targets (`false`). The default is `true`. Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens. Only valid for Load Balancers of type `application` | `bool` | `true` | no |
| <a name="input_enable_cross_zone_load_balancing"></a> [enable\_cross\_zone\_load\_balancing](#input\_enable\_cross\_zone\_load\_balancing) | If `true`, cross-zone load balancing of the load balancer will be enabled. For application load balancer this feature is always enabled (`true`) and cannot be disabled. Defaults to `true` | `bool` | `true` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | If `true`, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to `true` | `bool` | `true` | no |
| <a name="input_enable_http2"></a> [enable\_http2](#input\_enable\_http2) | Indicates whether HTTP/2 is enabled in application load balancers. Defaults to `true` | `bool` | `null` | no |
| <a name="input_enable_tls_version_and_cipher_suite_headers"></a> [enable\_tls\_version\_and\_cipher\_suite\_headers](#input\_enable\_tls\_version\_and\_cipher\_suite\_headers) | Indicates whether the two headers (`x-amzn-tls-version` and `x-amzn-tls-cipher-suite`), which contain information about the negotiated TLS version and cipher suite, are added to the client request before sending it to the target. Only valid for Load Balancers of type `application`. Defaults to `false` | `bool` | `null` | no |
| <a name="input_enable_waf_fail_open"></a> [enable\_waf\_fail\_open](#input\_enable\_waf\_fail\_open) | Indicates whether to allow a WAF-enabled load balancer to route requests to targets if it is unable to forward the request to AWS WAF. Defaults to `false` | `bool` | `null` | no |
| <a name="input_enable_xff_client_port"></a> [enable\_xff\_client\_port](#input\_enable\_xff\_client\_port) | Indicates whether the X-Forwarded-For header should preserve the source port that the client used to connect to the load balancer in `application` load balancers. Defaults to `false` | `bool` | `null` | no |
| <a name="input_enable_zonal_shift"></a> [enable\_zonal\_shift](#input\_enable\_zonal\_shift) | Whether zonal shift is enabled | `bool` | `null` | no |
| <a name="input_enforce_security_group_inbound_rules_on_private_link_traffic"></a> [enforce\_security\_group\_inbound\_rules\_on\_private\_link\_traffic](#input\_enforce\_security\_group\_inbound\_rules\_on\_private\_link\_traffic) | Indicates whether inbound security group rules are enforced for traffic originating from a PrivateLink. Only valid for Load Balancers of type network. The possible values are on and off | `string` | `null` | no |
| <a name="input_idle_timeout"></a> [idle\_timeout](#input\_idle\_timeout) | The time in seconds that the connection is allowed to be idle. Only valid for Load Balancers of type `application`. Default: `60` | `number` | `null` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | If true, the LB will be internal. Defaults to `false` | `bool` | `null` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | The type of IP addresses used by the subnets for your load balancer. The possible values are `ipv4` and `dualstack` | `string` | `null` | no |
| <a name="input_ipam_pools"></a> [ipam\_pools](#input\_ipam\_pools) | The IPAM pools to use with the load balancer | <pre>object({<br/>    ipv4_ipam_pool_id = string<br/>  })</pre> | `null` | no |
| <a name="input_listeners"></a> [listeners](#input\_listeners) | Map of listener configurations to create | <pre>map(object({<br/>    alpn_policy                 = optional(string)<br/>    certificate_arn             = optional(string)<br/>    additional_certificate_arns = optional(list(string), [])<br/>    authenticate_cognito = optional(object({<br/>      authentication_request_extra_params = optional(map(string))<br/>      on_unauthenticated_request          = optional(string)<br/>      scope                               = optional(string)<br/>      session_cookie_name                 = optional(string)<br/>      session_timeout                     = optional(number)<br/>      user_pool_arn                       = optional(string)<br/>      user_pool_client_id                 = optional(string)<br/>      user_pool_domain                    = optional(string)<br/>    }))<br/>    authenticate_oidc = optional(object({<br/>      authentication_request_extra_params = optional(map(string))<br/>      authorization_endpoint              = string<br/>      client_id                           = string<br/>      client_secret                       = string<br/>      issuer                              = string<br/>      on_unauthenticated_request          = optional(string)<br/>      scope                               = optional(string)<br/>      session_cookie_name                 = optional(string)<br/>      session_timeout                     = optional(number)<br/>      token_endpoint                      = string<br/>      user_info_endpoint                  = string<br/>    }))<br/>    fixed_response = optional(object({<br/>      content_type = string<br/>      message_body = optional(string)<br/>      status_code  = optional(string)<br/>    }))<br/>    forward = optional(object({<br/>      target_group_arn = optional(string)<br/>      target_group_key = optional(string)<br/>    }))<br/>    weighted_forward = optional(object({<br/>      target_groups = optional(list(object({<br/>        target_group_arn = optional(string)<br/>        target_group_key = optional(string)<br/>        weight           = optional(number)<br/>      })))<br/>      stickiness = optional(object({<br/>        duration = optional(number)<br/>        enabled  = optional(bool)<br/>      }))<br/>    }))<br/>    redirect = optional(object({<br/>      host        = optional(string)<br/>      path        = optional(string)<br/>      port        = optional(string)<br/>      protocol    = optional(string)<br/>      query       = optional(string)<br/>      status_code = string<br/>    }))<br/>    mutual_authentication = optional(object({<br/>      advertise_trust_store_ca_names   = optional(string)<br/>      ignore_client_certificate_expiry = optional(bool)<br/>      mode                             = string<br/>      trust_store_arn                  = optional(string)<br/>    }))<br/>    order                                                                 = optional(number)<br/>    port                                                                  = optional(number)<br/>    protocol                                                              = optional(string)<br/>    routing_http_request_x_amzn_mtls_clientcert_header_name               = optional(string)<br/>    routing_http_request_x_amzn_mtls_clientcert_issuer_header_name        = optional(string)<br/>    routing_http_request_x_amzn_mtls_clientcert_leaf_header_name          = optional(string)<br/>    routing_http_request_x_amzn_mtls_clientcert_serial_number_header_name = optional(string)<br/>    routing_http_request_x_amzn_mtls_clientcert_subject_header_name       = optional(string)<br/>    routing_http_request_x_amzn_mtls_clientcert_validity_header_name      = optional(string)<br/>    routing_http_request_x_amzn_tls_cipher_suite_header_name              = optional(string)<br/>    routing_http_request_x_amzn_tls_version_header_name                   = optional(string)<br/>    routing_http_response_access_control_allow_credentials_header_value   = optional(string)<br/>    routing_http_response_access_control_allow_headers_header_value       = optional(string)<br/>    routing_http_response_access_control_allow_methods_header_value       = optional(string)<br/>    routing_http_response_access_control_allow_origin_header_value        = optional(string)<br/>    routing_http_response_access_control_expose_headers_header_value      = optional(string)<br/>    routing_http_response_access_control_max_age_header_value             = optional(string)<br/>    routing_http_response_content_security_policy_header_value            = optional(string)<br/>    routing_http_response_server_enabled                                  = optional(bool)<br/>    routing_http_response_strict_transport_security_header_value          = optional(string)<br/>    routing_http_response_x_content_type_options_header_value             = optional(string)<br/>    routing_http_response_x_frame_options_header_value                    = optional(string)<br/>    ssl_policy                                                            = optional(string)<br/>    tcp_idle_timeout_seconds                                              = optional(number)<br/>    tags                                                                  = optional(map(string), {})<br/><br/>    # Listener rules<br/>    rules = optional(map(object({<br/>      actions = list(object({<br/>        authenticate_cognito = optional(object({<br/>          authentication_request_extra_params = optional(map(string))<br/>          on_unauthenticated_request          = optional(string)<br/>          scope                               = optional(string)<br/>          session_cookie_name                 = optional(string)<br/>          session_timeout                     = optional(number)<br/>          user_pool_arn                       = string<br/>          user_pool_client_id                 = string<br/>          user_pool_domain                    = string<br/>        }))<br/>        authenticate_oidc = optional(object({<br/>          authentication_request_extra_params = optional(map(string))<br/>          authorization_endpoint              = string<br/>          client_id                           = string<br/>          client_secret                       = string<br/>          issuer                              = string<br/>          on_unauthenticated_request          = optional(string)<br/>          scope                               = optional(string)<br/>          session_cookie_name                 = optional(string)<br/>          session_timeout                     = optional(number)<br/>          token_endpoint                      = string<br/>          user_info_endpoint                  = string<br/>        }))<br/>        fixed_response = optional(object({<br/>          content_type = string<br/>          message_body = optional(string)<br/>          status_code  = optional(string)<br/>        }))<br/>        forward = optional(object({<br/>          target_group_arn = optional(string)<br/>          target_group_key = optional(string)<br/>        }))<br/>        order = optional(number)<br/>        redirect = optional(object({<br/>          host        = optional(string)<br/>          path        = optional(string)<br/>          port        = optional(string)<br/>          protocol    = optional(string)<br/>          query       = optional(string)<br/>          status_code = string<br/>        }))<br/>        weighted_forward = optional(object({<br/>          stickiness = optional(object({<br/>            duration = optional(number)<br/>            enabled  = optional(bool)<br/>          }))<br/>          target_groups = optional(list(object({<br/>            target_group_arn = optional(string)<br/>            target_group_key = optional(string)<br/>            weight           = optional(number)<br/>          })))<br/>        }))<br/>      }))<br/>      conditions = list(object({<br/>        host_header = optional(object({<br/>          values       = optional(list(string))<br/>          regex_values = optional(list(string))<br/>        }))<br/>        http_header = optional(object({<br/>          http_header_name = string<br/>          values           = optional(list(string))<br/>          regex_values     = optional(list(string))<br/>        }))<br/>        http_request_method = optional(object({<br/>          values = list(string)<br/>        }))<br/>        path_pattern = optional(object({<br/>          values       = optional(list(string))<br/>          regex_values = optional(list(string))<br/>        }))<br/>        query_string = optional(list(object({<br/>          key   = optional(string)<br/>          value = string<br/>        })))<br/>        source_ip = optional(object({<br/>          values = list(string)<br/>        }))<br/>      }))<br/>      listener_arn = optional(string)<br/>      listener_key = optional(string)<br/>      priority     = optional(number)<br/>      transform = optional(map(object({<br/>        type = optional(string)<br/>        host_header_rewrite_config = optional(object({<br/>          rewrite = optional(object({<br/>            regex   = string<br/>            replace = string<br/>          }))<br/>        }))<br/>        url_rewrite_config = optional(object({<br/>          rewrite = optional(object({<br/>            regex   = string<br/>            replace = string<br/>          }))<br/>        }))<br/>      })))<br/>      tags = optional(map(string), {})<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_load_balancer_type"></a> [load\_balancer\_type](#input\_load\_balancer\_type) | The type of load balancer to create. Possible values are `application`, `gateway`, or `network`. The default value is `application` | `string` | `"application"` | no |
| <a name="input_minimum_load_balancer_capacity"></a> [minimum\_load\_balancer\_capacity](#input\_minimum\_load\_balancer\_capacity) | Minimum capacity for a load balancer. Only valid for Load Balancers of type `application` or `network` | <pre>object({<br/>    capacity_units = number<br/>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the LB. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Creates a unique name beginning with the specified prefix. Conflicts with `name` | `string` | `null` | no |
| <a name="input_preserve_host_header"></a> [preserve\_host\_header](#input\_preserve\_host\_header) | Indicates whether the Application Load Balancer should preserve the Host header in the HTTP request and send it to the target without any change. Defaults to `false` | `bool` | `null` | no |
| <a name="input_putin_khuylo"></a> [putin\_khuylo](#input\_putin\_khuylo) | Do you agree that Putin doesn't respect Ukrainian sovereignty and territorial integrity? More info: https://en.wikipedia.org/wiki/Putin_khuylo! | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration | `string` | `null` | no |
| <a name="input_route53_records"></a> [route53\_records](#input\_route53\_records) | Map of Route53 records to create. Each record map should contain `zone_id`, `name`, and `type` | <pre>map(object({<br/>    zone_id                = string<br/>    name                   = optional(string)<br/>    type                   = string<br/>    evaluate_target_health = optional(bool, true)<br/>  }))</pre> | `null` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | Description of the security group created | `string` | `null` | no |
| <a name="input_security_group_egress_rules"></a> [security\_group\_egress\_rules](#input\_security\_group\_egress\_rules) | Security group egress rules to add to the security group created | <pre>map(object({<br/>    name = optional(string)<br/><br/>    cidr_ipv4                    = optional(string)<br/>    cidr_ipv6                    = optional(string)<br/>    description                  = optional(string)<br/>    from_port                    = optional(string)<br/>    ip_protocol                  = optional(string, "tcp")<br/>    prefix_list_id               = optional(string)<br/>    referenced_security_group_id = optional(string)<br/>    tags                         = optional(map(string), {})<br/>    to_port                      = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_security_group_ingress_rules"></a> [security\_group\_ingress\_rules](#input\_security\_group\_ingress\_rules) | Security group ingress rules to add to the security group created | <pre>map(object({<br/>    name = optional(string)<br/><br/>    cidr_ipv4                    = optional(string)<br/>    cidr_ipv6                    = optional(string)<br/>    description                  = optional(string)<br/>    from_port                    = optional(string)<br/>    ip_protocol                  = optional(string, "tcp")<br/>    prefix_list_id               = optional(string)<br/>    referenced_security_group_id = optional(string)<br/>    tags                         = optional(map(string), {})<br/>    to_port                      = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name to use on security group created | `string` | `null` | no |
| <a name="input_security_group_tags"></a> [security\_group\_tags](#input\_security\_group\_tags) | A map of additional tags to add to the security group created | `map(string)` | `{}` | no |
| <a name="input_security_group_use_name_prefix"></a> [security\_group\_use\_name\_prefix](#input\_security\_group\_use\_name\_prefix) | Determines whether the security group name (`security_group_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A list of security group IDs to assign to the LB | `list(string)` | `[]` | no |
| <a name="input_subnet_mapping"></a> [subnet\_mapping](#input\_subnet\_mapping) | A list of subnet mapping blocks describing subnets to attach to load balancer | <pre>list(object({<br/>    allocation_id        = optional(string)<br/>    ipv6_address         = optional(string)<br/>    private_ipv4_address = optional(string)<br/>    subnet_id            = string<br/>  }))</pre> | `null` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A list of subnet IDs to attach to the LB. Subnets cannot be updated for Load Balancers of type `network`. Changing this value for load balancers of type `network` will force a recreation of the resource | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_target_groups"></a> [target\_groups](#input\_target\_groups) | Map of target group configurations to create | <pre>map(object({<br/>    connection_termination = optional(bool)<br/>    deregistration_delay   = optional(number)<br/>    health_check = optional(object({<br/>      enabled             = optional(bool)<br/>      healthy_threshold   = optional(number)<br/>      interval            = optional(number)<br/>      matcher             = optional(string)<br/>      path                = optional(string)<br/>      port                = optional(string)<br/>      protocol            = optional(string)<br/>      timeout             = optional(number)<br/>      unhealthy_threshold = optional(number)<br/>    }))<br/>    ip_address_type                    = optional(string)<br/>    lambda_multi_value_headers_enabled = optional(bool)<br/>    load_balancing_algorithm_type      = optional(string)<br/>    load_balancing_anomaly_mitigation  = optional(string)<br/>    load_balancing_cross_zone_enabled  = optional(string)<br/>    name                               = optional(string)<br/>    name_prefix                        = optional(string)<br/>    port                               = optional(number)<br/>    preserve_client_ip                 = optional(bool)<br/>    protocol                           = optional(string)<br/>    protocol_version                   = optional(string)<br/>    proxy_protocol_v2                  = optional(bool)<br/>    slow_start                         = optional(number)<br/>    stickiness = optional(object({<br/>      cookie_duration = optional(number)<br/>      cookie_name     = optional(string)<br/>      enabled         = optional(bool)<br/>      type            = string<br/>    }))<br/>    tags = optional(map(string))<br/>    target_failover = optional(list(object({<br/>      on_deregistration = string<br/>      on_unhealthy      = string<br/>    })))<br/>    target_group_health = optional(object({<br/>      dns_failover = optional(object({<br/>        minimum_healthy_targets_count      = optional(string)<br/>        minimum_healthy_targets_percentage = optional(string)<br/>      }))<br/>      unhealthy_state_routing = optional(object({<br/>        minimum_healthy_targets_count      = optional(number)<br/>        minimum_healthy_targets_percentage = optional(string)<br/>      }))<br/>    }))<br/>    target_health_state = optional(object({<br/>      enable_unhealthy_connection_termination = bool<br/>      unhealthy_draining_interval             = optional(number)<br/>    }))<br/>    target_type = optional(string)<br/>    target_id   = optional(string)<br/>    vpc_id      = optional(string)<br/>    # Attachment<br/>    create_attachment = optional(bool, true)<br/>    availability_zone = optional(string)<br/>    # Lambda<br/>    attach_lambda_permission  = optional(bool, false)<br/>    lambda_qualifier          = optional(string)<br/>    lambda_statement_id       = optional(string)<br/>    lambda_action             = optional(string)<br/>    lambda_principal          = optional(string)<br/>    lambda_source_account     = optional(string)<br/>    lambda_event_source_token = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Create, update, and delete timeout configurations for the load balancer | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Identifier of the VPC where the security group will be created | `string` | `null` | no |
| <a name="input_web_acl_arn"></a> [web\_acl\_arn](#input\_web\_acl\_arn) | Web Application Firewall (WAF) ARN of the resource to associate with the load balancer | `string` | `null` | no |
| <a name="input_xff_header_processing_mode"></a> [xff\_header\_processing\_mode](#input\_xff\_header\_processing\_mode) | Determines how the load balancer modifies the X-Forwarded-For header in the HTTP request before sending the request to the target. The possible values are `append`, `preserve`, and `remove`. Only valid for Load Balancers of type `application`. The default is `append` | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ID and ARN of the load balancer we created |
| <a name="output_arn_suffix"></a> [arn\_suffix](#output\_arn\_suffix) | ARN suffix of our load balancer - can be used with CloudWatch |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | The DNS name of the load balancer |
| <a name="output_id"></a> [id](#output\_id) | The ID and ARN of the load balancer we created |
| <a name="output_listener_rules"></a> [listener\_rules](#output\_listener\_rules) | Map of listeners rules created and their attributes |
| <a name="output_listeners"></a> [listeners](#output\_listeners) | Map of listeners created and their attributes |
| <a name="output_route53_records"></a> [route53\_records](#output\_route53\_records) | The Route53 records created and attached to the load balancer |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | Amazon Resource Name (ARN) of the security group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
| <a name="output_target_groups"></a> [target\_groups](#output\_target\_groups) | Map of target groups created and their attributes |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | The zone\_id of the load balancer to assist with creating DNS records |
<!-- END_TF_DOCS -->

## Authors

Module is maintained by [Anton Babenko](https://github.com/antonbabenko) with help from [these awesome contributors](https://github.com/terraform-aws-modules/terraform-aws-alb/graphs/contributors).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/LICENSE) for full details.

## Additional information for users from Russia and Belarus

- Russia has [illegally annexed Crimea in 2014](https://en.wikipedia.org/wiki/Annexation_of_Crimea_by_the_Russian_Federation) and [brought the war in Donbas](https://en.wikipedia.org/wiki/War_in_Donbas) followed by [full-scale invasion of Ukraine in 2022](https://en.wikipedia.org/wiki/2022_Russian_invasion_of_Ukraine).
- Russia has brought sorrow and devastations to millions of Ukrainians, killed hundreds of innocent people, damaged thousands of buildings, and forced several million people to flee.
- [Putin khuylo!](https://en.wikipedia.org/wiki/Putin_khuylo!)
