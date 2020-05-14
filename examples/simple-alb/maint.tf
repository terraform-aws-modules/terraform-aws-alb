provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "allows_tls"
  }
  depends_on = [module.vpc]
}

module "vpc" {
  source = "github.com/youse-seguradora/terraform-aws-vpc"

  name = var.vpc_name

  cidr = "10.120.0.0/16"

  azs                    = ["us-east-1a", "us-east-1c"]
  compute_public_subnets = ["10.120.0.0/24", "10.120.5.0/24"]
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "sg_ids" {
  value = aws_security_group.sg.id
}


module "alb" {
  source = "../../"


  name = "my-alb"

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.sg.id]

  target_groups = [
    {
      name_prefix      = "test"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
}

variable "vpc_name" {}
