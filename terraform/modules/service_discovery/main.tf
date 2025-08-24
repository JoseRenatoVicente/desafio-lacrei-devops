# Service Discovery Namespace
resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${var.project_name}.local"
  vpc         = var.vpc_id
  description = "Private DNS namespace for ${var.project_name}"

  tags = {
    Name        = "${var.project_name}-namespace-${var.environment}"
    Environment = var.environment
  }
}

# Service Discovery Service
resource "aws_service_discovery_service" "main" {
  name = "${var.project_name}-${var.environment}"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = {
    Name        = "${var.project_name}-discovery-service-${var.environment}"
    Environment = var.environment
  }
}

output "namespace_id" {
  value = aws_service_discovery_private_dns_namespace.main.id
}

output "namespace_name" {
  value = aws_service_discovery_private_dns_namespace.main.name
}

output "service_id" {
  value = aws_service_discovery_service.main.id
}

output "service_arn" {
  value = aws_service_discovery_service.main.arn
}
