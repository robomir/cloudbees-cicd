output "service_account_roles" {
  description = "Controller service account role ARN"
  value       = concat([module.serviceaccount.arn], var.service_accounts)
}

output "secret_role" {
  description = "Controller secret role ARN"
  value       = module.cloudbees_secrets.role
}
