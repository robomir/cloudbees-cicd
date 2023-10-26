variable "name" {
  description = "Controller name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "domain" {
  description = "DNS Zone"
  type        = string
}

variable "instance_profiles" {
  description = "Instance profile role ARNs"
  type        = list(string)
}

variable "tags" {
  description = "Resources Tags"
  type        = map
}
