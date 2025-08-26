output "nlb_arn" {
  description = "ARN do Network Load Balancer"
  value       = aws_lb.nlb.arn
}

output "nlb_dns_name" {
  description = "DNS do Network Load Balancer"
  value       = aws_lb.nlb.dns_name
}

output "nlb_listener_arn" {
  description = "ARN do listener do NLB"
  value       = aws_lb_listener.http.arn
}

output "nlb_target_group_arn" {
  description = "ARN do Target Group do NLB"
  value       = aws_lb_target_group.ecs.arn
}