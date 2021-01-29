
output "aws_lb" {
  description = "The ID and ARN of the load balancer we created."
  value       = aws_lb.test.arn
}

output "aws_lb_target_group" {
  description = "The ID and ARN of the load balancer we created."
  value       = aws_lb_target_group.test.arn
}

