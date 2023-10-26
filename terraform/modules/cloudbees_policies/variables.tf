variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "domain" {
  description = "DNS Zone"
  type        = string
  default     = "cloudbees.dev.fsecure.com"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "secrets_account_id" {
  description = "Secrets AWS Account ID"
  type        = string
}

variable "kms_id" {
  description = "Key ID"
  type        = string
}

variable "kms_key_arns" {
  description = "Additional KMS Key ARNs"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Resources Tags"
  type        = map
}

variable "backup_bucket_name" {
  description = "Backup S3 Bucket Name"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "Artifacts S3 Bucket Name"
  type        = string
}

variable "instance_profiles" {
  description = "Instance profile role ARNs"
  type        = list(string)
}
