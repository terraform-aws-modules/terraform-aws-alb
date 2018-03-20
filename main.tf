locals {
  prefix_length = "${length(var.lb_name) < 6 ? length(var.lb_name) : 6 }"
  name_prefix   = "${substr(var.lb_name, 0, local.prefix_length)}"
}

resource "aws_lb" "main" {
  name_prefix                      = "${local.name_prefix}"
  internal                         = "${var.lb_is_internal}"
  load_balancer_type               = "${var.load_balancer_type}"
  security_groups                  = ["${var.lb_security_groups}"]
  subnets                          = ["${var.subnets}"]
  idle_timeout                     = "${var.idle_timeout}"
  enable_cross_zone_load_balancing = "${var.enable_cross_zone_load_balancing}"
  enable_deletion_protection       = "${var.enable_deletion_protection}"
  enable_http2                     = "${var.enable_http2}"
  ip_address_type                  = "${var.ip_address_type}"
  tags                             = "${merge(var.tags, map("Name", var.lb_name))}"

  access_logs {
    enabled = true
    bucket  = "${var.log_bucket_name}"
    prefix  = "${var.log_location_prefix}"
  }

  #XXX can these be defined?
  #  subnet_mapping {
  #    subnet_id     = "${}"
  #    allocation_id = "${}"
  #  }

  timeouts {
    create = "${var.load_balancer_create_timeout}"
    delete = "${var.load_balancer_delete_timeout}"
    update = "${var.load_balancer_update_timeout}"
  }
}

resource "aws_lb_target_group" "target_group" {
  name                 = "${lookup(var.target_groups[count.index], "name")}"
  vpc_id               = "${var.vpc_id}"
  port                 = "${lookup(var.target_groups[count.index], "backend_port")}"
  protocol             = "${upper(lookup(var.target_groups[count.index], "backend_protocol"))}"
  deregistration_delay = "${lookup(var.target_groups[count.index], "deregistration_delay", lookup(var.target_groups_defaults, "deregistration_delay"))}"
  target_type          = "${lookup(var.target_groups[count.index], "target_type", lookup(var.target_groups_defaults, "target_type"))}"

  health_check {
    interval            = "${lookup(var.target_groups[count.index], "health_check_interval", lookup(var.target_groups_defaults, "health_check_interval"))}"
    path                = "${lookup(var.target_groups[count.index], "health_check_path", lookup(var.target_groups_defaults, "health_check_path"))}"
    port                = "${lookup(var.target_groups[count.index], "health_check_port", lookup(var.target_groups_defaults, "health_check_port"))}"
    healthy_threshold   = "${lookup(var.target_groups[count.index], "health_check_healthy_threshold", lookup(var.target_groups_defaults, "health_check_healthy_threshold"))}"
    unhealthy_threshold = "${lookup(var.target_groups[count.index], "health_check_unhealthy_threshold", lookup(var.target_groups_defaults, "health_check_unhealthy_threshold"))}"
    timeout             = "${lookup(var.target_groups[count.index], "health_check_timeout", lookup(var.target_groups_defaults, "health_check_timeout"))}"
    protocol            = "${upper(lookup(var.target_groups[count.index], "healthcheck_protocol", lookup(var.target_groups[count.index], "backend_protocol")))}"
    matcher             = "${lookup(var.target_groups[count.index], "health_check_matcher", lookup(var.target_groups_defaults, "health_check_matcher"))}"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = "${lookup(var.target_groups[count.index], "cookie_duration", lookup(var.target_groups_defaults, "cookie_duration"))}"
    enabled         = "${lookup(var.target_groups[count.index], "stickiness_enabled", lookup(var.target_groups_defaults, "stickiness_enabled"))}"
  }

  tags       = "${merge(var.tags, map("Name", lookup(var.target_groups[count.index], "name")))}"
  count      = "${var.target_groups_count}"
  depends_on = ["aws_lb.main"]
}

resource "aws_lb_listener" "frontend_http_tcp" {
  load_balancer_arn = "${aws_lb.main.arn}"
  port              = "${lookup(var.http_tcp_listeners[count.index], "port")}"
  protocol          = "${lookup(var.http_tcp_listeners[count.index], "protocol")}"
  count             = "${var.http_tcp_listeners_count}"

  default_action {
    target_group_arn = "${aws_lb_target_group.target_group.*.id[lookup(var.http_tcp_listeners[count.index], "target_group_index")]}"
    type             = "forward"
  }

  depends_on = ["aws_lb.main"]
}

resource "aws_lb_listener" "frontend_https" {
  load_balancer_arn = "${aws_lb.main.arn}"
  port              = "${lookup(var.https_listeners[count.index], "port")}"
  protocol          = "HTTPS"
  certificate_arn   = "${lookup(var.https_listeners[count.index], "certificate_arn")}"
  ssl_policy        = "${lookup(var.https_listeners[count.index], "ssl_policy", var.listener_ssl_policy_default)}"
  count             = "${var.https_listeners_count}"

  default_action {
    target_group_arn = "${aws_lb_target_group.target_group.*.id[lookup(var.https_listeners[count.index], "target_group_index")]}"
    type             = "forward"
  }

  depends_on = ["aws_lb.main"]
}
