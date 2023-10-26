variable "name" {
  description = "secret name"
  type        = string
  default     = "builder_config"
}

variable "controller_name" {
  description = "Controller name"
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

variable "kms_key_id" {
  description = "AWS Service account KMS key ID"
  type        = string
}

variable "builder_profile_name" {
  description = "Builder instance profile name"
  type        = string
}

variable "builder_subnet_id" {
  description = "Builder subnet id"
  type        = string
}

variable "builder_security_group_name" {
  description = "Builder security group name"
  type        = string
  default     = "jenkins-builder"
}

variable "instance_cap" {
  description = "Builder instance cap"
  type        = string
  default     = "20"
}

variable "idle_termination_minutes" {
  description = "Builder idle termination"
  type        = string
  default     = "15"
}

variable "use_instance_profile_for_credentials" {
  description = "Builder use instance profile credentials"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Resources Tags"
  type        = map
}
