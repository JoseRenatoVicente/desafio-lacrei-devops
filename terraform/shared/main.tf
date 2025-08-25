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
}

module "iam" {
  source     = "../modules/iam"
  github_org = var.github_org
  github_repo = var.github_repo
  rolename   = var.rolename
}