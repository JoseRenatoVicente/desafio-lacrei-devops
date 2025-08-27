output "github_actions_role_arn" {
  description = "ARN da Role assumida pelo GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}