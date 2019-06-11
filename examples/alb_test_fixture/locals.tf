locals {
  tags = {
    "Environment" = "test"
    "GithubRepo"  = "tf-aws-alb"
    "GithubOrg"   = "terraform-aws-modules"
    "Workspace"   = terraform.workspace
  }

  log_bucket_name = "${var.log_bucket_name}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"

  https_listeners_count = 2

  https_listeners = [
    {
      "certificate_arn" = aws_iam_server_certificate.fixture_cert[0].arn
      "port"            = 443
    },
    {
      "certificate_arn"    = aws_iam_server_certificate.fixture_cert[1].arn
      "port"               = 8443
      "ssl_policy"         = "ELBSecurityPolicy-TLS-1-2-2017-01"
      "target_group_index" = 1
    },
  ]

  http_tcp_listeners_count = 3

  http_tcp_listeners = [
    {
      "port"     = 80
      "protocol" = "HTTP"
    },
    {
      "port"               = 8080
      "protocol"           = "HTTP"
      "target_group_index" = 0
    },
    {
      "port"               = 8081
      "protocol"           = "HTTP"
      "target_group_index" = 1
    },
  ]

  target_groups_count = 2

  target_groups = [
    {
      "name"             = "foo"
      "backend_protocol" = "HTTP"
      "backend_port"     = 80
      "slow_start"       = 0
    },
    {
      "name"             = "bar"
      "backend_protocol" = "HTTP"
      "backend_port"     = 8080
      "slow_start"       = 100
    },
  ]

  extra_ssl_certs_count = 4

  extra_ssl_certs = [
    {
      "certificate_arn"      = aws_iam_server_certificate.fixture_cert[0].arn
      "https_listener_index" = "1"
    },
    {
      "certificate_arn"      = aws_iam_server_certificate.fixture_cert[1].arn
      "https_listener_index" = "0"
    },
    {
      "certificate_arn"      = aws_iam_server_certificate.fixture_cert[2].arn
      "https_listener_index" = "0"
    },
    {
      "certificate_arn"      = aws_iam_server_certificate.fixture_cert[3].arn
      "https_listener_index" = "0"
    },
  ]
  # helpful for debugging
  #   https_listeners_count    = 0
  #   https_listeners          = "${list()}"
  #   http_tcp_listeners_count = 0
  #   http_tcp_listeners       = "${list()}"
  #   target_groups_count      = 0
  #   target_groups            = "${list()}"
  #   extra_ssl_certs_count    = 0
  #   extra_ssl_certs          = "${list()}"
}

