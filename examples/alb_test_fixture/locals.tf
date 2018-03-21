locals {
  tags                  = "${map("Environment", "test", "GithubRepo", "tf-aws-alb", "GithubOrg", "terraform-aws-modules", "Workspace", "${terraform.workspace}")}"
  log_bucket_name       = "${var.log_bucket_name}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  https_listeners_count = 2

  https_listeners = "${list(
                            map(
                                "certificate_arn", aws_iam_server_certificate.fixture_cert.arn,
                                "port", 443
                            ),
                            map(
                                "certificate_arn", aws_iam_server_certificate.fixture_cert.arn,
                                "port", 8443,
                                "ssl_policy", "ELBSecurityPolicy-TLS-1-2-2017-01",
                                "target_group_index", 1
                            )
  )}"

  http_tcp_listeners_count = 3

  http_tcp_listeners = "${list(
                            map(
                                "port", 80,
                                "protocol", "HTTP"
                            ),
                            map(
                                "port", 8080,
                                "protocol", "HTTP",
                                "target_group_index", 0
                            ),
                            map(
                                "port", 8081,
                                "protocol", "HTTP",
                                "target_group_index", 1
                            )
    )}"

  target_groups_count = 2

  target_groups = "${list(
                        map("name", "foo",
                            "backend_protocol", "HTTP",
                            "backend_port", 80
                        ),
                        map("name", "bar",
                            "backend_protocol", "HTTP",
                            "backend_port", 8080
                        )
  )}"
}
