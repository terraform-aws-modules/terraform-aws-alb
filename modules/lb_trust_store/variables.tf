variable "create" {
  description = "Controls if resources should be created."
  type        = bool
  default     = true
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration"
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

################################################################################
# Trust Store
################################################################################

variable "ca_certificates_bundle_s3_bucket" {
  description = "S3 bucket name holding the client certificate CA bundle."
  type        = string
  default     = null
}

variable "ca_certificates_bundle_s3_key" {
  description = "S3 object key holding the client certificate CA bundle."
  type        = string
  default     = null
}

variable "ca_certificates_bundle_s3_object_version" {
  description = "Version ID of CA bundle S3 bucket object, if versioned, defaults to latest if omitted."
  type        = string
  default     = null
}

variable "name" {
  description = "Name of the trust store. If omitted, Terraform will assign a random, unique name. This name must be unique per region, per account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen."
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "Creates a unique name beginning with the specified prefix. Conflicts with `name`. Cannot be longer than 6 characters."
  type        = string
  default     = null
}

variable "create_trust_store_revocation" {
  description = "Whether to create a trust store revocation for use with an application load balancer."
  type        = bool
  default     = false
}

################################################################################
# Trust Store Revocation(s)
################################################################################

variable "revocation_lists" {
  description = "Map of revocation list configurations."
  type = map(object({
    revocations_s3_bucket         = string
    revocations_s3_key            = string
    revocations_s3_object_version = optional(string)
  }))
  default = null
}
