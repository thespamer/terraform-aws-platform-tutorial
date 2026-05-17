output "bucket_name" {
  value       = aws_s3_bucket.this.bucket
  description = "Nome do bucket."
}

output "bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "ARN do bucket."
}
