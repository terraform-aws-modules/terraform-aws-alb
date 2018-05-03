output "dns_name" {
  description = "The DNS name of the load balancer."
  value       = "${aws_lb.application.dns_name}"
}

output "http_tcp_listener_arns" {
  description = "The ARN of the TCP and HTTP load balancer listeners created."
  value       = "${slice(concat(aws_lb_listener.frontend_http_tcp.*.arn, list("")), 0, var.http_tcp_listeners_count)}"
}

output "http_tcp_listener_ids" {
  description = "The IDs of the TCP and HTTP load balancer listeners created."
  value       = "${slice(concat(aws_lb_listener.frontend_http_tcp.*.id, list("")), 0, var.http_tcp_listeners_count)}"
}

output "https_listener_arns" {
  description = "The ARNs of the HTTPS load balancer listeners created."
  value       = "${slice(concat(aws_lb_listener.frontend_https.*.arn, list("")), 0, var.https_listeners_count)}"
}

output "https_listener_ids" {
  description = "The IDs of the load balancer listeners created."
  value       = "${slice(concat(aws_lb_listener.frontend_https.*.id, list("")), 0, var.https_listeners_count)}"
}

output "load_balancer_arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch."
  value       = "${aws_lb.application.arn_suffix}"
}

output "load_balancer_id" {
  description = "The ID and ARN of the load balancer we created."
  value       = "${aws_lb.application.id}"
}

output "load_balancer_zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records."
  value       = "${aws_lb.application.zone_id}"
}

output "target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value       = "${slice(concat(aws_lb_target_group.main.*.arn, list("")), 0, var.target_groups_count)}"
}

output "target_group_arn_suffixes" {
    description = "ARN suffixes of our target groups - can be used with CloudWatch."
    value       = "${slice(concat(aws_lb_target_group.main.*.arn_suffix, list("")), 0, var.target_groups_count)}"
  }

output "target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value       = "${slice(concat(aws_lb_target_group.main.*.name, list("")), 0, var.target_groups_count)}"
}
