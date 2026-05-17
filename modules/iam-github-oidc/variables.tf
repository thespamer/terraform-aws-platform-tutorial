variable "github_org_or_user" {
  type        = string
  description = "GitHub org ou usuário."
}

variable "github_repo" {
  type        = string
  description = "GitHub repo."
}

variable "allowed_branch" {
  type        = string
  description = "Branch autorizada."
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID."
}

variable "state_bucket_arn" {
  type        = string
  description = "ARN do bucket de state."
}

variable "kms_key_arn" {
  type        = string
  description = "ARN da KMS key do state."
}
