
# ECR Repository
resource "aws_ecr_repository" "app" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "${var.project_name}-ecr-${var.environment}"
    Environment = var.environment
  }
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Manter apenas as 10 imagens mais recentes"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Network Load Balancer
resource "aws_lb" "nlb" {
  name               = "${var.project_name}-nlb-${var.environment}"
  internal           = false
  load_balancer_type = "network"
  subnets            = aws_subnet.public[*].id

  tags = {
    Name        = "${var.project_name}-nlb-${var.environment}"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = false
  }
}

# Target Group para ECS
resource "aws_lb_target_group" "ecs" {
  name        = "${var.project_name}-tg-${var.environment}"
  port        = var.container_port
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    protocol            = "HTTP"
    path                = "/health"
    port                = var.container_port
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }

  tags = {
    Name        = "${var.project_name}-tg-${var.environment}"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = false
  }
}

# Listener NLB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }

  depends_on = [aws_lb_target_group.ecs]

  lifecycle {
    create_before_destroy = false
  }
}
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
  Name        = "${var.project_name}-vpc-${var.environment}"
    Environment = var.environment
  }
}

# Public Subnets (for NAT Gateway)
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
  Name        = "${var.project_name}-public-${count.index + 1}-${var.environment}"
    Environment = var.environment
  }
}

# Private Subnets (for ECS tasks)
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 2)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
  Name        = "${var.project_name}-private-${count.index + 1}-${var.environment}"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
  Name        = "${var.project_name}-igw-${var.environment}"
    Environment = var.environment
  }
}

# NAT Gateway
resource "aws_eip" "nat" {
  count  = 1
  domain = "vpc"

  tags = {
  Name        = "${var.project_name}-nat-eip-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "main" {
  count         = 1
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
  Name        = "${var.project_name}-nat-${var.environment}"
    Environment = var.environment
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
  Name        = "${var.project_name}-public-rt-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }

  tags = {
  Name        = "${var.project_name}-private-rt-${var.environment}"
    Environment = var.environment
  }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# VPC Endpoints
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  tags = {
  Name        = "${var.project_name}-s3-endpoint-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints.id]

  private_dns_enabled = true

  tags = {
  Name        = "${var.project_name}-ecr-api-endpoint-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints.id]

  private_dns_enabled = true

  tags = {
  Name        = "${var.project_name}-ecr-dkr-endpoint-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints.id]

  private_dns_enabled = true

  tags = {
  Name        = "${var.project_name}-logs-endpoint-${var.environment}"
    Environment = var.environment
  }
}

# Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.project_name}-vpc-endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
  Name        = "${var.project_name}-vpc-endpoints-sg-${var.environment}"
    Environment = var.environment
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}
