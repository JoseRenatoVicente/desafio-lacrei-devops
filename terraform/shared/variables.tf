variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "github_org" {
  description = "Organização do GitHub"
  type        = string
}

variable "github_repo" {
  description = "Repositório GitHub"
  type        = string
}

variable "rolename" {
  description = "Nome da role IAM para GitHub Actions"
  type        = string
}