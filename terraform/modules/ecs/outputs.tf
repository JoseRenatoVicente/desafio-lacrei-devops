output "cluster_name" {
  description = "Nome do cluster ECS"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "ARN do cluster ECS"
  value       = aws_ecs_cluster.main.arn
}

output "service_name" {
  description = "Nome do serviço ECS"
  value       = aws_ecs_service.main.name
}

output "task_definition_arn" {
  description = "ARN da task definition"
  value       = aws_ecs_task_definition.app.arn
}
