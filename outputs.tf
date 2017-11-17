output "alb_dns_name" {
  description = "The DNS name of the ALB presumably to be used with a friendlier CNAME."
  value       = "${aws_alb.main.dns_name}"
}

output "alb_id" {
  description = "The ID of the ALB we created."
  value       = "${aws_alb.main.id}"
}

output "alb_listener_https_id" {
  description = "The ID of the ALB Listener we created."
  value       = "${aws_alb_listener.frontend_https.id}"
}

output "alb_listener_http_id" {
  description = "The ID of the ALB Listener we created."
  value       = "${aws_alb_listener.frontend_http.id}"
}

output "alb_zone_id" {
  description = "The zone_id of the ALB to assist with creating DNS records."
  value       = "${aws_alb.main.zone_id}"
}

output "principal_account_id" {
  description = "The AWS-owned account given permissions to write your ALB logs to S3."
  value       = "${data.aws_elb_service_account.main.id}"
}

output "target_group_arn" {
  description = "ARN of the target group. Useful for passing to your Auto Scaling group module."
  value       = "${aws_alb_target_group.target_group.arn}"
}
