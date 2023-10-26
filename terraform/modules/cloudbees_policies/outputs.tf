
output "artifacts_arn" {
  description = "Artifacts policy ARN"
  value       = aws_iam_policy.artifacts.arn
}

output "backup_arn" {
  description = "Backup policy ARN"
  value       = aws_iam_policy.backup.arn
}

output "secrets_arn" {
  description = "Secrets policy ARN"
  value       = aws_iam_policy.secrets.arn
}

output "cjoc_secrets_arn" {
  description = "Secrets CJOC policy ARN"
  value       = aws_iam_policy.cjoc_secrets.arn
}

output "ec2_builders_arn" {
  description = "EC2 Builders policy ARN"
  value       = aws_iam_policy.ec2_builders.arn
}
