provider "aws" {
  region = "eu-west-1"
}

##########################################
# ALB WILL NOT be created by this example
##########################################
module "alb_disabled" {
  source = "../../"

  create_alb = false

  load_balancer_name = "disabled-alb"
  vpc_id             = "vpc-12345678"
  security_groups    = ["sg-12345678"]
  subnets            = ["subnet-12345678"]
}

