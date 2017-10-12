### ALB resources

resource "aws_alb" "main" {
  name            = "${var.alb_name}"
  subnets         = ["${var.subnets}"]
  security_groups = ["${var.alb_security_groups}"]
  internal        = "${var.alb_is_internal}"
  tags            = "${merge(var.tags, map("Name", format("%s", var.alb_name)))}"

  access_logs {
    bucket  = "${var.log_bucket}"
    prefix  = "${var.log_prefix}"
    enabled = "${var.log_bucket != ""}"
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket        = "${var.log_bucket}"
  policy        = "${var.bucket_policy == "" ? local.bucket_policy : var.bucket_policy}"
  force_destroy = "${var.force_destroy_log_bucket}"
  count         = "${var.log_bucket != "" ? 1 : 0}"
  tags          = "${merge(var.tags, map("Name", format("%s", var.log_bucket)))}"
}

resource "aws_alb_target_group" "target_group" {
  name     = "${var.alb_name}-tg"
  port     = "${var.backend_port}"
  protocol = "${upper(var.backend_protocol)}"
  vpc_id   = "${var.vpc_id}"

  health_check {
    interval            = "${var.health_check_interval}"
    path                = "${var.health_check_path}"
    port                = "${var.health_check_port}"
    healthy_threshold   = "${var.health_check_healthy_threshold}"
    unhealthy_threshold = "${var.health_check_unhealthy_threshold}"
    timeout             = "${var.health_check_timeout}"
    protocol            = "${var.backend_protocol}"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = "${var.cookie_duration}"
    enabled         = "${ var.cookie_duration == 1 ? false : true}"
  }

  tags = "${merge(var.tags, map("Name", format("%s-tg", var.alb_name)))}"
}

resource "aws_alb_listener" "front_end_http" {
  load_balancer_arn = "${aws_alb.main.arn}"
  port              = "80"
  protocol          = "HTTP"
  count             = "${contains(var.alb_protocols, "HTTP") ? 1 : 0}"

  default_action {
    target_group_arn = "${aws_alb_target_group.target_group.id}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "front_end_https" {
  load_balancer_arn = "${aws_alb.main.arn}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${var.certificate_arn}"
  ssl_policy        = "${var.security_policy}"
  count             = "${contains(var.alb_protocols, "HTTPS") ? 1 : 0}"

  default_action {
    target_group_arn = "${aws_alb_target_group.target_group.id}"
    type             = "forward"
  }
}
