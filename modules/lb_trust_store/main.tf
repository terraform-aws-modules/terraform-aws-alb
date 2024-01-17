resource "aws_lb_trust_store" "this" {
  count = var.create ? 1 : 0

  ca_certificates_bundle_s3_bucket         = var.ca_certificates_bundle_s3_bucket
  ca_certificates_bundle_s3_key            = var.ca_certificates_bundle_s3_key
  ca_certificates_bundle_s3_object_version = var.ca_certificates_bundle_s3_object_version
  name_prefix                              = var.name_prefix != null ? "${var.name_prefix}-" : null
  name                                     = var.name != null ? var.name : null
  tags                                     = var.tags
}

resource "aws_lb_trust_store_revocation" "this" {
  for_each = { for k, v in var.revocation_lists : k => v if var.create && var.create_trust_store_revocation }

  trust_store_arn               = aws_lb_trust_store.this[0].arn
  revocations_s3_bucket         = each.value.revocations_s3_bucket
  revocations_s3_key            = each.value.revocations_s3_key
  revocations_s3_object_version = try(each.value.revocations_s3_object_version, null)
}
