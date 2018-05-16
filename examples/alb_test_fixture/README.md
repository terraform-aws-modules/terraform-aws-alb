# alb_test_fixture example

This set of templates serves two purposes:

1. it shows developers how to use the module in a straightforward way as integrated with other terraform community supported modules.
1. serves as the test infrastructure for CI on the project.

## IAM Permissions

The following IAM policy is the minimum needed to execute the module from the test suite.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1507789535000",
            "Effect": "Allow",
            "Action": [
                "autoscaling:*LoadBalancerTargetGroups",
                "autoscaling:*AutoScalingGroup",
                "autoscaling:*LaunchConfiguration",
                "autoscaling:*AutoScalingGroups",
                "autoscaling:*LaunchConfigurations",
                "ec2:AllocateAddress",
                "ec2:AssignIpv6Addresses",
                "ec2:AssignPrivateIpAddresses",
                "ec2:AssociateAddress",
                "ec2:AssociateDhcpOptions",
                "ec2:AssociateRouteTable",
                "ec2:AttachInternetGateway",
                "ec2:AttachNetworkInterface",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateDhcpOptions",
                "ec2:CreateInternetGateway",
                "ec2:CreateNatGateway",
                "ec2:CreateNetworkAcl",
                "ec2:CreateNetworkAclEntry",
                "ec2:CreateNetworkInterface",
                "ec2:CreateNetworkInterfacePermission",
                "ec2:CreateRoute",
                "ec2:CreateRouteTable",
                "ec2:CreateSecurityGroup",
                "ec2:CreateSubnet",
                "ec2:CreateTags",
                "ec2:CreateVpc",
                "ec2:DeleteDhcpOptions",
                "ec2:DeleteInternetGateway",
                "ec2:DeleteNatGateway",
                "ec2:DeleteNetworkAcl",
                "ec2:DeleteNetworkAclEntry",
                "ec2:DeleteNetworkInterface",
                "ec2:DeleteRoute",
                "ec2:DeleteRouteTable",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteSubnet",
                "ec2:DeleteTags",
                "ec2:DeleteVpc",
                "ec2:Describe*",
                "ec2:DetachInternetGateway",
                "ec2:DetachNetworkInterface",
                "ec2:DisassociateAddress",
                "ec2:DisassociateRouteTable",
                "ec2:DisassociateSubnetCidrBlock",
                "ec2:DisassociateVpcCidrBlock",
                "ec2:ModifySubnetAttribute",
                "ec2:ModifyVpcAttribute",
                "ec2:ModifyVpcEndpoint",
                "ec2:ReleaseAddress",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
                "ec2:UpdateSecurityGroupRuleDescriptionsIngress"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "Stmt1507789585001",
            "Effect": "Allow",
            "Action": [
                "s3:*",
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "Stmt1507789655000",
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "Stmt1507789655001",
            "Effect": "Allow",
            "Action": [
                "iam:UploadServerCertificate",
                "iam:DeleteServerCertificate",
                "iam:GetServerCertificate"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| log_bucket_name |  | string | `test-log-bucket` | no |
| log_location_prefix |  | string | `my-lb-logs` | no |
| region |  | string | `us-west-2` | no |

## Outputs

| Name | Description |
|------|-------------|
| account_id |  |
| alb_id |  |
| http_tcp_listener_arns |  |
| http_tcp_listeners_count |  |
| https_listener_arns |  |
| https_listeners_count |  |
| region |  |
| sg_id |  |
| target_group_arns |  |
| target_groups_count |  |
| vpc_id |  |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
