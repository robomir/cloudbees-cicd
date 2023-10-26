variable "name" {
  description = "Key Name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "aws_accounts" {
  description = "AWS Account IDs"
  type        = list(string)
}

variable "roles" {
  description = "AWS Role ARNs that can use this key"
  type        = list(string)
}

variable "tags" {
  description = "Resources Tags"
  type        = map
}
