variable "name" {
  description = "Controller name"
  type        = string
  default     = "cjoc"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "namespace" {
  description = "Controller namespace"
  type        = string
  default     = ""
}

variable "aws_accounts" {
  description = "AWS Account IDs"
  type        = list(string)
}

variable "service_accounts" {
  description = "Service Account role ARNs"
  type        = list(string)
}

variable "kms_key_id" {
  description = "AWS Service account KMS key ID"
  type        = string
}

variable "token_suffix" {
  description = "service account secret token suffix"
  type        = string
  default     = ""
}

variable "kms_keys" {
  description = "Additional KMS keys"
  type        = list(string)
  default     = []
}

variable "kms_roles" {
  description = "Roles that can use the KMS key"
  type        = list(string)
}

variable "policies" {
  description = "Policies assigned to the service account role"
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

variable "tags" {
  description = "Resources Tags"
  type        = map
}
