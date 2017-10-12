locals {
  bucket_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["s3:PutObject"],
      "Effect": "Allow",
      "Resource":
        "arn:aws:s3:::${var.log_bucket}/${var.log_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "Principal": {
        "AWS": ["${data.aws_elb_service_account.main.id}"]
      }
    }
  ]
}
POLICY
}
