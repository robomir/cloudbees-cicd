output "role" {
  description = "Secrets role ARN"
  value       = aws_iam_role.role.arn
}

output "kms_id" {
  description = "KMS Key ID"
  value       = module.cloudbees_kms_key.kms_id
}
