output "trust_store_arn_suffix" {
  description = "ARN suffix for use with cloudwatch metrics."
  value       = try(aws_lb_trust_store.this[0].arn_suffix, null)
}

output "trust_store_arn" {
  description = "ARN of the trust store (matches `id`)."
  value       = try(aws_lb_trust_store.this[0].arn, null)
}

output "trust_store_id" {
  description = "ARN of the trust store (matches `arn`)."
  value       = try(aws_lb_trust_store.this[0].id, null)
}

output "trust_store_name" {
  description = "Name of the trust store."
  value       = try(aws_lb_trust_store.this[0].name, null)
}

output "revocation_id" {
  description = "AWS assigned RevocationId, (number)."
  value       = try(aws_lb_trust_store_revocation.this[0].revocation_id, null)
}
