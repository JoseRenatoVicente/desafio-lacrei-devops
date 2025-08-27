output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = module.api_gateway.api_gateway_url
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.network.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.network.public_subnets
}

output "environment" {
  description = "Nome do ambiente atual"
  value       = var.environment
}

output "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  value       = module.ecs.cluster_name
}

output "service_discovery_namespace" {
  description = "Namespace do Service Discovery"
  value       = module.service_discovery.namespace_name
}



output "alb_dns_name" {
  description = "DNS name do Application Load Balancer"
  value       = module.network.alb_dns_name
}

output "alb_zone_id" {
  description = "Route 53 zone ID do ALB"
  value       = module.network.alb_zone_id
}

output "dns_settings" {
  description = "Configurações DNS para DuckDNS"
  value = {
    ipv4 = [module.network.alb_dns_name]
    ipv6 = [] # O ALB não suporta IPv6 por padrão
  }
}
