variable "alb_is_internal" {
  description = "Boolean determining if the ALB is internal or externally facing."
  default     = false
}

variable "alb_name" {
  description = "The name of the ALB as will show in the AWS EC2 ELB console."
}

variable "alb_protocols" {
  description = "The protocols the ALB accepts. e.g.: [\"HTTP\"]"
  type        = "list"
  default     = ["HTTP"]
}

variable "alb_security_groups" {
  description = "The security groups with which we associate the ALB. e.g. [\"sg-edcd9784\",\"sg-edcd9785\"]"
  type        = "list"
}

variable "region" {
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

variable "bucket_policy" {
  description = "An S3 bucket policy to apply to the log bucket. If not provided, a minimal policy will be generated from other variables."
  default     = ""
}

variable "certificate_arn" {
  description = "The ARN of the SSL Certificate. e.g. \"arn:aws:iam::123456789012:server-certificate/ProdServerCert\""
}

variable "cookie_duration" {
  description = "If load balancer connection stickiness is desired, set this to the duration in seconds that cookie should be valid (e.g. 300). Otherwise, if no stickiness is desired, leave the default."
  default     = 1
}

variable "force_destroy_log_bucket" {
  description = "If set to true and if the log bucket already exists, it will be destroyed and recreated."
  default     = false
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive positive health checks before a backend instance is considered healthy."
  default     = 3
}

variable "health_check_interval" {
  description = "Interval in seconds on which the health check against backend hosts is tried."
  default     = 10
}

variable "health_check_path" {
  description = "The URL the ELB should use for health checks. e.g. /health"
}

variable "health_check_port" {
  description = "The port used by the health check if different from the traffic-port."
  default     = "traffic-port"
}

variable "health_check_timeout" {
  description = "Seconds to leave a health check waiting before terminating it and calling the check unhealthy."
  default     = 5
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive positive health checks before a backend instance is considered unhealthy."
  default     = 3
}

variable "health_check_matcher" {
  description = "The HTTP codes that are a success when checking TG health."
  default     = "200-299"
}

variable "create_log_bucket" {
  description = "Create the S3 bucket (named with the log_bucket_name var) and attach a policy to allow ALB logging."
  default     = false
}

variable "enable_logging" {
  default     = false
  description = "Enable the ALB to write log entries to S3."
}

variable "log_bucket_name" {
  description = "S3 bucket for storing ALB access logs. To create the bucket \"create_log_bucket\" should be set to true."
  default     = ""
}

variable "log_location_prefix" {
  description = "S3 prefix within the log_bucket_name under which logs are stored."
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

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "vpc_id" {
  description = "VPC id where the ALB and other resources will be deployed."
}
