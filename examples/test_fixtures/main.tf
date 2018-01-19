terraform {
  required_version = ">= 0.11.2"
}

locals {
  tags = "${map("Environment", "test", "GithubRepo", "tf-aws-alb", "GithubOrg", "terraform-aws-modules", "Workspace", "${terraform.workspace}")}"
}

provider "aws" {
  version = ">= 1.0.0"
  region  = "${var.region}"
}

resource "aws_iam_server_certificate" "fixture_cert" {
  name             = "test_cert-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  certificate_body = "${file("${path.module}/../../examples/test_fixtures/certs/example.crt.pem")}"
  private_key      = "${file("${path.module}/../../examples/test_fixtures/certs/example.key.pem")}"

  lifecycle {
    create_before_destroy = true
  }
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "1.14.0"
  name               = "test-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = "${local.tags}"
}

module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "1.12.0"
  name    = "test-sg-https"
  vpc_id  = "${module.vpc.vpc_id}"
  tags    = "${local.tags}"
}

module "alb" {
  source                   = "../.."
  alb_protocols            = ["HTTPS"]
  alb_name                 = "test-alb"
  alb_security_groups      = ["${module.security-group.this_security_group_id}"]
  certificate_arn          = "${aws_iam_server_certificate.fixture_cert.arn}"
  create_log_bucket        = true
  enable_logging           = true
  force_destroy_log_bucket = true
  health_check_path        = "/"
  log_bucket_name          = "logs-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"
  log_location_prefix      = "${var.log_location_prefix}"
  subnets                  = "${module.vpc.public_subnets}"
  tags                     = "${local.tags}"
  vpc_id                   = "${module.vpc.vpc_id}"
}
