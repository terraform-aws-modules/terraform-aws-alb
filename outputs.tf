output "lb_arn" {
  description = "ARN of the LB itself. Useful for debug output, for example when attaching a WAF."
  value       = "${aws_lb.main.arn}"
}

output "lb_arn_suffix" {
  description = "ARN suffix of our LB - can be used with CloudWatch"
  value       = "${aws_lb.main.arn_suffix}"
}

output "lb_dns_name" {
  description = "The DNS name of the LB presumably to be used with a friendlier CNAME."
  value       = "${aws_lb.main.dns_name}"
}

output "lb_id" {
  description = "The ID of the LB we created."
  value       = "${aws_lb.main.id}"
}

output "http_tcp_listener_arns" {
  description = "The ARN of the HTTP LB Listener we created."
  value       = "${element(concat(aws_lb_listener.frontend_http_tcp.*.arn, list("")), 0)}"
}

output "http_tcp_listener_ids" {
  description = "The ID of the LB Listener we created."
  value       = "${element(concat(aws_lb_listener.frontend_http_tcp.*.id, list("")), 0)}"
}

output "https_listener_arns" {
  description = "The ARN of the HTTPS LB Listener we created."
  value       = "${element(concat(aws_lb_listener.frontend_https.*.arn, list("")), 0)}"
}

output "https_listner_ids" {
  description = "The ID of the LB Listener we created."
  value       = "${element(concat(aws_lb_listener.frontend_https.*.id, list("")), 0)}"
}

output "lb_zone_id" {
  description = "The zone_id of the LB to assist with creating DNS records."
  value       = "${aws_lb.main.zone_id}"
}

output "target_group_arns" {
  description = "ARN of the target group. Useful for passing to your Auto Scaling group module."
  value       = "${aws_lb_target_group.target_group.*.arn}"
}

output "target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value       = "${aws_lb_target_group.target_group.*.name}"
}
