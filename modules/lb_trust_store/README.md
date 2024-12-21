# lb_trust_store

Terraform module which creates an ALB trust store and trust store revocation list resources.

## Usage
```
module "trust_store" {
  source = "terraform-aws-modules/alb/aws//modules/lb_trust_store"

  name                             = "my-trust-store"
  ca_certificates_bundle_s3_bucket = "my-cert-bucket"
  ca_certificates_bundle_s3_key    = "ca_cert/RootCA.pem"
  create_trust_store_revocation    = true
  revocation_lists = {
    crl_1 = {
      revocations_s3_bucket = "my-cert-bucket"
      revocations_s3_key    = "crl/crl_1.pem"
    }
    crl_2 = {
      revocations_s3_bucket = "my-cert-bucket"
      revocations_s3_key    = "crl/crl_2.pem"
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.82 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.82 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb_trust_store.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_trust_store) | resource |
| [aws_lb_trust_store_revocation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_trust_store_revocation) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ca_certificates_bundle_s3_bucket"></a> [ca\_certificates\_bundle\_s3\_bucket](#input\_ca\_certificates\_bundle\_s3\_bucket) | S3 bucket name holding the client certificate CA bundle. | `string` | `null` | no |
| <a name="input_ca_certificates_bundle_s3_key"></a> [ca\_certificates\_bundle\_s3\_key](#input\_ca\_certificates\_bundle\_s3\_key) | S3 object key holding the client certificate CA bundle. | `string` | `null` | no |
| <a name="input_ca_certificates_bundle_s3_object_version"></a> [ca\_certificates\_bundle\_s3\_object\_version](#input\_ca\_certificates\_bundle\_s3\_object\_version) | Version ID of CA bundle S3 bucket object, if versioned, defaults to latest if omitted. | `string` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created. | `bool` | `true` | no |
| <a name="input_create_trust_store_revocation"></a> [create\_trust\_store\_revocation](#input\_create\_trust\_store\_revocation) | Whether to create a trust store revocation for use with an application load balancer. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the trust store. If omitted, Terraform will assign a random, unique name. This name must be unique per region, per account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen. | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Creates a unique name beginning with the specified prefix. Conflicts with `name`. Cannot be longer than 6 characters. | `string` | `null` | no |
| <a name="input_revocation_lists"></a> [revocation\_lists](#input\_revocation\_lists) | Map of revocation list configurations. | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_revocation_lists"></a> [revocation\_lists](#output\_revocation\_lists) | Map of revocation lists and their attributes. |
| <a name="output_trust_store_arn"></a> [trust\_store\_arn](#output\_trust\_store\_arn) | ARN of the trust store (matches `id`). |
| <a name="output_trust_store_arn_suffix"></a> [trust\_store\_arn\_suffix](#output\_trust\_store\_arn\_suffix) | ARN suffix for use with cloudwatch metrics. |
| <a name="output_trust_store_id"></a> [trust\_store\_id](#output\_trust\_store\_id) | ARN of the trust store (matches `arn`). |
| <a name="output_trust_store_name"></a> [trust\_store\_name](#output\_trust\_store\_name) | Name of the trust store. |
<!-- END_TF_DOCS -->
