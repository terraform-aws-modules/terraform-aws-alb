data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "aws_region" "current" {}

data "aws_elb_service_account" "main" {}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid       = "AllowToPutLoadBalancerLogsToS3Bucket"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.log_bucket_name}/${var.log_location_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_elb_service_account.main.id}:root"]
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
