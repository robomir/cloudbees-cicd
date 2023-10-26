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

variable "casc_version" {
  description = "Filesystem path to the CasC bundle directory"
  type        = string
}

variable "casc_dir" {
  description = "Filesystem path to the CasC bundle directory"
  type        = string
}

variable "controllers" {
  description = "Cloudbees Controllers"
  type        = map
}

variable "default_csi_secrets" {
  description = "Secrets"
  type        = map
  default     = {}
}

variable "tags" {
  description = "Resources Tags"
  type        = map
}
