output "state_bucket_name" {
  value       = aws_s3_bucket.tfstate.bucket
  description = "Nome do bucket S3 de state."
}

output "state_bucket_arn" {
  value       = aws_s3_bucket.tfstate.arn
  description = "ARN do bucket S3 de state."
}

output "kms_key_arn" {
  value       = aws_kms_key.tfstate.arn
  description = "ARN da KMS key do state."
}

output "github_actions_role_arn" {
  value       = module.github_oidc.github_actions_role_arn
  description = "Role ARN para GitHub Actions via OIDC."
}
