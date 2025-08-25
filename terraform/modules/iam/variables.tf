variable "rolename" {
  description = "Nome da role IAM para GitHub Actions (compartilhada entre ambientes)"
  type        = string
}

variable "github_org" {
  description = "Organização do GitHub"
  type        = string
}

variable "github_repo" {
  description = "Repositório GitHub no formato owner/repo"
  type        = string
}