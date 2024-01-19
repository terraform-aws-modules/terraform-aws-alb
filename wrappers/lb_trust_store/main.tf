module "wrapper" {
  source = "../../modules/lb_trust_store"

  for_each = var.items

  ca_certificates_bundle_s3_bucket         = try(each.value.ca_certificates_bundle_s3_bucket, var.defaults.ca_certificates_bundle_s3_bucket, null)
  ca_certificates_bundle_s3_key            = try(each.value.ca_certificates_bundle_s3_key, var.defaults.ca_certificates_bundle_s3_key, null)
  ca_certificates_bundle_s3_object_version = try(each.value.ca_certificates_bundle_s3_object_version, var.defaults.ca_certificates_bundle_s3_object_version, null)
  create                                   = try(each.value.create, var.defaults.create, true)
  create_trust_store_revocation            = try(each.value.create_trust_store_revocation, var.defaults.create_trust_store_revocation, false)
  name                                     = try(each.value.name, var.defaults.name, null)
  name_prefix                              = try(each.value.name_prefix, var.defaults.name_prefix, null)
  revocation_lists                         = try(each.value.revocation_lists, var.defaults.revocation_lists, {})
  tags                                     = try(each.value.tags, var.defaults.tags, {})
}
