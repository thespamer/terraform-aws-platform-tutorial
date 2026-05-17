variable "aws_region" {
  type        = string
  description = "Região AWS."
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Nome do projeto."
}

variable "environment" {
  type        = string
  description = "Ambiente."
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment deve ser dev, staging ou prod."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR da VPC."
}

variable "availability_zones" {
  type        = list(string)
  description = "AZs."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs das subnets públicas."
}
