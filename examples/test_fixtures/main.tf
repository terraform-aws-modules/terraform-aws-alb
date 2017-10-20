terraform {
  required_version = "~> 0.10.6"
}

provider "aws" {
<<<<<<< HEAD
  region  = "${var.region}"
=======
  region  = "${var.aws_region}"
>>>>>>> b5a4c76cab7e5471f5af210fb858c42787453ebb
  version = "~> 1.0.0"
}

provider "template" {
  version = "~> 1.0.0"
}

resource "aws_iam_server_certificate" "fixture_cert" {
<<<<<<< HEAD
  name             = "test_cert-${data.aws_caller_identity.fixtures.account_id}-${var.region}"
=======
  name             = "test_cert-${data.aws_caller_identity.fixtures.account_id}"
>>>>>>> b5a4c76cab7e5471f5af210fb858c42787453ebb
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
<<<<<<< HEAD
  azs                = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
=======
  azs                = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
>>>>>>> b5a4c76cab7e5471f5af210fb858c42787453ebb
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
<<<<<<< HEAD
  source                   = "../../.."
  alb_name                 = "my-alb"
  alb_security_groups      = ["${module.security-group.this_security_group_id}"]
  region                   = "${var.region}"
=======
  source                   = "../../../"
  alb_name                 = "my-alb"
  alb_security_groups      = ["${module.security-group.this_security_group_id}"]
  aws_region               = "${var.aws_region}"
>>>>>>> b5a4c76cab7e5471f5af210fb858c42787453ebb
  vpc_id                   = "${module.vpc.vpc_id}"
  subnets                  = "${module.vpc.public_subnets}"
  certificate_arn          = "${aws_iam_server_certificate.fixture_cert.arn}"
  health_check_path        = "/"
<<<<<<< HEAD
  log_bucket               = "logs-${var.region}-${data.aws_caller_identity.fixtures.account_id}"
=======
  log_bucket               = "logs-${var.aws_region}-${data.aws_caller_identity.fixtures.account_id}"
>>>>>>> b5a4c76cab7e5471f5af210fb858c42787453ebb
  log_prefix               = "${var.log_prefix}"
  force_destroy_log_bucket = true

  tags {
    "Terraform" = "true"
    "Env"       = "${terraform.workspace}"
  }
}
