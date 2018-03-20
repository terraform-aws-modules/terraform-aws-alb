variable "lb_is_internal" {
  description = "Boolean determining if the LB is internal or externally facing."
  default     = false
}

variable "load_balancer_type" {
  description = "The type of load balancer to create. Possible values are application or network."
  default     = "application"
}

variable "load_balancer_create_timeout" {
  description = ""
  default     = "10m"
}

variable "load_balancer_delete_timeout" {
  description = ""
  default     = "10m"
}

variable "load_balancer_update_timeout" {
  description = ""
  default     = "10m"
}

variable "enable_cross_zone_load_balancing" {
  description = "If true, cross-zone load balancing of the load balancer will be enabled. This is a network load balancer feature. Defaults to false."
  default     = false
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle."
  default     = 60
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  default     = false
}

variable "enable_http2" {
  description = "Indicates whether HTTP/2 is enabled in application load balancers."
  default     = true
}

variable "ip_address_type" {
  description = "The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack."
  default     = "ipv4"
}

variable "lb_name" {
  description = "The name prefix and name tag of the LB."
}

variable "lb_security_groups" {
  description = "The security groups with which we associate the LB. e.g. [\"sg-edcd9784\",\"sg-edcd9785\"]"
  type        = "list"
}

variable "backend_port" {
  description = "The port the service on the EC2 instances listen on."
  default     = 80
}

variable "backend_protocol" {
  description = "The protocol the backend service speaks. Options: HTTP, HTTPS, TCP, SSL (secure tcp)."
  default     = "HTTP"
}

variable "http_tcp_listeners" {
  description = ""
  type        = "list"
  default     = []
}

variable "http_tcp_listeners_count" {
  description = ""
  default     = 0
}

variable "https_listeners" {
  description = ""
  type        = "list"
  default     = []
}

variable "https_listeners_count" {
  description = ""
  default     = 0
}

variable "log_bucket_name" {
  description = "S3 bucket for storing LB access logs."
}

variable "log_location_prefix" {
  description = "S3 prefix within the log_bucket_name under which logs are stored."
  default     = ""
}

variable "listener_ssl_policy_default" {
  description = "The security policy if using HTTPS externally on the LB. See: https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html"
  default     = "ELBSecurityPolicy-2016-08"
}

variable "subnets" {
  description = "A list of subnets to associate with the LB. e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f']"
  type        = "list"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "target_groups" {
  description = "A list of maps containing key/value pairs that define the target groups to be created. Order of these is important and the index of these are to be referenced in listenr definitions."
  type        = "list"
  default     = []
}

variable "target_groups_count" {
  description = ""
  default     = 0
}

variable "target_groups_defaults" {
  description = "Default values for target groups as defined by the list of maps."
  type        = "map"

  default = {
    "cookie_duration"                  = 86400
    "deregistration_delay"             = 300
    "health_check_interval"            = 10
    "health_check_healthy_threshold"   = 3
    "health_check_path"                = "/"
    "health_check_port"                = "traffic-port"
    "health_check_timeout"             = 5
    "health_check_unhealthy_threshold" = 3
    "health_check_matcher"             = "200-299"
    "stickiness_enabled"               = true
    "target_type"                      = "instance"
  }
}

variable "vpc_id" {
  description = "VPC id where the LB and other resources will be deployed."
}
