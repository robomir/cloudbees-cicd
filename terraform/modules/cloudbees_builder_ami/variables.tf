variable "name" {
  description = "secret name"
  type        = string
  default     = "builder_ami"
}

variable "controller_name" {
  description = "Controller name"
  type        = string
  default     = ""
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

variable "kms_key_id" {
  description = "AWS Service account KMS key ID"
  type        = string
}

variable "builder_ami_name" {
  description = "Builder ami name"
  type        = string
}

variable "builder_distributions" {
  description = "Builder distributions"
  type        = map
  default     = {}
}

variable "owners" {
  description = "AMI owner account ID"
  type        = string
}

variable "tags" {
  description = "Resources Tags"
  type        = map
}
