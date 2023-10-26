
variable "roles" {
  description = "IAM roles"
  type        = list(string)
}

variable "policies" {
  description = "Policies assigned to the role"
  type        = list(string)
}
