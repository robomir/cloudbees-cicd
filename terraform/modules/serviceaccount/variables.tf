variable "automount_service_account_token" {
  description = "Service account token"
  type        = bool
  default     = true
}

variable "name" {
  description = "Service account name"
  type        = string
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
  description = "Namespace name"
  type        = string
  default     = ""
}

variable "policies" {
  description = "IAM Policies to be attached to role"
  type        = list
}

variable "secret" {
  description = "Create a secret for the serviceaccount"
  type        = bool
  default     = false
}

variable "rolebinding" {
  description = "Create a rolebinding for the serviceaccount"
  type        = bool
  default     = false
}

variable "token_suffix" {
  type        = string
  default     = ""
}

variable "tags" {
  description = "Resources Tags"
  type        = map
}
