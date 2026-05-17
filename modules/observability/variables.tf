variable "name" {
  type        = string
  description = "Nome base."
}

variable "retention_in_days" {
  type        = number
  description = "Retenção de logs."
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = "Tags."
  default     = {}
}
