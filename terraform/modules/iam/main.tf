# Recupera dinamicamente o Account ID da AWS
data "aws_caller_identity" "current" {}

# Role para GitHub Actions assumir via OIDC
resource "aws_iam_role" "github_actions" {
  name = "${var.organization_name}-${var.environment}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
            StringEquals = {
            "token.actions.githubusercontent.com:aud" = ["sts.amazonaws.com"]
            }
            StringLike = {
            "token.actions.githubusercontent.com:sub" = ["repo:${var.github_org}/${var.github_repo}"]
            }
        }
      }
    ]
  })
}

# Policy de permissões para a role
resource "aws_iam_policy" "github_actions_policy" {
  name = "${var.organization_name}-${var.environment}-github-action-policy"
  description = "Permissões para CI/CD GitHub Actions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"  # GetAuthorizationToken só funciona com "*" como recurso
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchGetImage"
        ]
        Resource = "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${var.organization_name}-${var.environment}-ecr/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:RegisterTaskDefinition"
        ]
        Resource = "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:task-definition/${var.organization_name}-${var.environment}*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ]
        Resource = [
          "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.organization_name}-${var.environment}*",
          "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:service/${var.organization_name}-${var.environment}*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/ecs/${var.organization_name}-${var.environment}*:*",
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-stream:/aws/ecs/${var.organization_name}-${var.environment}*:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.organization_name}-${var.environment}-task-execution-role",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.organization_name}-${var.environment}-task-role"
        ]
      }
    ]
  })
}

# Anexar a policy à role
resource "aws_iam_role_policy_attachment" "github_actions_attach" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}