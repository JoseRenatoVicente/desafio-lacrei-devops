output "github_oidc_provider_arn" {
  description = "ARN do OIDC Provider do GitHub"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_role_arn" {
  description = "ARN da Role assumida pelo GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}
