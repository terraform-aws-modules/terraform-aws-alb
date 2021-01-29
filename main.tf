
locals{
    subnet_ids_string = join(",", data.aws_subnet_ids.public.ids)
  subnet_ids_list = split(",", local.subnet_ids_string)

}

#############################################################
# Data sources to get VPC Details
##############################################################
data "aws_vpc" "usbank_vpc" {
  filter {
    name = "tag:Name"
    values = ["bankus_east-1-vpc"]
  }
}


##############################################################
# Data sources to get subnets
##############################################################

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.usbank_vpc.id
 tags = {
    Name = "bankus_east-1-vpc-public-*"
 }

  # tags = {
  # Name = "bankus_east-1-vpc-db-us-east-1a",
  # Name = "bankus_east-1-vpc-db-us-east-1c",  # insert value here

}

data "aws_subnet" "public" {
  vpc_id = data.aws_vpc.usbank_vpc.id
  count = length(data.aws_subnet_ids.public.ids)
  id    = local.subnet_ids_list[count.index]
}

data "aws_security_group" "this" {
  vpc_id = data.aws_vpc.usbank_vpc.id
  tags = {
  Name = "usbank-appserv"
  }
}

########################################################################################################################################
##Give Bucket Permission and allow access for the ELB
##################################################################################################################################################
#data "aws_elb_service_account" "main" {}

# data "aws_iam_policy_document" "s3_lb_write" {
#     policy_id = "s3_lb_write"

#     statement {
#         actions = ["s3:PutObject","s3:ListBucket"]
#         resources = ["arn:aws:s3:::usbank-elb-bucket/logs/*"]

#         principals {
#             identifiers = [data.aws_elb_service_account.main.arn]
#             type = "AWS"
#         }
#     }
# }

# resource "aws_s3_bucket" "elb_logs" {
#   bucket = "usbank-elb-bucket"
#   acl    = "private"

# }



resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.this.id]
  subnets            = data.aws_subnet_ids.public.ids

    enable_deletion_protection = true

  # access_logs {
  #   #bucket = aws_s3_bucket.elb_logs.bucket
  #   bucket = aws_s3_bucket.elb_logs.id
  #   prefix  = "logs"
  #   enabled = true
  # }

  tags = {
    Environment = "production",
    Name = "alb"
  }

}

resource "aws_lb_target_group" "test" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.usbank_vpc.id
  tags = {
    Environment = "production",
    Name = "alb-tgt"
  }
}
