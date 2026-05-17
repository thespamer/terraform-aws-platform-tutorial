variable "bucket_name" {
  description = "Nome do bucket."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN opcional. Se vazio, usa SSE-S3."
  type        = string
  default     = null
}

variable "versioning_enabled" {
  description = "Habilita versionamento."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
