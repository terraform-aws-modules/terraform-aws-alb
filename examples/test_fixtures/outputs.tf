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
