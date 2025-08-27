output "github_oidc_provider_arn" {
  description = "ARN do OIDC provider do GitHub Actions"
  value       = aws_iam_openid_connect_provider.github.arn
}
