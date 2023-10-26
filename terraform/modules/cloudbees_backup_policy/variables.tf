variable "name" {
  description = "Controller name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "backup_bucket_name" {
  description = "Backup Bucket name"
  type        = string
}

variable "tags" {
  description = "Resources Tags"
  type        = map
}
