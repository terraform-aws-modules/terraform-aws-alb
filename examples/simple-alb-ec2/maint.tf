provider "aws" {
  region = "us-east-2"
}

data "aws_security_group" "default" {
  vpc_id = module.vpc.vpc_id
  name   = "default"
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

module "ec2" {
  source = "github.com/youse-seguradora/terraform-aws-ec2-instance"

  instance_count = 1

  name                        = var.ec2_name
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [data.aws_security_group.default.id]
  associate_public_ip_address = true


  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
    },
  ]

  tags = {
    "Env"      = "Private"
    "Location" = "Secret"
  }
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
  source = "github.com/youse-seguradora/terraform-aws-alb"


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
  target_count             = 1
  target_groups_arn_attach = module.alb.target_group_arns[0]
  target_id                = module.ec2.id[0]
  target_port              = 4440
}

variable "vpc_name" {}
variable "ec2_name" {}
