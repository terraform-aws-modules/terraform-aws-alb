output "alb_id" {
  value = "${module.alb.load_balancer_id}"
}

output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "http_tcp_listener_arns" {
  value = "${module.alb.http_tcp_listener_arns}"
}

output "https_listener_arns" {
  value = "${module.alb.https_listener_arns}"
}

output "region" {
  value = "${var.region}"
}

output "sg_id" {
  value = "${module.security_group.this_security_group_id}"
}

output "target_group_arns" {
  value = "${module.alb.target_group_arns}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "target_groups_count" {
  value = "${local.target_groups_count}"
}

output "https_listeners_count" {
  value = "${local.https_listeners_count}"
}

output "http_tcp_listeners_count" {
  value = "${local.http_tcp_listeners_count}"
}
