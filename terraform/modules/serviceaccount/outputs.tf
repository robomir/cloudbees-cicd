output "arn" {
  description = "Service Account Role ARN"
  value       = tostring(aws_iam_role.service_account.arn)
}

output "role_name" {
  description = "Service Account Role name"
  value       = tostring(aws_iam_role.service_account.name)
}
