data "aws_caller_identity" "this" {}

data "aws_elb_service_account" "main" {}

data "template_file" "bucket_policy" {
  template = "${file("${path.module}/bucket_policy.json")}"

  vars {
    log_bucket           = "${var.log_bucket}"
    log_prefix           = "${var.log_prefix}"
    account_id           = "${data.aws_caller_identity.this.account_id}"
    principal_account_id = "${data.aws_elb_service_account.main.id}"
  }
}
