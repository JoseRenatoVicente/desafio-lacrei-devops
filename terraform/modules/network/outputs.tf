output "alb_arn" {
  description = "ARN do Application Load Balancer"
  value       = aws_lb.alb.arn
}

output "alb_listener_arn" {
  description = "ARN do listener do ALB"
  value       = aws_lb_listener.http.arn
}

output "alb_target_group_arn" {
  description = "ARN do Target Group do ALB"
  value       = aws_lb_target_group.ecs.arn
}