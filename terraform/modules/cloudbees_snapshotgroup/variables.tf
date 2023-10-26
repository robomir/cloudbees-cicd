variable "name" {
  description = "Controller name"
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

variable "keep" {
  description = "Days to keep snapshot history"
  type        = string
}

variable "tags" {
  description = "Resources Tags"
  type        = map
}

