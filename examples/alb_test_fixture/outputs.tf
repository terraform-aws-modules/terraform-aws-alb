output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "region" {
  value = "${var.region}"
}

output "sg_id" {
  value = "${module.security_group.this_security_group_id}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "alb_id" {
  value = "${module.alb.lb_id}"
}

output "http_tcp_listener_arns" {
  value = "${module.alb.http_tcp_listener_arns}"
}

output "https_listener_arns" {
  value = "${module.alb.https_listener_arns}"
}
