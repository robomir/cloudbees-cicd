variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "secrets_account_id" {
  description = "AWS Secrets Account ID"
  type        = string
}

variable "certs_dir" {
  description = "Path to CA Bundles certs directory"
  type        = string
}

variable "policies" {
  description = "Service account role policies"
  type        = list(string)
}

variable "controllers" {
  description = "Cloudbees controllers"
  type        = map
}

variable "kms_roles" {
  description = "Roles that can use the KMS key"
  type        = list(string)
}

variable "oc_roles" {
  description = "Roles used by the Cloudbees Operations Center"
  type        = list(string)
}

variable "service_roles" {
  description = "Roles used in the service AWS account"
  type        = list(string)
}

variable "domain" {
  description = "DNS Zone"
  type        = string
  default     = "cloudbees.dev.flexilis.com"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "backup_bucket_name" {
  description = "S3 Bucket name"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "S3 Bucket name"
  type        = string
}

variable "instance_profiles" {
  description = "Builder Instance Profile ARNs"
  type        = list(string)
}

variable "builder_profile_name" {
  description = "Builder instance profile name"
  type        = string
  default     = "ci-builder"
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

variable "dcd_builder_profile_name" {
  description = "DCD Builder instance profile name"
  type        = string
  default     = "jenkins-declarative-pipelines-builder"
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

variable "jenkins_token_suffix" {
  description = "secret token suffix"
  type        = string
  default     = ""
}

variable "config_kms_key_id" {
  description = "Cloudbees deployment KMS key for secrets loaded by CasC"
  type        = string
}

variable "tags" {
  description = "Resources Tags"
  type        = map
}
