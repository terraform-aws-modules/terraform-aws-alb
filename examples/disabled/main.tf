provider "aws" {
  region = "eu-west-1"
}

##########################################
# LB WILL NOT be created by this example
##########################################
module "lb_disabled" {
  source = "../../"

  create_lb = false
}
