# Fetch specific rules from listeners
locals {
  http_nonauth_listeners = [
    for l in var.http_tcp_listeners :
    l if l["action_type"] == "forward" || l["action_type"] == "redirect" || l["action_type"] == "fixed-response"
  ]

  http_auth_listeners = [
    for l in var.http_tcp_listeners :
    l if l["action_type"] == "authenticate-cognito" || l["action_type"] == "authenticate-oidc"
  ]

  https_nonauth_listeners = [
    for l in var.https_listeners :
    l if l["action_type"] == "forward" || l["action_type"] == "redirect" || l["action_type"] == "fixed-response"
  ]

  https_auth_listeners = [
    for l in var.https_listeners :
    l if l["action_type"] == "authenticate-cognito" || l["action_type"] == "authenticate-oidc"
  ]
}

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

resource "aws_lb_listener" "nonauth_frontend_http_tcp" {
  count = var.create_lb ? length(local.http_nonauth_listeners) : 0

  load_balancer_arn = aws_lb.this[0].arn

  port     = local.http_nonauth_listeners[count.index]["port"]
  protocol = local.http_nonauth_listeners[count.index]["protocol"]

  dynamic "default_action" {
    for_each = local.http_nonauth_listeners[count.index]["action_type"] == "forward" ? local.http_nonauth_listeners[count.index] : {}

    content {
      type             = lookup(local.http_nonauth_listeners[count.index], "action_type", null)
      target_group_arn = aws_lb_target_group.main[lookup(local.http_nonauth_listeners[count.index], "target_group_index", count.index)].id
    }
  }

  dynamic "default_action" {
    for_each = local.http_nonauth_listeners[count.index]["action_type"] == "redirect" ? local.http_nonauth_listeners[count.index] : {}
    content {
      type = lookup(local.http_nonauth_listeners[count.index], "action_type", null)
      redirect {
        path        = lookup(local.http_nonauth_listeners[count.index], "path", null)
        host        = lookup(local.http_nonauth_listeners[count.index], "host", null)
        port        = lookup(local.http_nonauth_listeners[count.index], "port", null)
        protocol    = lookup(local.http_nonauth_listeners[count.index], "protocol", null)
        query       = lookup(local.http_nonauth_listeners[count.index], "query", null)
        status_code = lookup(local.http_nonauth_listeners[count.index], "status_code", null)
      }
    }
  }

  dynamic "default_action" {
    for_each = local.http_nonauth_listeners[count.index]["action_type"] == "fixed-response" ? local.http_nonauth_listeners[count.index] : {}
    content {
      type = lookup(local.http_nonauth_listeners[count.index], "action_type", null)
      fixed_response {
        content_type = lookup(local.http_nonauth_listeners[count.index], "content_type", null)
        message_body = lookup(local.http_nonauth_listeners[count.index], "message_body", null)
        status_code  = lookup(local.http_nonauth_listeners[count.index], "status_code", null)
      }
    }
  }
}

resource "aws_lb_listener" "auth_frontend_http_tcp" {
  count = var.create_lb ? length(local.http_auth_listeners) : 0

  load_balancer_arn = aws_lb.this[0].arn

  port     = local.http_auth_listeners[count.index]["port"]
  protocol = local.http_auth_listeners[count.index]["protocol"]

  dynamic "default_action" {
    for_each = local.http_auth_listeners[count.index]["action_type"] == "authenticate-cognito" ? local.http_auth_listeners[count.index] : {}
    content {
      type = lookup(local.http_auth_listeners[count.index], "action_type", null)
      authenticate_cognito {
        on_unauthenticated_request = lookup(local.http_auth_listeners[count.index], "on_authenticated_request", null)
        scope                      = lookup(local.http_auth_listeners[count.index], "scope", null)
        session_cookie_name        = lookup(local.http_auth_listeners[count.index], "session_cookie_name", null)
        session_timeout            = lookup(local.http_auth_listeners[count.index], "session_timeout", null)
        user_pool_arn              = lookup(local.http_auth_listeners[count.index], "user_pool_arn", null)
        user_pool_client_id        = lookup(local.http_auth_listeners[count.index], "user_pool_client_id", null)
        user_pool_domain           = lookup(local.http_auth_listeners[count.index], "user_pool_domain", null)
      }
    }
  }

  dynamic "default_action" {
    for_each = local.http_auth_listeners[count.index]["action_type"] == "authenticate-oidc" ? local.http_auth_listeners[count.index] : {}
    content {
      type = lookup(local.http_auth_listeners[count.index], "action_type", null)
      authenticate_oidc {
        authorization_endpoint     = lookup(local.http_auth_listeners[count.index], "authorization_endpoint", null)
        client_id                  = lookup(local.http_auth_listeners[count.index], "client_id", null)
        client_secret              = lookup(local.http_auth_listeners[count.index], "client_secret", null)
        issuer                     = lookup(local.http_auth_listeners[count.index], "issuer", null)
        on_unauthenticated_request = lookup(local.http_auth_listeners[count.index], "on_unauthenticated_request", null)
        scope                      = lookup(local.http_auth_listeners[count.index], "scope", null)
        session_cookie_name        = lookup(local.http_auth_listeners[count.index], "session_cookie_name", null)
        session_timeout            = lookup(local.http_auth_listeners[count.index], "session_timeout", null)
        token_endpoint             = lookup(local.http_auth_listeners[count.index], "token_endpoint", null)
        user_info_endpoint         = lookup(local.http_auth_listeners[count.index], "user_info_endpoint", null)
      }
    }
  }

  default_action {
    target_group_arn = aws_lb_target_group.main[lookup(local.http_auth_listeners[count.index], "target_group_index", count.index)].id
    type             = "forward"
  }
}

resource "aws_lb_listener" "nonauth_frontend_https" {
  count = var.create_lb ? length(local.https_nonauth_listeners) : 0

  load_balancer_arn = aws_lb.this[0].arn

  port            = local.https_nonauth_listeners[count.index]["port"]
  protocol        = lookup(local.https_nonauth_listeners[count.index], "protocol", "HTTPS")
  certificate_arn = local.https_nonauth_listeners[count.index]["certificate_arn"]
  ssl_policy      = lookup(local.https_nonauth_listeners[count.index], "ssl_policy", var.listener_ssl_policy_default)

  dynamic "default_action" {
    for_each = local.https_nonauth_listeners[count.index]["action_type"] == "forward" ? local.https_nonauth_listeners[count.index] : {}

    content {
      type             = lookup(local.https_nonauth_listeners[count.index], "action_type", null)
      target_group_arn = aws_lb_target_group.main[lookup(local.https_nonauth_listeners[count.index], "target_group_index", count.index)].id
    }
  }

  dynamic "default_action" {
    for_each = local.https_nonauth_listeners[count.index]["action_type"] == "redirect" ? local.https_nonauth_listeners[count.index] : {}
    content {
      type = lookup(local.https_nonauth_listeners[count.index], "action_type", null)
      redirect {
        path        = lookup(local.https_nonauth_listeners[count.index], "path", null)
        host        = lookup(local.https_nonauth_listeners[count.index], "host", null)
        port        = lookup(local.https_nonauth_listeners[count.index], "port", null)
        protocol    = lookup(local.https_nonauth_listeners[count.index], "protocol", null)
        query       = lookup(local.https_nonauth_listeners[count.index], "query", null)
        status_code = lookup(local.https_nonauth_listeners[count.index], "status_code", null)
      }
    }
  }

  dynamic "default_action" {
    for_each = local.https_nonauth_listeners[count.index]["action_type"] == "fixed-response" ? local.https_nonauth_listeners[count.index] : {}
    content {
      type = lookup(local.https_nonauth_listeners[count.index], "action_type", null)
      fixed_response {
        content_type = lookup(local.https_nonauth_listeners[count.index], "content_type", null)
        message_body = lookup(local.https_nonauth_listeners[count.index], "message_body", null)
        status_code  = lookup(local.https_nonauth_listeners[count.index], "status_code", null)
      }
    }
  }
}

resource "aws_lb_listener" "auth_frontend_https" {
  count = var.create_lb ? length(local.https_auth_listeners) : 0

  load_balancer_arn = aws_lb.this[0].arn

  port            = local.https_auth_listeners[count.index]["port"]
  protocol        = lookup(local.https_auth_listeners[count.index], "protocol", "HTTPS")
  certificate_arn = local.https_auth_listeners[count.index]["certificate_arn"]
  ssl_policy      = lookup(local.https_auth_listeners[count.index], "ssl_policy", var.listener_ssl_policy_default)

  dynamic "default_action" {
    for_each = local.https_auth_listeners[count.index]["action_type"] == "authenticate-cognito" ? local.https_auth_listeners[count.index] : {}
    content {
      type = lookup(local.https_auth_listeners[count.index], "action_type", null)
      authenticate_cognito {
        on_unauthenticated_request = lookup(local.https_auth_listeners[count.index], "on_authenticated_request", null)
        scope                      = lookup(local.https_auth_listeners[count.index], "scope", null)
        session_cookie_name        = lookup(local.https_auth_listeners[count.index], "session_cookie_name", null)
        session_timeout            = lookup(local.https_auth_listeners[count.index], "session_timeout", null)
        user_pool_arn              = lookup(local.https_auth_listeners[count.index], "user_pool_arn", null)
        user_pool_client_id        = lookup(local.https_auth_listeners[count.index], "user_pool_client_id", null)
        user_pool_domain           = lookup(local.https_auth_listeners[count.index], "user_pool_domain", null)
      }
    }
  }

  dynamic "default_action" {
    for_each = local.https_auth_listeners[count.index]["action_type"] == "authenticate-oidc" ? local.https_auth_listeners[count.index] : {}
    content {
      type = lookup(local.https_auth_listeners[count.index], "action_type", null)
      authenticate_oidc {
        authorization_endpoint     = lookup(local.https_auth_listeners[count.index], "authorization_endpoint", null)
        client_id                  = lookup(local.https_auth_listeners[count.index], "client_id", null)
        client_secret              = lookup(local.https_auth_listeners[count.index], "client_secret", null)
        issuer                     = lookup(local.https_auth_listeners[count.index], "issuer", null)
        on_unauthenticated_request = lookup(local.https_auth_listeners[count.index], "on_unauthenticated_request", null)
        scope                      = lookup(local.https_auth_listeners[count.index], "scope", null)
        session_cookie_name        = lookup(local.https_auth_listeners[count.index], "session_cookie_name", null)
        session_timeout            = lookup(local.https_auth_listeners[count.index], "session_timeout", null)
        token_endpoint             = lookup(local.https_auth_listeners[count.index], "token_endpoint", null)
        user_info_endpoint         = lookup(local.https_auth_listeners[count.index], "user_info_endpoint", null)
      }
    }
  }

  default_action {
    target_group_arn = aws_lb_target_group.main[lookup(local.https_auth_listeners[count.index], "target_group_index", count.index)].id
    type             = "forward"
  }
}

resource "aws_lb_listener_certificate" "nonauth_https_listener" {
  count = var.create_lb ? length(var.extra_ssl_certs) : 0

  listener_arn    = aws_lb_listener.nonauth_frontend_https[var.extra_ssl_certs[count.index]["https_listener_index"]].arn
  certificate_arn = var.extra_ssl_certs[count.index]["certificate_arn"]
}

resource "aws_lb_listener_certificate" "auth_https_listener" {
  count = var.create_lb ? length(var.extra_ssl_certs) : 0

  listener_arn    = aws_lb_listener.auth_frontend_https[var.extra_ssl_certs[count.index]["https_listener_index"]].arn
  certificate_arn = var.extra_ssl_certs[count.index]["certificate_arn"]
}
