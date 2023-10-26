variable "name" {
  description = "Controller name"
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

variable "builder_profile_name" {
  description = "Builder instance profile name"
  type        = string
  default     = "ci-builder"
}

variable "dcd_builder_profile_name" {
  description = "DCD Builder instance profile name"
  type        = string
  default     = "jenkins-declarative-pipelines-builder"
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

variable "controller_secrets" {
  description = "Secrets"
  type        = map
  default     = {}
}

variable "domain" {
  description = "Controller domain name"
  type        = string
}

variable "instance_profiles" {
  description = "Instance profiles that can be passed to EC2 builders"
  type        = list(string)
}

variable "artifacts_bucket_name" {
  description = "Artifacts bucket name"
  type        = string
}

variable "backup_bucket_name" {
  description = "Backup bucket name"
  type        = string
}

variable "owners" {
  description = "AMI account IDs"
  type        = list(string)
}

variable "tags" {
  description = "Resources Tags"
  type        = map
}
