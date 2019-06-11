provider "aws" {
  region = var.region
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "aws_iam_server_certificate" "fixture_cert" {
  name_prefix = "test_cert-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  certificate_body = file(
    "${path.module}/../../examples/alb_test_fixture/certs/example.crt.pem",
  )
  private_key = file(
    "${path.module}/../../examples/alb_test_fixture/certs/example.key.pem",
  )

  lifecycle {
    create_before_destroy = true
  }

  count = 4
}

resource "aws_s3_bucket" "log_bucket" {
  bucket        = local.log_bucket_name
  policy        = data.aws_iam_policy_document.bucket_policy.json
  force_destroy = true
  tags          = local.tags

  lifecycle_rule {
    id      = "log-expiration"
    enabled = "true"

    expiration {
      days = "7"
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  name               = "test-vpc"
  cidr               = "10.0.0.0/16"
  azs                = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  public_subnets     = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway = false
  tags               = local.tags
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0.1"

  name   = "test-sg-https"
  vpc_id = module.vpc.vpc_id
  tags   = local.tags
}

resource "aws_autoscaling_group" "test" {
  name_prefix          = "test-alb"
  max_size             = 1
  min_size             = 1
  launch_configuration = aws_launch_configuration.as_conf.name
  health_check_type    = "EC2"
  target_group_arns    = module.alb.target_group_arns
  force_delete         = true
  vpc_zone_identifier  = module.vpc.public_subnets
}

resource "aws_launch_configuration" "test" {
  name_prefix   = "test_lc"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
}

resource "aws_launch_configuration" "as_conf" {
  name          = "web_config"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
}

module "alb" {
  source                   = "../../"
  load_balancer_name       = "test-alb-${random_string.suffix.result}"
  security_groups          = [module.security_group.this_security_group_id]
  logging_enabled          = true
  log_bucket_name          = aws_s3_bucket.log_bucket.id
  log_location_prefix      = var.log_location_prefix
  subnets                  = module.vpc.public_subnets
  tags                     = local.tags
  vpc_id                   = module.vpc.vpc_id
  https_listeners          = local.https_listeners
  https_listeners_count    = local.https_listeners_count
  http_tcp_listeners       = local.http_tcp_listeners
  http_tcp_listeners_count = local.http_tcp_listeners_count
  target_groups            = local.target_groups
  target_groups_count      = local.target_groups_count
  extra_ssl_certs          = local.extra_ssl_certs
  extra_ssl_certs_count    = local.extra_ssl_certs_count
}

