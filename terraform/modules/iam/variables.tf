variable "organization_name" {
  description = "Nome da organização"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., prod, staging)"
  type        = string
  default     = "prod"
}

variable "github_org" {
  description = "Organização do GitHub"
  type        = string
}

variable "github_repo" {
  description = "Repositório GitHub no formato owner/repo"
  type        = string
}

variable "aws_region" {
  description = "Região AWS"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}