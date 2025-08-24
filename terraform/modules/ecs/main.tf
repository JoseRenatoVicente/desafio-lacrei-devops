
# Cluster ECS
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Name        = "${var.project_name}-cluster-${var.environment}"
  }

  lifecycle {
    ignore_changes = [setting]
  }
}

# Task Role
resource "aws_iam_role" "task_role" {
  name = "${var.project_name}-task-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Name        = "${var.project_name}-task-role-${var.environment}"
  }
}

# Task Execution Role
resource "aws_iam_role" "task_execution_role" {
  name = "${var.project_name}-task-execution-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Name        = "${var.project_name}-task-execution-role-${var.environment}"
  }
}

resource "aws_iam_role_policy_attachment" "task_execution_role_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-task-${var.environment}"
  container_definitions    = jsonencode([
    {
      name  = "${var.project_name}-container-${var.environment}"
      image = var.container_image
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "NODE_ENV"
          value = var.environment
        }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "node -e 'require(\"http\").get(\"http://localhost:${var.container_port}/health\", (res) => process.exit(res.statusCode === 200 ? 0 : 1))'"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.cloudwatch_log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      essential = true
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = 256
  memory                  = 512
  execution_role_arn      = aws_iam_role.task_execution_role.arn
  task_role_arn           = aws_iam_role.task_role.arn

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Name        = "${var.project_name}-task-def-${var.environment}"
  }
}

# Security Group para o serviço ECS
resource "aws_security_group" "ecs_service" {
  name        = "${var.project_name}-ecs-service-sg-${var.environment}"
  description = "Security group for ECS service"
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
}

# Serviço ECS
resource "aws_ecs_service" "main" {
  name                = "${var.project_name}-service-${var.environment}"
  cluster             = aws_ecs_cluster.main.id
  task_definition     = aws_ecs_task_definition.app.arn
  desired_count       = var.desired_count
  launch_type         = "FARGATE"
  platform_version    = "LATEST"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.nlb_target_group_arn
    container_name   = "${var.project_name}-container-${var.environment}"
    container_port   = var.container_port
  }

  depends_on = [aws_ecs_cluster.main]

  lifecycle {
    create_before_destroy = false
    ignore_changes = [desired_count]
  }
}
