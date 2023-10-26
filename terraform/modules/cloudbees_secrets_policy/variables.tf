variable "name" {
  description = "Controller name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "kms_id" {
  description = "ID of the KMS key"
  type        = string
}

variable "secrets_account_id" {
  description = "Secrets AWS Account ID"
  type        = string
}

variable "secrets_paths" {
  description = "Additional secret paths"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Resources Tags"
  type        = map
}
