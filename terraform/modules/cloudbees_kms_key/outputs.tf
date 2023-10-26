output "kms_id" {
  description = "KMS Key ID"
  value       = aws_kms_key.cloudbees.id
}

output "kms_arn" {
  description = "KMS Key ARN"
  value       = aws_kms_key.cloudbees.arn
}
