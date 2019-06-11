variable "create_alb" {
  description = "Controls if the ALB should be created"
  type        = bool
  default     = true
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  type        = bool
  default     = false
}

variable "enable_http2" {
  description = "Indicates whether HTTP/2 is enabled in application load balancers."
  type        = bool
  default     = true
}

variable "enable_cross_zone_load_balancing" {
  description = "Indicates whether cross zone load balancing should be enabled in application load balancers."
  type        = bool
  default     = false
}

variable "extra_ssl_certs" {
  description = "A list of maps describing any extra SSL certificates to apply to the HTTPS listeners. Required key/values: certificate_arn, https_listener_index (the index of the listener within https_listeners which the cert applies toward)."
  type        = list(object({ certificate_arn = string, https_listener_index = number }))
  default     = []
}

variable "extra_ssl_certs_count" {
  description = "A manually provided count/length of the extra_ssl_certs list of maps since the list cannot be computed."
  type        = number
  default     = 0
}

variable "https_listeners" {
  description = "A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate_arn. Optional key/values: ssl_policy (defaults to ELBSecurityPolicy-2016-08), target_group_index (defaults to 0)"
  type        = list(map(string))
  default     = []
}

variable "https_listeners_count" {
  description = "A manually provided count/length of the https_listeners list of maps since the list cannot be computed."
  type        = number
  default     = 0
}

variable "http_tcp_listeners" {
  description = "A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, protocol. Optional key/values: target_group_index (defaults to 0)"
  type        = list(map(string))
  default     = []
}

variable "http_tcp_listeners_count" {
  description = "A manually provided count/length of the http_tcp_listeners list of maps since the list cannot be computed."
  type        = number
  default     = 0
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle."
  type        = number
  default     = 60
}

variable "ip_address_type" {
  description = "The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack."
  type        = string
  default     = "ipv4"
}

variable "listener_ssl_policy_default" {
  description = "The security policy if using HTTPS externally on the load balancer. [See](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html)."
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}

variable "load_balancer_is_internal" {
  description = "Boolean determining if the load balancer is internal or externally facing."
  type        = bool
  default     = false
}

variable "load_balancer_create_timeout" {
  description = "Timeout value when creating the ALB."
  type        = string
  default     = "10m"
}

variable "load_balancer_delete_timeout" {
  description = "Timeout value when deleting the ALB."
  type        = string
  default     = "10m"
}

variable "load_balancer_name" {
  description = "The resource name and Name tag of the load balancer."
  type        = string
}

variable "load_balancer_update_timeout" {
  description = "Timeout value when updating the ALB."
  type        = string
  default     = "10m"
}

variable "logging_enabled" {
  description = "Controls if the ALB will log requests to S3."
  type        = bool
  default     = true
}

variable "log_bucket_name" {
  description = "S3 bucket (externally created) for storing load balancer access logs. Required if logging_enabled is true."
  type        = string
  default     = ""
}

variable "log_location_prefix" {
  description = "S3 prefix within the log_bucket_name under which logs are stored."
  type        = string
  default     = ""
}

variable "subnets" {
  description = "A list of subnets to associate with the load balancer. e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f']"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "security_groups" {
  description = "The security groups to attach to the load balancer. e.g. [\"sg-edcd9784\",\"sg-edcd9785\"]"
  type        = list(string)
}

variable "target_groups" {
  description = "A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend_protocol, backend_port. Optional key/values are in the target_groups_defaults variable."
  type        = list(map(string))
  default     = []
}

variable "target_groups_count" {
  description = "A manually provided count/length of the target_groups list of maps since the list cannot be computed."
  type        = number
  default     = 0
}

variable "target_groups_defaults" {
  description = "Default values for target groups as defined by the list of maps."
  type = object(
    {
      cookie_duration                  = string,
      deregistration_delay             = string,
      health_check_interval            = string,
      health_check_healthy_threshold   = string,
      health_check_path                = string,
      health_check_port                = string,
      health_check_timeout             = string,
      health_check_unhealthy_threshold = string,
      health_check_matcher             = string,
      stickiness_enabled               = string,
      target_type                      = string,
      slow_start                       = string,
    }
  )
  default = {
    cookie_duration                  = 86400
    deregistration_delay             = 300
    health_check_interval            = 10
    health_check_healthy_threshold   = 3
    health_check_path                = "/"
    health_check_port                = "traffic-port"
    health_check_timeout             = 5
    health_check_unhealthy_threshold = 3
    health_check_matcher             = "200-299"
    stickiness_enabled               = true
    target_type                      = "instance"
    slow_start                       = 0
  }
}

variable "vpc_id" {
  description = "VPC id where the load balancer and other resources will be deployed."
  type        = string
}

