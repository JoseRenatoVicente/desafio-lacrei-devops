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

# IAM Resources
module "iam" {
  source     = "./modules/iam"
  organization_name = var.organization_name
  environment  = var.environment
  github_org = var.github_org
  github_repo = var.github_repo
  aws_region = var.aws_region
  project_name = var.project_name
}

# VPC and Network Resources
module "network" {
  source = "./modules/network"

  organization_name = var.organization_name
  ecr_repositories = var.ecr_repositories
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  container_port = var.container_port
}

# Monitoring Resources
module "monitoring" {
  source = "./modules/monitoring"
  
  organization_name = var.organization_name
  environment      = var.environment
  alarm_email      = var.alarm_email
  api_id         = module.api_gateway.api_id
}

# ECS Resources
module "ecs" {
  source = "./modules/ecs"

  organization_name = var.organization_name
  project_name    = var.project_name
  environment     = var.environment
  vpc_id         = module.network.vpc_id
  private_subnets = module.network.private_subnets
  
  container_image = var.container_image
  container_port  = var.container_port
  desired_count  = var.desired_count
  
  nlb_target_group_arn = module.network.nlb_target_group_arn

  depends_on = [module.network]
}

# Service Discovery
module "service_discovery" {
  source = "./modules/service_discovery"

  organization_name = var.organization_name
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.network.vpc_id

  depends_on = [module.network]
}

# API Gateway and VPC Link
module "api_gateway" {
  source = "./modules/api_gateway"

  organization_name                 = var.organization_name
  project_name                      = var.project_name
  environment                       = var.environment
  vpc_id                           = module.network.vpc_id
  private_subnets                  = module.network.private_subnets
  nlb_listener_arn                 = module.network.nlb_listener_arn
  container_port                    = var.container_port

  depends_on = [module.network, module.ecs]
}
