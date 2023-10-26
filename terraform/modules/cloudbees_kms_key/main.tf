terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20"
    }
  }
}

locals {
  policy = length(var.roles) > 0 || length(var.aws_accounts) > 0 ? jsonencode({
    "Version": "2012-10-17",
    "Id": "KMSCloudbees",
    "Statement": concat([
        for account in var.aws_accounts: {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${account}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        }],[
        for arn in var.roles: {
            "Sid": "Role",
            "Effect": "Allow",
            "Principal": {
                "AWS": arn
            },
            "Action": [
                "kms:*"
            ],
            "Resource": "*"
        }
    ])
  }) : null
}

resource "aws_kms_key" "cloudbees" {
  description = "Cloudbees ${var.env} ${var.name} Secrets KMS Key"

  policy = local.policy

  tags = var.tags
}

resource "aws_kms_alias" "key_name" {
  name          = "alias/secretsmanager/cloudbees-${var.env}-${var.name}"
  target_key_id = aws_kms_key.cloudbees.key_id
}
