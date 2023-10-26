variable "name" {
  description = "Controller name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "aws_accounts" {
  description = "AWS Account IDs"
  type        = list(string)
}

variable "service_accounts" {
  description = "Service Account role ARNs"
  type        = list(string)
}

variable "kms_roles" {
  description = "Roles that can use the KMS key"
  type        = list(string)
}

variable "kms_keys" {
  description = "Additional KMS keys"
  type        = list(string)
}

variable "secrets" {
  description = "Secrets"
  type        = map
}

variable "controller_secrets" {
  description = "Secrets"
  type        = map
  default     = {}
}

variable "use_global_secrets" {
  description = "Allow access to global cloudbees secrets"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Resources Tags"
  type        = map
}
