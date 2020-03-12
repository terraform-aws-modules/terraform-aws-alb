output "this_lb_id" {
  description = "The ID and ARN of the load balancer we created."
  value       = concat(aws_lb.this.*.id, [""])[0]
}

output "this_lb_arn" {
  description = "The ID and ARN of the load balancer we created."
  value       = concat(aws_lb.this.*.arn, [""])[0]
}

output "this_lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = concat(aws_lb.this.*.dns_name, [""])[0]
}

output "this_lb_arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch."
  value       = concat(aws_lb.this.*.arn_suffix, [""])[0]
}

output "this_lb_zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records."
  value       = concat(aws_lb.this.*.zone_id, [""])[0]
}

output "http_tcp_listener_arns" {
  description = "The ARN of the TCP and HTTP load balancer listeners created."
  value       = aws_lb_listener.frontend_http_tcp.*.arn
}

output "http_tcp_listener_ids" {
  description = "The IDs of the TCP and HTTP load balancer listeners created."
  value       = aws_lb_listener.frontend_http_tcp.*.id
}

output "https_listener_arns" {
  description = "The ARNs of the HTTPS load balancer listeners created."
  value       = aws_lb_listener.frontend_https.*.arn
}

output "https_listener_ids" {
  description = "The IDs of the load balancer listeners created."
  value       = aws_lb_listener.frontend_https.*.id
}

output "target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value       = aws_lb_target_group.main.*.arn
}

output "target_group_arn_suffixes" {
  description = "ARN suffixes of our target groups - can be used with CloudWatch."
  value       = aws_lb_target_group.main.*.arn_suffix
}

output "target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value       = aws_lb_target_group.main.*.name
}
