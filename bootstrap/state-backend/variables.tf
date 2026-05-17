variable "aws_region" {
  description = "Região AWS."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Nome globalmente único do bucket S3 para Terraform state."
  type        = string
}

variable "github_org_or_user" {
  description = "Organização ou usuário GitHub autorizado no OIDC."
  type        = string
}

variable "github_repo" {
  description = "Nome do repositório GitHub autorizado no OIDC."
  type        = string
}

variable "allowed_branch" {
  description = "Branch autorizada para assumir role via OIDC."
  type        = string
  default     = "main"
}

variable "tags" {
  description = "Tags padrão."
  type        = map(string)
  default = {
    Project     = "terraform-aws-platform-tutorial"
    Environment = "bootstrap"
  }
}
