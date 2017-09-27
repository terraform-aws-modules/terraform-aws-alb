/*
Outputs used for tests
*/

output "principal_account_id" {
  value = "${module.alb.principal_account_id}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "sg_id" {
  value = "${module.sg_https_web.security_group_id_web}"
}

output "account_id" {
  value = "${data.aws_caller_identity.fixtures.account_id}"
}
