variable "name" {
  description = "secret provider class name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "namespace" {
  description = "Namespace name"
  type        = string
  default     = ""
}

variable "secrets" {
  description = "Secret ARNs"
  type        = list(string)
}

variable "tags" {
  description = "Resources Tags"
  type        = map
}

