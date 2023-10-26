
variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "secrets_account_id" {
  description = "AWS Secrets Account ID"
  type        = string
}

variable "datadog_api_key" {
  type        = string
}

variable "aws_profile" {
  description = "AWS Profile"
  type        = string
}

variable "aws_secrets_profile" {
  description = "AWS Secrets Profile"
  type        = string
}

variable "aws_role" {
  description = "AWS Role"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "controllers" {
  description = "Cloudbees Controllers"
  type        = map
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
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

variable "cjoc_token_suffix" {
  description = "secret token suffix"
  type        = string
  default     = ""
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
