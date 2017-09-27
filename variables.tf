/*
Module variables
*/

variable "alb_is_internal" {
  description = "Determines if the ALB is internal. Default: false"
  default     = false
}

variable "alb_name" {
  description = "The name of the ALB as will show in the AWS EC2 ELB console."
  default     = "my-alb"
}

variable "alb_protocols" {
  description = "A comma delimited list of the protocols the ALB accepts. e.g.: HTTPS"
  default     = "HTTPS"
}

variable "alb_security_groups" {
  description = "A comma separated string of security groups with which we associate the ALB. e.g. 'sg-edcd9784,sg-edcd9785'"
  type        = "list"
}

variable "aws_region" {
  description = "AWS region to use."
}

variable "backend_port" {
  description = "The port the service on the EC2 instances listen on."
  default     = 80
}

variable "backend_protocol" {
  description = "The protocol the backend service speaks. Options: HTTP, HTTPS, TCP, SSL (secure tcp)."
  default     = "HTTP"
}

variable "certificate_arn" {
  description = "The ARN of the SSL Certificate. e.g. 'arn:aws:iam::123456789012:server-certificate/ProdServerCert'"
}

variable "cookie_duration" {
  description = "If load balancer connection stickiness is desired, set this to the duration that cookie should be valid. If no stickiness is wanted, leave it blank. e.g.: 300"
  default     = "1"
}

variable "health_check_path" {
  description = "The URL the ELB should use for health checks. e.g. /health"
  default     = "/"
}

variable "log_bucket" {
  description = "S3 bucket for storing ALB access logs."
  default     = ""
}

variable "log_prefix" {
  description = "S3 prefix within the log_bucket under which logs are stored."
  default     = ""
}

variable "security_policy" {
  description = "The security policy if using HTTPS externally on the ALB. See: https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html"
  default     = "ELBSecurityPolicy-2016-08"
}

variable "subnets" {
  description = "A list of subnets to associate with the ALB. e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f']"
  type        = "list"
}

variable "vpc_id" {
  description = "VPC id where the ALB and other resources will be deployed."
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}
