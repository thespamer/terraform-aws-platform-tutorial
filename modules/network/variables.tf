variable "name" {
  description = "Nome base da rede."
  type        = string
}

variable "cidr_block" {
  description = "CIDR da VPC."
  type        = string
}

variable "availability_zones" {
  description = "Lista de AZs."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDRs das subnets públicas."
  type        = list(string)
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}
