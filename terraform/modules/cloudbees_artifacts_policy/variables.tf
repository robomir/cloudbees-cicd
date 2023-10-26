variable "name" {
  description = "Controller name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "artifacts_bucket_name" {
  description = "Artifacts Bucket name"
  type        = string
}

variable "tags" {
  description = "Resources Tags"
  type        = map
}
