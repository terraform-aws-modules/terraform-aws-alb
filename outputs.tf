output "lb_arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch."
  value       = "${aws_lb.application.arn_suffix}"
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = "${aws_lb.application.dns_name}"
}

output "lb_id" {
  description = "The ID and ARN of the load balancer we created."
  value       = "${aws_lb.application.id}"
}

output "http_tcp_listener_arns" {
  description = "The ARN of the TCP and HTTP load balancer listeners created."
  value       = "${element(concat(aws_lb_listener.frontend_http_tcp.*.arn, list("")), 0)}"
}

output "http_tcp_listener_ids" {
  description = "The IDs of the TCP and HTTP load balancer listeners created."
  value       = "${element(concat(aws_lb_listener.frontend_http_tcp.*.id, list("")), 0)}"
}

output "https_listener_arns" {
  description = "The ARN of the HTTPS load balancer listeners created."
  value       = "${element(concat(aws_lb_listener.frontend_https.*.arn, list("")), 0)}"
}

output "https_listner_ids" {
  description = "The ID of the load balancer listeners created."
  value       = "${element(concat(aws_lb_listener.frontend_https.*.id, list("")), 0)}"
}

output "lb_zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records."
  value       = "${aws_lb.application.zone_id}"
}

output "target_group_arns" {
  description = "ARN of the target group. Useful for passing to your Auto Scaling group module."
  value       = "${aws_lb_target_group.main.*.arn}"
}

output "target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value       = "${aws_lb_target_group.main.*.name}"
}
