terraform {
  required_version = "~> 0.10.6"
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.0.0"
}

provider "template" {
  version = "~> 1.0.0"
}

resource "aws_iam_server_certificate" "fixture_cert" {
  name             = "test_cert-${data.aws_caller_identity.fixtures.account_id}"
  certificate_body = "${file("${path.module}/../../../examples/test_fixtures/certs/example.crt.pem")}"
  private_key      = "${file("${path.module}/../../../examples/test_fixtures/certs/example.key.pem")}"

  lifecycle {
    create_before_destroy = true
  }
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  name               = "my-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = {}
}

module "security-group" {
  source = "terraform-aws-modules/security-group/aws"
  name   = "my-sg-https"
  vpc_id = "${module.vpc.vpc_id}"
}

module "alb" {
  source                   = "../../../"
  alb_name                 = "my-alb"
  alb_security_groups      = ["${module.security-group.this_security_group_id}"]
  aws_region               = "${var.aws_region}"
  vpc_id                   = "${module.vpc.vpc_id}"
  subnets                  = "${module.vpc.public_subnets}"
  certificate_arn          = "${aws_iam_server_certificate.fixture_cert.arn}"
  health_check_path        = "/"
  log_bucket               = "logs-${var.aws_region}-${data.aws_caller_identity.fixtures.account_id}"
  log_prefix               = "${var.log_prefix}"
  force_destroy_log_bucket = true

  tags {
    "Terraform" = "true"
    "Env"       = "${terraform.workspace}"
  }
}
