terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

# VPC and Network Resources
module "network" {
  source = "./modules/network"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  container_port = var.container_port
}

# ECS Resources
module "ecs" {
  source = "./modules/ecs"

  project_name    = var.project_name
  environment     = var.environment
  vpc_id         = module.network.vpc_id
  private_subnets = module.network.private_subnets
  
  container_image = var.container_image
  container_port  = var.container_port
  desired_count  = var.desired_count
  
  nlb_target_group_arn = module.network.nlb_target_group_arn
  cloudwatch_log_group_name     = "/ecs/${var.project_name}"

  depends_on = [module.network]
}

# Service Discovery
module "service_discovery" {
  source = "./modules/service_discovery"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.network.vpc_id

  depends_on = [module.network]
}

# API Gateway and VPC Link
module "api_gateway" {
  source = "./modules/api_gateway"

  project_name                      = var.project_name
  environment                       = var.environment
  vpc_id                           = module.network.vpc_id
  private_subnets                  = module.network.private_subnets
  nlb_listener_arn                 = module.network.nlb_listener_arn
  container_port                    = var.container_port

  depends_on = [module.network, module.ecs]
}
