output "vpc_id" {
  value       = module.network.vpc_id
  description = "VPC ID."
}

output "artifact_bucket_name" {
  value       = module.artifact_bucket.bucket_name
  description = "Bucket de artefatos."
}

output "log_group_name" {
  value       = module.observability.log_group_name
  description = "CloudWatch Log Group."
}
