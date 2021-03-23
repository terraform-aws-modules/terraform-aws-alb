# Complete ALB example

Configuration in this directory creates ALB with several supported types of listeners and actions, and SSL certificates.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.26 |
| aws | >= 2.54 |
| random | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.54 |
| random | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| acm | terraform-aws-modules/acm/aws | ~> 2.0 |
| alb | ../../ |  |
| lb_disabled | ../../ |  |
| security_group | terraform-aws-modules/security-group/aws | ~> 3.0 |

## Resources

| Name |
|------|
| [aws_cognito_user_pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) |
| [aws_cognito_user_pool_client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) |
| [aws_cognito_user_pool_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) |
| [aws_route53_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) |
| [aws_subnet_ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet_ids) |
| [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) |
| [random_pet](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) |

## Inputs

No input.

## Outputs

| Name | Description |
|------|-------------|
| http\_tcp\_listener\_arns | The ARN of the TCP and HTTP load balancer listeners created. |
| http\_tcp\_listener\_ids | The IDs of the TCP and HTTP load balancer listeners created. |
| https\_listener\_arns | The ARNs of the HTTPS load balancer listeners created. |
| https\_listener\_ids | The IDs of the load balancer listeners created. |
| target\_group\_arn\_suffixes | ARN suffixes of our target groups - can be used with CloudWatch. |
| target\_group\_arns | ARNs of the target groups. Useful for passing to your Auto Scaling group. |
| target\_group\_names | Name of the target group. Useful for passing to your CodeDeploy Deployment Group. |
| this\_lb\_arn | The ID and ARN of the load balancer we created. |
| this\_lb\_arn\_suffix | ARN suffix of our load balancer - can be used with CloudWatch. |
| this\_lb\_dns\_name | The DNS name of the load balancer. |
| this\_lb\_id | The ID and ARN of the load balancer we created. |
| this\_lb\_zone\_id | The zone\_id of the load balancer to assist with creating DNS records. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
