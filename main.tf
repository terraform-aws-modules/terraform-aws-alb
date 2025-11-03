data "aws_partition" "current" {
  count = local.create ? 1 : 0
}

locals {
  create = var.create && var.putin_khuylo
  tags   = merge(var.tags, { terraform-aws-modules = "alb" })
}

################################################################################
# Load Balancer
################################################################################

resource "aws_lb" "this" {
  count = local.create ? 1 : 0

  region = var.region

  dynamic "access_logs" {
    for_each = var.access_logs != null ? [var.access_logs] : []

    content {
      bucket  = access_logs.value.bucket
      enabled = access_logs.value.enabled
      prefix  = access_logs.value.prefix
    }
  }

  client_keep_alive = var.client_keep_alive

  dynamic "connection_logs" {
    for_each = var.connection_logs != null ? [var.connection_logs] : []

    content {
      bucket  = connection_logs.value.bucket
      enabled = connection_logs.value.enabled
      prefix  = connection_logs.value.prefix
    }
  }

  customer_owned_ipv4_pool                                     = var.customer_owned_ipv4_pool
  desync_mitigation_mode                                       = var.desync_mitigation_mode
  dns_record_client_routing_policy                             = var.dns_record_client_routing_policy
  drop_invalid_header_fields                                   = var.drop_invalid_header_fields
  enable_cross_zone_load_balancing                             = var.enable_cross_zone_load_balancing
  enable_deletion_protection                                   = var.enable_deletion_protection
  enable_http2                                                 = var.enable_http2
  enable_tls_version_and_cipher_suite_headers                  = var.enable_tls_version_and_cipher_suite_headers
  enable_waf_fail_open                                         = var.enable_waf_fail_open
  enable_xff_client_port                                       = var.enable_xff_client_port
  enable_zonal_shift                                           = var.enable_zonal_shift
  enforce_security_group_inbound_rules_on_private_link_traffic = var.enforce_security_group_inbound_rules_on_private_link_traffic
  idle_timeout                                                 = var.idle_timeout
  internal                                                     = var.internal
  ip_address_type                                              = var.ip_address_type

  dynamic "ipam_pools" {
    for_each = var.ipam_pools != null ? [var.ipam_pools] : []

    content {
      ipv4_ipam_pool_id = ipam_pools.value.ipv4_ipam_pool_id
    }
  }

  load_balancer_type = var.load_balancer_type

  dynamic "minimum_load_balancer_capacity" {
    for_each = var.minimum_load_balancer_capacity != null ? [var.minimum_load_balancer_capacity] : []

    content {
      capacity_units = minimum_load_balancer_capacity.value.capacity_units
    }
  }

  name                 = var.name
  name_prefix          = var.name_prefix
  preserve_host_header = var.preserve_host_header
  security_groups      = var.create_security_group ? concat([aws_security_group.this[0].id], var.security_groups) : var.security_groups

  dynamic "subnet_mapping" {
    for_each = var.subnet_mapping != null ? var.subnet_mapping : []

    content {
      allocation_id        = subnet_mapping.value.allocation_id
      ipv6_address         = subnet_mapping.value.ipv6_address
      private_ipv4_address = subnet_mapping.value.private_ipv4_address
      subnet_id            = subnet_mapping.value.subnet_id
    }
  }

  subnets                    = var.subnets
  tags                       = local.tags
  xff_header_processing_mode = var.xff_header_processing_mode

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    ignore_changes = [
      tags["elasticbeanstalk:shared-elb-environment-count"]
    ]
  }
}

################################################################################
# Listener(s)
################################################################################

resource "aws_lb_listener" "this" {
  for_each = { for k, v in var.listeners : k => v if local.create }

  region = var.region

  alpn_policy     = each.value.alpn_policy
  certificate_arn = each.value.certificate_arn

  dynamic "default_action" {
    for_each = each.value.authenticate_cognito != null ? [each.value.authenticate_cognito] : []

    content {
      authenticate_cognito {
        authentication_request_extra_params = default_action.value.authentication_request_extra_params
        on_unauthenticated_request          = default_action.value.on_unauthenticated_request
        scope                               = default_action.value.scope
        session_cookie_name                 = default_action.value.session_cookie_name
        session_timeout                     = default_action.value.session_timeout
        user_pool_arn                       = default_action.value.user_pool_arn
        user_pool_client_id                 = default_action.value.user_pool_client_id
        user_pool_domain                    = default_action.value.user_pool_domain
      }

      order = each.value.order
      type  = "authenticate-cognito"
    }
  }

  dynamic "default_action" {
    for_each = each.value.authenticate_oidc != null ? [each.value.authenticate_oidc] : []

    content {
      authenticate_oidc {
        authentication_request_extra_params = default_action.value.authentication_request_extra_params
        authorization_endpoint              = default_action.value.authorization_endpoint
        client_id                           = default_action.value.client_id
        client_secret                       = default_action.value.client_secret
        issuer                              = default_action.value.issuer
        on_unauthenticated_request          = default_action.value.on_unauthenticated_request
        scope                               = default_action.value.scope
        session_cookie_name                 = default_action.value.session_cookie_name
        session_timeout                     = default_action.value.session_timeout
        token_endpoint                      = default_action.value.token_endpoint
        user_info_endpoint                  = default_action.value.user_info_endpoint
      }

      order = each.value.order
      type  = "authenticate-oidc"
    }
  }

  dynamic "default_action" {
    for_each = each.value.fixed_response != null ? [each.value.fixed_response] : []

    content {
      fixed_response {
        content_type = default_action.value.content_type
        message_body = default_action.value.message_body
        status_code  = default_action.value.status_code
      }

      order = each.value.order
      type  = "fixed-response"
    }
  }

  dynamic "default_action" {
    for_each = each.value.forward != null ? [each.value.forward] : []

    content {
      order            = each.value.order
      target_group_arn = try(aws_lb_target_group.this[default_action.value.target_group_key].arn, default_action.value.target_group_arn)
      type             = "forward"
    }
  }

  dynamic "default_action" {
    for_each = each.value.weighted_forward != null ? [each.value.weighted_forward] : []

    content {
      forward {
        dynamic "target_group" {
          for_each = default_action.value.target_groups != null ? default_action.value.target_groups : []

          content {
            arn    = try(aws_lb_target_group.this[target_group.value.target_group_key].arn, target_group.value.target_group_arn)
            weight = target_group.value.weight
          }
        }

        dynamic "stickiness" {
          for_each = default_action.value.stickiness != null ? [default_action.value.stickiness] : []

          content {
            duration = stickiness.value.duration
            enabled  = stickiness.value.enabled
          }
        }
      }

      order = each.value.order
      type  = "forward"
    }
  }

  dynamic "default_action" {
    for_each = each.value.redirect != null ? [each.value.redirect] : []

    content {
      redirect {
        host        = default_action.value.host
        path        = default_action.value.path
        port        = default_action.value.port
        protocol    = default_action.value.protocol
        query       = default_action.value.query
        status_code = default_action.value.status_code
      }

      order = each.value.order
      type  = "redirect"
    }
  }

  load_balancer_arn = aws_lb.this[0].arn

  dynamic "mutual_authentication" {
    for_each = each.value.mutual_authentication != null ? [each.value.mutual_authentication] : []

    content {
      advertise_trust_store_ca_names   = mutual_authentication.value.advertise_trust_store_ca_names
      ignore_client_certificate_expiry = mutual_authentication.value.ignore_client_certificate_expiry
      mode                             = mutual_authentication.value.mode
      trust_store_arn                  = mutual_authentication.value.trust_store_arn
    }
  }

  port                                                                  = coalesce(each.value.port, var.default_port)
  protocol                                                              = coalesce(each.value.protocol, var.default_protocol)
  routing_http_request_x_amzn_mtls_clientcert_header_name               = coalesce(each.value.protocol, var.default_protocol) == "HTTPS" ? each.value.routing_http_request_x_amzn_mtls_clientcert_header_name : null
  routing_http_request_x_amzn_mtls_clientcert_issuer_header_name        = coalesce(each.value.protocol, var.default_protocol) == "HTTPS" ? each.value.routing_http_request_x_amzn_mtls_clientcert_issuer_header_name : null
  routing_http_request_x_amzn_mtls_clientcert_leaf_header_name          = coalesce(each.value.protocol, var.default_protocol) == "HTTPS" ? each.value.routing_http_request_x_amzn_mtls_clientcert_leaf_header_name : null
  routing_http_request_x_amzn_mtls_clientcert_serial_number_header_name = coalesce(each.value.protocol, var.default_protocol) == "HTTPS" ? each.value.routing_http_request_x_amzn_mtls_clientcert_serial_number_header_name : null
  routing_http_request_x_amzn_mtls_clientcert_subject_header_name       = coalesce(each.value.protocol, var.default_protocol) == "HTTPS" ? each.value.routing_http_request_x_amzn_mtls_clientcert_subject_header_name : null
  routing_http_request_x_amzn_mtls_clientcert_validity_header_name      = coalesce(each.value.protocol, var.default_protocol) == "HTTPS" ? each.value.routing_http_request_x_amzn_mtls_clientcert_validity_header_name : null
  routing_http_request_x_amzn_tls_cipher_suite_header_name              = coalesce(each.value.protocol, var.default_protocol) == "HTTPS" ? each.value.routing_http_request_x_amzn_tls_cipher_suite_header_name : null
  routing_http_request_x_amzn_tls_version_header_name                   = coalesce(each.value.protocol, var.default_protocol) == "HTTPS" ? each.value.routing_http_request_x_amzn_tls_version_header_name : null
  routing_http_response_access_control_allow_credentials_header_value   = contains(["HTTP", "HTTPS"], coalesce(each.value.protocol, var.default_protocol)) ? each.value.routing_http_response_access_control_allow_credentials_header_value : null
  routing_http_response_access_control_allow_headers_header_value       = contains(["HTTP", "HTTPS"], coalesce(each.value.protocol, var.default_protocol)) ? each.value.routing_http_response_access_control_allow_headers_header_value : null
  routing_http_response_access_control_allow_methods_header_value       = contains(["HTTP", "HTTPS"], coalesce(each.value.protocol, var.default_protocol)) ? each.value.routing_http_response_access_control_allow_methods_header_value : null
  routing_http_response_access_control_allow_origin_header_value        = contains(["HTTP", "HTTPS"], coalesce(each.value.protocol, var.default_protocol)) ? each.value.routing_http_response_access_control_allow_origin_header_value : null
  routing_http_response_access_control_expose_headers_header_value      = contains(["HTTP", "HTTPS"], coalesce(each.value.protocol, var.default_protocol)) ? each.value.routing_http_response_access_control_expose_headers_header_value : null
  routing_http_response_access_control_max_age_header_value             = contains(["HTTP", "HTTPS"], coalesce(each.value.protocol, var.default_protocol)) ? each.value.routing_http_response_access_control_max_age_header_value : null
  routing_http_response_content_security_policy_header_value            = contains(["HTTP", "HTTPS"], coalesce(each.value.protocol, var.default_protocol)) ? each.value.routing_http_response_content_security_policy_header_value : null
  routing_http_response_server_enabled                                  = contains(["HTTP", "HTTPS"], coalesce(each.value.protocol, var.default_protocol)) ? each.value.routing_http_response_server_enabled : null
  routing_http_response_strict_transport_security_header_value          = contains(["HTTP", "HTTPS"], coalesce(each.value.protocol, var.default_protocol)) ? each.value.routing_http_response_strict_transport_security_header_value : null
  routing_http_response_x_content_type_options_header_value             = contains(["HTTP", "HTTPS"], coalesce(each.value.protocol, var.default_protocol)) ? each.value.routing_http_response_x_content_type_options_header_value : null
  routing_http_response_x_frame_options_header_value                    = contains(["HTTP", "HTTPS"], coalesce(each.value.protocol, var.default_protocol)) ? each.value.routing_http_response_x_frame_options_header_value : null
  ssl_policy                                                            = contains(["HTTPS", "TLS"], coalesce(each.value.protocol, var.default_protocol)) ? coalesce(each.value.ssl_policy, "ELBSecurityPolicy-TLS13-1-3-2021-06") : each.value.ssl_policy
  tcp_idle_timeout_seconds                                              = coalesce(each.value.protocol, var.default_protocol) == "TCP" ? each.value.tcp_idle_timeout_seconds : null

  tags = merge(
    local.tags,
    each.value.tags,
  )
}

################################################################################
# Listener Rule(s)
################################################################################

locals {
  # This allows rules to be specified under the listener definition
  listener_rules = flatten([
    for listener_key, listener_values in var.listeners : [
      for rule_key, rule_values in listener_values.rules :
      merge(rule_values, {
        listener_key = listener_key
        rule_key     = rule_key
      })
    ]
  ])
}

resource "aws_lb_listener_rule" "this" {
  for_each = { for v in local.listener_rules : "${v.listener_key}/${v.rule_key}" => v if local.create }

  region = var.region

  # Authenticate OIDC
  dynamic "action" {
    for_each = [for action in each.value.actions : action if action.authenticate_cognito != null]

    content {
      dynamic "authenticate_cognito" {
        for_each = [action.value.authenticate_cognito]

        content {
          authentication_request_extra_params = authenticate_cognito.value.authentication_request_extra_params
          on_unauthenticated_request          = authenticate_cognito.value.on_unauthenticated_request
          scope                               = authenticate_cognito.value.scope
          session_cookie_name                 = authenticate_cognito.value.session_cookie_name
          session_timeout                     = authenticate_cognito.value.session_timeout
          user_pool_arn                       = authenticate_cognito.value.user_pool_arn
          user_pool_client_id                 = authenticate_cognito.value.user_pool_client_id
          user_pool_domain                    = authenticate_cognito.value.user_pool_domain
        }
      }

      order = action.value.order
      type  = "authenticate-cognito"
    }
  }

  # Authenticate OIDC
  dynamic "action" {
    for_each = [for action in each.value.actions : action if action.authenticate_oidc != null]

    content {
      dynamic "authenticate_oidc" {
        for_each = [action.value.authenticate_oidc]

        content {
          authentication_request_extra_params = authenticate_oidc.value.authentication_request_extra_params
          authorization_endpoint              = authenticate_oidc.value.authorization_endpoint
          client_id                           = authenticate_oidc.value.client_id
          client_secret                       = authenticate_oidc.value.client_secret
          issuer                              = authenticate_oidc.value.issuer
          on_unauthenticated_request          = authenticate_oidc.value.on_unauthenticated_request
          scope                               = authenticate_oidc.value.scope
          session_cookie_name                 = authenticate_oidc.value.session_cookie_name
          session_timeout                     = authenticate_oidc.value.session_timeout
          token_endpoint                      = authenticate_oidc.value.token_endpoint
          user_info_endpoint                  = authenticate_oidc.value.user_info_endpoint
        }
      }

      order = action.value.order
      type  = "authenticate-oidc"
    }
  }

  # Fixed response
  dynamic "action" {
    for_each = [for action in each.value.actions : action if action.fixed_response != null]

    content {
      dynamic "fixed_response" {
        for_each = [action.value.fixed_response]

        content {
          content_type = fixed_response.value.content_type
          message_body = fixed_response.value.message_body
          status_code  = fixed_response.value.status_code
        }
      }

      order = action.value.order
      type  = "fixed-response"
    }
  }

  # Forward
  dynamic "action" {
    for_each = [for action in each.value.actions : action if action.forward != null]

    content {
      order            = action.value.order
      target_group_arn = try(aws_lb_target_group.this[action.value.forward.target_group_key].arn, action.value.forward.target_group_arn)
      type             = "forward"
    }
  }

  # Redirect
  dynamic "action" {
    for_each = [for action in each.value.actions : action if action.redirect != null]

    content {
      dynamic "redirect" {
        for_each = [action.value.redirect]

        content {
          host        = redirect.value.host
          path        = redirect.value.path
          port        = redirect.value.port
          protocol    = redirect.value.protocol
          query       = redirect.value.query
          status_code = redirect.value.status_code
        }
      }

      order = action.value.order
      type  = "redirect"
    }
  }

  # Weighted forward
  dynamic "action" {
    for_each = [for action in each.value.actions : action if action.weighted_forward != null]

    content {
      dynamic "forward" {
        for_each = [action.value.weighted_forward]

        content {
          dynamic "stickiness" {
            for_each = forward.value.stickiness != null ? [forward.value.stickiness] : []

            content {
              duration = stickiness.value.duration
              enabled  = stickiness.value.enabled
            }
          }

          dynamic "target_group" {
            for_each = forward.value.target_groups

            content {
              arn    = try(aws_lb_target_group.this[target_group.value.target_group_key].arn, target_group.value.target_group_arn)
              weight = target_group.value.weight
            }
          }
        }
      }

      order = action.value.order
      type  = "forward"
    }
  }

  dynamic "condition" {
    for_each = each.value.conditions

    content {
      dynamic "host_header" {
        for_each = condition.value.host_header != null ? [condition.value.host_header] : []

        content {
          values       = host_header.value.values
          regex_values = host_header.value.regex_values
        }
      }

      dynamic "http_header" {
        for_each = condition.value.http_header != null ? [condition.value.http_header] : []

        content {
          http_header_name = http_header.value.http_header_name
          values           = http_header.value.values
          regex_values     = http_header.value.regex_values
        }
      }

      dynamic "http_request_method" {
        for_each = condition.value.http_request_method != null ? [condition.value.http_request_method] : []

        content {
          values = http_request_method.value.values
        }
      }

      dynamic "path_pattern" {
        for_each = condition.value.path_pattern != null ? [condition.value.path_pattern] : []

        content {
          values       = path_pattern.value.values
          regex_values = path_pattern.value.regex_values
        }
      }

      dynamic "query_string" {
        for_each = condition.value.query_string != null ? condition.value.query_string : []

        content {
          key   = query_string.value.key
          value = query_string.value.value
        }
      }

      dynamic "source_ip" {
        for_each = condition.value.source_ip != null ? [condition.value.source_ip] : []

        content {
          values = source_ip.value.values
        }
      }
    }
  }

  listener_arn = try(aws_lb_listener.this[each.value.listener_key].arn, each.value.listener_arn)
  priority     = each.value.priority

  dynamic "transform" {
    for_each = each.value.transform != null ? each.value.transform : {}

    content {
      type = coalesce(transform.value.type, transform.key)

      dynamic "host_header_rewrite_config" {
        for_each = transform.value.host_header_rewrite_config != null ? [transform.value.host_header_rewrite_config] : []

        content {

          dynamic "rewrite" {
            for_each = host_header_rewrite_config.value.rewrite != null ? [host_header_rewrite_config.value.rewrite] : []

            content {
              regex   = rewrite.value.regex
              replace = rewrite.value.replace
            }
          }
        }
      }
      dynamic "url_rewrite_config" {
        for_each = transform.value.url_rewrite_config != null ? [transform.value.url_rewrite_config] : []

        content {

          dynamic "rewrite" {
            for_each = url_rewrite_config.value.rewrite != null ? [url_rewrite_config.value.rewrite] : []

            content {
              regex   = rewrite.value.regex
              replace = rewrite.value.replace
            }
          }
        }
      }
    }
  }

  tags = merge(
    local.tags,
    each.value.tags,
  )
}

################################################################################
# Certificate(s)
################################################################################

locals {
  # Take the list of `additional_certificate_arns` from the listener and create
  # a map entry that maps each certificate to the listener key. This map of maps
  # is then used to create the certificate resources.
  additional_certs = merge(values({
    for listener_key, listener_values in var.listeners : listener_key =>
    {
      # This will cause certs to be detached and reattached if certificate_arns
      # towards the front of the list are updated/removed. However, we need to have
      # unique keys on the resulting map and we can't have computed values (i.e. cert ARN)
      # in the key so we are using the array index as part of the key.
      for idx, cert_arn in listener_values.additional_certificate_arns :
      "${listener_key}/${idx}" => {
        listener_key    = listener_key
        certificate_arn = cert_arn
      }
    } if length(listener_values.additional_certificate_arns) > 0
  })...)
}

resource "aws_lb_listener_certificate" "this" {
  for_each = { for k, v in local.additional_certs : k => v if local.create }

  region = var.region

  listener_arn    = aws_lb_listener.this[each.value.listener_key].arn
  certificate_arn = each.value.certificate_arn
}

################################################################################
# Target Group(s)
################################################################################

resource "aws_lb_target_group" "this" {
  for_each = local.create && var.target_groups != null ? var.target_groups : {}

  region = var.region

  connection_termination = each.value.connection_termination
  deregistration_delay   = each.value.deregistration_delay

  dynamic "health_check" {
    for_each = each.value.health_check != null ? [each.value.health_check] : []

    content {
      enabled             = health_check.value.enabled
      healthy_threshold   = health_check.value.healthy_threshold
      interval            = health_check.value.interval
      matcher             = health_check.value.matcher
      path                = health_check.value.path
      port                = health_check.value.port
      protocol            = health_check.value.protocol
      timeout             = health_check.value.timeout
      unhealthy_threshold = health_check.value.unhealthy_threshold
    }
  }

  ip_address_type                    = each.value.ip_address_type
  lambda_multi_value_headers_enabled = each.value.lambda_multi_value_headers_enabled
  load_balancing_algorithm_type      = each.value.load_balancing_algorithm_type
  load_balancing_anomaly_mitigation  = each.value.load_balancing_anomaly_mitigation
  load_balancing_cross_zone_enabled  = each.value.load_balancing_cross_zone_enabled
  name                               = each.value.name
  name_prefix                        = each.value.name_prefix
  port                               = each.value.target_type == "lambda" ? null : coalesce(each.value.port, var.default_port)
  preserve_client_ip                 = each.value.preserve_client_ip
  protocol                           = each.value.target_type == "lambda" ? null : coalesce(each.value.protocol, var.default_protocol)
  protocol_version                   = each.value.protocol_version
  proxy_protocol_v2                  = each.value.proxy_protocol_v2
  slow_start                         = each.value.slow_start

  dynamic "stickiness" {
    for_each = each.value.stickiness != null ? [each.value.stickiness] : []

    content {
      cookie_duration = stickiness.value.cookie_duration
      cookie_name     = stickiness.value.cookie_name
      enabled         = stickiness.value.enabled
      type            = stickiness.value.type
    }
  }

  dynamic "target_failover" {
    for_each = each.value.target_failover != null ? each.value.target_failover : []

    content {
      on_deregistration = target_failover.value.on_deregistration
      on_unhealthy      = target_failover.value.on_unhealthy
    }
  }

  dynamic "target_group_health" {
    for_each = each.value.target_group_health != null ? [each.value.target_group_health] : []

    content {
      dynamic "dns_failover" {
        for_each = target_group_health.value.dns_failover != null ? [target_group_health.value.dns_failover] : []

        content {
          minimum_healthy_targets_count      = dns_failover.value.minimum_healthy_targets_count
          minimum_healthy_targets_percentage = dns_failover.value.minimum_healthy_targets_percentage
        }
      }

      dynamic "unhealthy_state_routing" {
        for_each = target_group_health.value.unhealthy_state_routing != null ? [target_group_health.value.unhealthy_state_routing] : []

        content {
          minimum_healthy_targets_count      = unhealthy_state_routing.value.minimum_healthy_targets_count
          minimum_healthy_targets_percentage = unhealthy_state_routing.value.minimum_healthy_targets_percentage
        }
      }
    }
  }

  dynamic "target_health_state" {
    for_each = each.value.target_health_state != null ? [each.value.target_health_state] : []

    content {
      enable_unhealthy_connection_termination = target_health_state.value.enable_unhealthy_connection_termination
      unhealthy_draining_interval             = target_health_state.value.unhealthy_draining_interval
    }
  }

  target_type = each.value.target_type
  vpc_id      = coalesce(each.value.vpc_id, var.vpc_id)

  tags = merge(
    local.tags,
    each.value.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Target Group Attachment
################################################################################

resource "aws_lb_target_group_attachment" "this" {
  for_each = local.create && var.target_groups != null ? { for k, v in var.target_groups : k => v if v.create_attachment } : {}

  region = var.region

  target_group_arn  = aws_lb_target_group.this[each.key].arn
  target_id         = each.value.target_id
  port              = each.value.target_type == "lambda" ? null : coalesce(each.value.port, var.default_port)
  availability_zone = each.value.availability_zone

  depends_on = [aws_lambda_permission.this]
}

resource "aws_lb_target_group_attachment" "additional" {
  for_each = local.create && var.additional_target_group_attachments != null ? var.additional_target_group_attachments : {}

  region = var.region

  target_group_arn  = aws_lb_target_group.this[each.value.target_group_key].arn
  target_id         = each.value.target_id
  port              = each.value.target_type == "lambda" ? null : coalesce(each.value.port, var.default_port)
  availability_zone = each.value.availability_zone

  depends_on = [aws_lambda_permission.this]
}

################################################################################
# Lambda Permission
################################################################################

# Filter out the attachments for lambda functions. The ALB target group needs
# permission to forward a request on to # the specified lambda function.
# This filtered list is used to create those permission resources. # To get the
# lambda_function_name, the 6th index is taken from the function ARN format below
# arn:aws:lambda:<region>:<account-id>:function:my-function-name:<version-number>
locals {
  lambda_target_groups = var.target_groups != null ? {
    for k, v in var.target_groups :
    (k) => merge(v, { lambda_function_name = split(":", v.target_id)[6] })
    if v.attach_lambda_permission
  } : {}
}

resource "aws_lambda_permission" "this" {
  for_each = { for k, v in local.lambda_target_groups : k => v if local.create }

  region = var.region

  function_name = each.value.lambda_function_name
  qualifier     = each.value.lambda_qualifier

  statement_id       = coalesce(each.value.lambda_statement_id, "AllowExecutionFromLb")
  action             = coalesce(each.value.lambda_action, "lambda:InvokeFunction")
  principal          = coalesce(each.value.lambda_principal, "elasticloadbalancing.${try(data.aws_partition.current[0].dns_suffix, "")}")
  source_arn         = aws_lb_target_group.this[each.key].arn
  source_account     = each.value.lambda_source_account
  event_source_token = each.value.lambda_event_source_token
}

################################################################################
# Security Group
################################################################################

locals {
  create_security_group = local.create && var.create_security_group
  security_group_name   = try(coalesce(var.security_group_name, var.name, var.name_prefix), "")
}

resource "aws_security_group" "this" {
  count = local.create_security_group ? 1 : 0

  region = var.region

  name        = var.security_group_use_name_prefix ? null : local.security_group_name
  name_prefix = var.security_group_use_name_prefix ? "${local.security_group_name}-" : null
  description = coalesce(var.security_group_description, "Security group for ${local.security_group_name} ${var.load_balancer_type} load balancer")
  vpc_id      = var.vpc_id

  tags = merge(local.tags, var.security_group_tags)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = local.create_security_group && var.security_group_ingress_rules != null ? var.security_group_ingress_rules : {}

  region = var.region

  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  description                  = each.value.description
  from_port                    = each.value.from_port
  ip_protocol                  = each.value.ip_protocol
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id
  security_group_id            = aws_security_group.this[0].id
  tags = merge(
    var.tags,
    var.security_group_tags,
    { "Name" = coalesce(each.value.name, "${local.security_group_name}-${each.key}") },
    each.value.tags
  )
  to_port = try(coalesce(each.value.to_port, each.value.from_port), null)
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = local.create_security_group && var.security_group_egress_rules != null ? var.security_group_egress_rules : {}

  region = var.region

  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  description                  = each.value.description
  from_port                    = try(coalesce(each.value.from_port, each.value.to_port), null)
  ip_protocol                  = each.value.ip_protocol
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id
  security_group_id            = aws_security_group.this[0].id
  tags = merge(
    var.tags,
    var.security_group_tags,
    { "Name" = coalesce(each.value.name, "${local.security_group_name}-${each.key}") },
    each.value.tags
  )
  to_port = each.value.to_port
}

################################################################################
# Route53 Record(s)
################################################################################

resource "aws_route53_record" "this" {
  for_each = var.create && var.route53_records != null ? var.route53_records : {}

  zone_id = each.value.zone_id
  name    = coalesce(each.value.name, each.key)
  type    = each.value.type

  alias {
    name                   = aws_lb.this[0].dns_name
    zone_id                = aws_lb.this[0].zone_id
    evaluate_target_health = each.value.evaluate_target_health
  }
}

################################################################################
# WAF
################################################################################

resource "aws_wafv2_web_acl_association" "this" {
  count = var.associate_web_acl ? 1 : 0

  region = var.region

  resource_arn = aws_lb.this[0].arn
  web_acl_arn  = var.web_acl_arn
}
