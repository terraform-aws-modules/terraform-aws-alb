################################################################################
# Trust Store
################################################################################

resource "aws_lb_trust_store" "this" {
  count = var.create ? 1 : 0

  region = var.region

  ca_certificates_bundle_s3_bucket         = var.ca_certificates_bundle_s3_bucket
  ca_certificates_bundle_s3_key            = var.ca_certificates_bundle_s3_key
  ca_certificates_bundle_s3_object_version = var.ca_certificates_bundle_s3_object_version
  name_prefix                              = var.name_prefix != null ? "${var.name_prefix}-" : null
  name                                     = var.name != null ? var.name : null

  tags = var.tags
}

################################################################################
# Trust Store Revocation(s)
################################################################################

resource "aws_lb_trust_store_revocation" "this" {
  for_each = var.create && var.create_trust_store_revocation && var.revocation_lists != null ? var.revocation_lists : {}

  region = var.region

  trust_store_arn               = aws_lb_trust_store.this[0].arn
  revocations_s3_bucket         = each.value.revocations_s3_bucket
  revocations_s3_key            = each.value.revocations_s3_key
  revocations_s3_object_version = each.value.revocations_s3_object_version
}
