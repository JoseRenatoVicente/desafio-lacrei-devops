# API Gateway
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.organization_name}-${var.environment}-api-gw"
  protocol_type = "HTTP"

  tags = {
    Name        = "${var.organization_name}-${var.environment}-api-gw"
    Environment = var.environment
  }
}

# VPC Link
resource "aws_apigatewayv2_vpc_link" "main" {
  name               = "${var.organization_name}-${var.environment}-vpc-link"
  security_group_ids = [aws_security_group.vpc_link.id]
  subnet_ids         = var.private_subnets

  tags = {
    Name        = "${var.organization_name}-${var.environment}-vpc-link"
    Environment = var.environment
  }
}

# Security Group for VPC Link
resource "aws_security_group" "vpc_link" {
  name_prefix = "${var.organization_name}-${var.environment}-vpc-link"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.organization_name}-${var.environment}-vpc-link-sg"
    Environment = var.environment
  }
}

# API Gateway Integration
resource "aws_apigatewayv2_integration" "main" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "HTTP_PROXY"
  integration_uri  = var.nlb_listener_arn
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.main.id
}

# API Gateway Routes
resource "aws_apigatewayv2_route" "health" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.main.id}"
}

resource "aws_apigatewayv2_route" "proxy" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.main.id}"
}

# API Gateway Stage
resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip            = "$context.identity.sourceIp"
      requestTime   = "$context.requestTime"
      httpMethod    = "$context.httpMethod"
      routeKey      = "$context.routeKey"
      status        = "$context.status"
      protocol      = "$context.protocol"
      responseLength = "$context.responseLength"
      integrationError = "$context.integrationErrorMessage"
    })
  }

  tags = {
    Name        = "${var.organization_name}-${var.environment}-stage"
    Environment = var.environment
  }
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/api-gateway/${var.organization_name}-${var.environment}"
  retention_in_days = 30

  tags = {
    Name        = "${var.organization_name}-${var.environment}-api-gw-logs"
    Environment = var.environment
  }
}

output "api_gateway_url" {
  value = aws_apigatewayv2_stage.main.invoke_url
}
