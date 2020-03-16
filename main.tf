resource "aws_lb" "this" {
  count = var.create_lb ? 1 : 0

  name        = var.name
  name_prefix = var.name_prefix

  load_balancer_type = var.load_balancer_type
  internal           = var.internal
  security_groups    = var.security_groups
  subnets            = var.subnets

  idle_timeout                     = var.idle_timeout
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = var.enable_http2
  ip_address_type                  = var.ip_address_type

  # See notes in README (ref: https://github.com/terraform-providers/terraform-provider-aws/issues/7987)
  dynamic "access_logs" {
    for_each = length(keys(var.access_logs)) == 0 ? [] : [var.access_logs]

    content {
      enabled = lookup(access_logs.value, "enabled", lookup(access_logs.value, "bucket", null) != null)
      bucket  = lookup(access_logs.value, "bucket", null)
      prefix  = lookup(access_logs.value, "prefix", null)
    }
  }

  dynamic "subnet_mapping" {
    for_each = var.subnet_mapping

    content {
      subnet_id     = subnet_mapping.value.subnet_id
      allocation_id = lookup(subnet_mapping.value, "allocation_id", null)
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name != null ? var.name : var.name_prefix
    },
  )

  timeouts {
    create = var.load_balancer_create_timeout
    update = var.load_balancer_update_timeout
    delete = var.load_balancer_delete_timeout
  }
}

resource "aws_lb_target_group" "main" {
  count = var.create_lb ? length(var.target_groups) : 0

  name        = lookup(var.target_groups[count.index], "name", null)
  name_prefix = lookup(var.target_groups[count.index], "name_prefix", null)

  vpc_id      = var.vpc_id
  port        = lookup(var.target_groups[count.index], "backend_port", null)
  protocol    = lookup(var.target_groups[count.index], "backend_protocol", null) != null ? upper(lookup(var.target_groups[count.index], "backend_protocol")) : null
  target_type = lookup(var.target_groups[count.index], "target_type", null)

  deregistration_delay               = lookup(var.target_groups[count.index], "deregistration_delay", null)
  slow_start                         = lookup(var.target_groups[count.index], "slow_start", null)
  proxy_protocol_v2                  = lookup(var.target_groups[count.index], "proxy_protocol_v2", null)
  lambda_multi_value_headers_enabled = lookup(var.target_groups[count.index], "lambda_multi_value_headers_enabled", null)

  dynamic "health_check" {
    for_each = length(keys(lookup(var.target_groups[count.index], "health_check", {}))) == 0 ? [] : [lookup(var.target_groups[count.index], "health_check", {})]

    content {
      enabled             = lookup(health_check.value, "enabled", null)
      interval            = lookup(health_check.value, "interval", null)
      path                = lookup(health_check.value, "path", null)
      port                = lookup(health_check.value, "port", null)
      healthy_threshold   = lookup(health_check.value, "healthy_threshold", null)
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", null)
      timeout             = lookup(health_check.value, "timeout", null)
      protocol            = lookup(health_check.value, "protocol", null)
      matcher             = lookup(health_check.value, "matcher", null)
    }
  }

  dynamic "stickiness" {
    for_each = length(keys(lookup(var.target_groups[count.index], "stickiness", {}))) == 0 ? [] : [lookup(var.target_groups[count.index], "stickiness", {})]

    content {
      enabled         = lookup(stickiness.value, "enabled", null)
      cookie_duration = lookup(stickiness.value, "cookie_duration", null)
      type            = lookup(stickiness.value, "type", null)
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = lookup(var.target_groups[count.index], "name", lookup(var.target_groups[count.index], "name_prefix", ""))
    },
  )

  depends_on = [aws_lb.this]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "frontend_http_tcp" {
  count = var.create_lb ? length(var.http_tcp_listeners) : 0

  load_balancer_arn = aws_lb.this[0].arn

  port     = var.http_tcp_listeners[count.index]["port"]
  protocol = var.http_tcp_listeners[count.index]["protocol"]

  dynamic "default_action" {
    for_each = var.http_tcp_listeners[count.index]

    # Defaults to forward action if action_type not specified
    content {
      type             = lookup(default_action.value, "action_type", "forward")
      target_group_arn = contains([null, "forward"], var.https_listeners[count.index]["action_type"]) ? aws_lb_target_group.main[lookup(var.https_listeners[count.index], "target_group_index", count.index)].id : null

      dynamic "redirect" {
        for_each = length(keys(lookup(redirect.value, "redirect_block", {}))) == 0 ? [] : [lookup(redirect.value, "redirect_block", {})]

        content {
          path        = lookup(redirect.value, "path", null)
          host        = lookup(redirect.value, "host", null)
          port        = lookup(redirect.value, "port", null)
          protocol    = lookup(redirect.value, "protocol", null)
          query       = lookup(redirect.value, "query", null)
          status_code = lookup(redirect.value, "status_code", null)
        }
      }

      dynamic "fixed_response" {
        for_each = length(keys(lookup(default_action.value, "fixed_response_block", {}))) == 0 ? [] : [lookup(default_action.value, "fixed_response_block", {})]

        content {
          content_type = lookup(fixed_response.value, "content_type", null)
          message_body = lookup(fixed_response.value, "message_body", null)
          status_code  = lookup(fixed_response.value, "status_code", null)
        }
      }

      dynamic "authenticate_cognito" {
        for_each = length(keys(lookup(default_action.value, "authenticate_cognito_block", {}))) == 0 ? [] : [lookup(default_action.value, "authenticate_cognito_block", {})]

        # Max 10 extra params
        content {
          dynamic "authentication_request_extra_params" {
            for_each = length(keys(lookup(authenticate_cognito.value, "authentication_request_extra_params", {}))) == 0 ? [] : [lookup(authenticate_cognito.value, "authentication_request_extra_params", {})]

            content {
              key   = authentication_request_extra_params.key
              value = authentication_request_extra_params.value
            }
          }
          on_unauthenticated_request = lookup(authenticate_cognito.value, "on_authenticated_request", null)
          scope                      = lookup(authenticate_cognito.value, "scope", null)
          session_cookie_name        = lookup(authenticate_cognito.value, "session_cookie_name", null)
          session_timeout            = lookup(authenticate_cognito.value, "session_timeout", null)
          user_pool_arn              = lookup(authenticate_cognito.value, "user_pool_arn", null)
          user_pool_client_id        = lookup(authenticate_cognito.value, "user_pool_client_id", null)
          user_pool_domain           = lookup(authenticate_cognito.value, "user_pool_domain", null)
        }
      }

      dynamic "authenticate_oidc" {
        for_each = length(keys(lookup(default_action.value, "authenticate_oidc_block", {}))) == 0 ? [] : [lookup(default_action.value, "authenticate_oidc_block", {})]

        # Max 10 extra params
        content {
          dynamic "authentication_request_extra_params" {
            for_each = length(keys(lookup(authenticate_oidc.value, "authentication_request_extra_params", {}))) == 0 ? [] : [lookup(authenticate_oidc.value, "authentication_request_extra_params", {})]

            content {
              authentication_request_extra_params.key = authentication_request_extra_params.value
            }
          }
          authorization_endpoint     = lookup(authenticate_oidc.value, "authorization_endpoint", null)
          client_id                  = lookup(authenticate_oidc.value, "client_id", null)
          client_secret              = lookup(authenticate_oidc.value, "client_secret", null)
          issuer                     = lookup(authenticate_oidc.value, "issuer", null)
          on_unauthenticated_request = lookup(authenticate_oidc.value, "on_unauthenticated_request", null)
          scope                      = lookup(authenticate_oidc.value, "scope", null)
          session_cookie_name        = lookup(authenticate_oidc.value, "session_cookie_name", null)
          session_timeout            = lookup(authenticate_oidc.value, "session_timeout", null)
          token_endpoint             = lookup(authenticate_oidc.value, "token_endpoint", null)
          user_info_endpoint         = lookup(authenticate_oidc.value, "user_info_endpoint", null)
        }
      }
    }
  }

  default_action {
    type             = contains(["authenticate-oidc", "authenticate-cognito"], var.http_tcp_listeners[count.index]["action_type"]) ? "forward" : null
    target_group_arn = contains(["authenticate-oidc", "authenticate-cognito"], var.http_tcp_listeners[count.index]["action_type"]) ? aws_lb_target_group.main[lookup(var.http_tcp_listeners[count.index], "target_group_index", count.index)].id : null
  }
}

resource "aws_lb_listener" "frontend_https" {
  count = var.create_lb ? length(var.https_listeners) : 0

  load_balancer_arn = aws_lb.this[0].arn

  port            = var.https_listeners[count.index]["port"]
  protocol        = lookup(var.https_listeners[count.index], "protocol", "HTTPS")
  certificate_arn = var.https_listeners[count.index]["certificate_arn"]
  ssl_policy      = lookup(var.https_listeners[count.index], "ssl_policy", var.listener_ssl_policy_default)

  dynamic "default_action" {
    for_each = var.https_listeners[count.index]

    # Defaults to forward action if action_type not specified
    content {
      type             = lookup(default_action.value, "action_type", "forward")
      target_group_arn = contains([null, "forward"], var.https_listeners[count.index]["action_type"]) ? aws_lb_target_group.main[lookup(var.https_listeners[count.index], "target_group_index", count.index)].id : null

      dynamic "redirect" {
        for_each = length(keys(lookup(redirect.value, "redirect_block", {}))) == 0 ? [] : [lookup(redirect.value, "redirect_block", {})]

        content {
          path        = lookup(redirect.value, "path", null)
          host        = lookup(redirect.value, "host", null)
          port        = lookup(redirect.value, "port", null)
          protocol    = lookup(redirect.value, "protocol", null)
          query       = lookup(redirect.value, "query", null)
          status_code = lookup(redirect.value, "status_code", null)
        }
      }

      dynamic "fixed_response" {
        for_each = length(keys(lookup(default_action.value, "fixed_response_block", {}))) == 0 ? [] : [lookup(default_action.value, "fixed_response_block", {})]

        content {
          content_type = lookup(fixed_response.value, "content_type", null)
          message_body = lookup(fixed_response.value, "message_body", null)
          status_code  = lookup(fixed_response.value, "status_code", null)
        }
      }

      dynamic "authenticate_cognito" {
        for_each = length(keys(lookup(default_action.value, "authenticate_cognito_block", {}))) == 0 ? [] : [lookup(default_action.value, "authenticate_cognito_block", {})]

        # Max 10 extra params
        content {
          dynamic "authentication_request_extra_params" {
            for_each = length(keys(lookup(authenticate_cognito.value, "authentication_request_extra_params", {}))) == 0 ? [] : [lookup(authenticate_cognito.value, "authentication_request_extra_params", {})]

            content {
              authentication_request_extra_params.key = authentication_request_extra_params.value
            }
          }
          on_unauthenticated_request = lookup(authenticate_cognito.value, "on_authenticated_request", null)
          scope                      = lookup(authenticate_cognito.value, "scope", null)
          session_cookie_name        = lookup(authenticate_cognito.value, "session_cookie_name", null)
          session_timeout            = lookup(authenticate_cognito.value, "session_timeout", null)
          user_pool_arn              = lookup(authenticate_cognito.value, "user_pool_arn", null)
          user_pool_client_id        = lookup(authenticate_cognito.value, "user_pool_client_id", null)
          user_pool_domain           = lookup(authenticate_cognito.value, "user_pool_domain", null)
        }
      }

      dynamic "authenticate_oidc" {
        for_each = length(keys(lookup(default_action.value, "authenticate_oidc_block", {}))) == 0 ? [] : [lookup(default_action.value, "authenticate_oidc_block", {})]

        # Max 10 extra params
        content {
          dynamic "authentication_request_extra_params" {
            for_each = length(keys(lookup(authenticate_oidc.value, "authentication_request_extra_params", {}))) == 0 ? [] : [lookup(authenticate_oidc.value, "authentication_request_extra_params", {})]

            content {
              authentication_request_extra_params.key = authentication_request_extra_params.value
            }
          }
          authorization_endpoint     = lookup(authenticate_oidc.value, "authorization_endpoint", null)
          client_id                  = lookup(authenticate_oidc.value, "client_id", null)
          client_secret              = lookup(authenticate_oidc.value, "client_secret", null)
          issuer                     = lookup(authenticate_oidc.value, "issuer", null)
          on_unauthenticated_request = lookup(authenticate_oidc.value, "on_unauthenticated_request", null)
          scope                      = lookup(authenticate_oidc.value, "scope", null)
          session_cookie_name        = lookup(authenticate_oidc.value, "session_cookie_name", null)
          session_timeout            = lookup(authenticate_oidc.value, "session_timeout", null)
          token_endpoint             = lookup(authenticate_oidc.value, "token_endpoint", null)
          user_info_endpoint         = lookup(authenticate_oidc.value, "user_info_endpoint", null)
        }
      }
    }
  }

  default_action {
    type             = contains(["authenticate-oidc", "authenticate-cognito"], var.https_listeners[count.index]["action_type"]) ? "forward" : null
    target_group_arn = contains(["authenticate-oidc", "authenticate-cognito"], var.https_listeners[count.index]["action_type"]) ? aws_lb_target_group.main[lookup(var.https_listeners[count.index], "target_group_index", count.index)].id : null
  }
}

resource "aws_lb_listener_certificate" "https_listener" {
  count = var.create_lb ? length(var.extra_ssl_certs) : 0

  listener_arn    = aws_lb_listener.frontend_https[var.extra_ssl_certs[count.index]["https_listener_index"]].arn
  certificate_arn = var.extra_ssl_certs[count.index]["certificate_arn"]
}
