output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions.arn
  description = "ARN da role assumida pelo GitHub Actions."
}
