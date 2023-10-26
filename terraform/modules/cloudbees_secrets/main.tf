terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20"
      configuration_aliases = [ aws.secrets, aws.secrets-update ]
    }
  }
}

locals {
  role_name          = "eks-iam-cloudbees-${var.env}-${var.name}-secrets"
}

module "cloudbees_kms_key" {
  providers      = {
    aws          = aws.secrets
  }
  source         = "../cloudbees_kms_key"
  name           = var.name
  env            = var.env
  aws_accounts   = var.aws_accounts
  roles          = concat([aws_iam_role.role.arn], var.kms_roles)
  tags           = var.tags
}

resource "aws_iam_policy" "secrets" {
  provider    = aws.secrets
  name        = "cloudbees_${var.env}_${var.name}_secrets_policy"
  path        = "/"
  description = "Cloudbees ${var.name} Secrets Policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": concat([
                "arn:*:secretsmanager:*:*:secret:cd/cloudbees/${var.name}/${var.env}/*"
            ], var.use_global_secrets ? [
                "arn:*:secretsmanager:*:*:secret:cd/cloudbees/${var.env}/*"
            ] : [])
        },
        {
            "Sid": "AllowJenkinsToListSecrets",
            "Effect": "Allow",
            "Action": "secretsmanager:ListSecrets",
            "Resource": "*"
        },
        {
            "Sid": "AllowKmsDecrypt",
            "Effect": "Allow",
            "Action": [
              "kms:Decrypt",
              "kms:DescribeKey"
            ],
            "Resource": concat(
            [ "arn:aws:kms:us-west-2:*:key/${module.cloudbees_kms_key.kms_id}" ],
            [ for key in var.kms_keys: "arn:aws:kms:us-west-2:*:key/${key}" ]
            )
        }
    ]
  })
}

resource "aws_iam_role" "role" {
  provider    = aws.secrets
  name        = "${local.role_name}"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      for arn in var.service_accounts: {
        "Effect": "Allow",
        "Principal": {
          "AWS": arn
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })

  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "secrets" {
  provider   = aws.secrets
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.secrets.arn
}

resource "aws_secretsmanager_secret" "secret" {
  provider    = aws.secrets-update
  for_each    = var.secrets
  name        = "cd/cloudbees/${var.name}/${var.env}/${each.key}"
  description = "cd/cloudbees/${var.name}/${var.env}/${each.key}"
  kms_key_id  = module.cloudbees_kms_key.kms_id
  policy      = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      for arn in var.service_accounts: {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : arn
        },
        "Action" : [ "secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret" ],
        "Resource" : "*"
      }
    ]
  })

  tags        = merge(var.tags, {
    product                  = "cd"
    service                  = "cloudbees"
    environment              = var.env
  }, merge({"cloudbees:controller:name" = "controller:${var.name}:"}, each.value["tags"]))

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_secretsmanager_secret" "controller_secret" {
  provider    = aws.secrets-update
  for_each    = var.controller_secrets
  name        = "cd/cloudbees/${var.name}/${var.env}/${each.key}"
  description = "cd/cloudbees/${var.name}/${var.env}/${each.key}"
  kms_key_id  = module.cloudbees_kms_key.kms_id
  policy      = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      for arn in var.service_accounts: {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : arn
        },
        "Action" : [ "secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret" ],
        "Resource" : "*"
      }
    ]
  })
  tags        = merge(var.tags, {
    product                  = "cd"
    service                  = "cloudbees"
    environment              = var.env
  }, merge({"cloudbees:controller:name" = "controller:${var.name}:"}, each.value["tags"]))

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "controller_secret_value" {
  provider      = aws.secrets-update
  for_each      = { for k,v in var.controller_secrets : k => v if contains(keys(v), "value") }
  secret_id     = aws_secretsmanager_secret.controller_secret[each.key].id
  secret_string = each.value.value
}
