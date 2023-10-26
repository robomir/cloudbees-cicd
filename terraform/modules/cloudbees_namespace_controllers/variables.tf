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

variable "certs_dir" {
  description = "Path to CA Bundles certs directory"
  type        = string
}

variable "tags" {
  description = "Resources Tags"
  type        = map
}
