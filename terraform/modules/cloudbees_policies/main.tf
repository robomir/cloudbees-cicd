resource "aws_iam_policy" "artifacts" {
  name        = "cloudbees_${var.env}_read_artifacts_policy"
  path        = "/"
  description = "Cloudbees Read Artifacts Policy"

  policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "VisualEditor0",
              "Effect": "Allow",
              "Action": [
                  "s3:GetObject",
              ],
              "Resource": [
                "arn:aws:s3:::${var.artifacts_bucket_name}/*"
              ]
          },
          {
              "Effect": "Allow",
              "Action": [
                  "s3:GetBucketLocation"
              ],
              "Resource": [
                "arn:aws:s3:::${var.artifacts_bucket_name}"
              ]
          },
          {
              "Sid": "VisualEditor1",
              "Effect": "Allow",
              "Action": [
                  "s3:ListBucket"
              ],
              "Resource": "*"
          }
      ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "backup" {
  name        = "cloudbees_${var.env}_backup_policy"
  path        = "/"
  description = "Cloudbees Backup Policy"

  policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "VisualEditor0",
              "Effect": "Allow",
              "Action": [
                  "s3:PutObject",
                  "s3:GetObject",
                  "s3:DeleteObject"
              ],
              "Resource": [
                "arn:aws:s3:::${var.backup_bucket_name}/*",
                "arn:aws:s3:::${var.artifacts_bucket_name}/*"
              ]
          },
          {
              "Effect": "Allow",
              "Action": [
                  "s3:GetBucketLocation"
              ],
              "Resource": [
                "arn:aws:s3:::${var.artifacts_bucket_name}"
              ]
          },
          {
              "Sid": "VisualEditor1",
              "Effect": "Allow",
              "Action": [
                  "s3:ListBucket"
              ],
              "Resource": "*"
          }
      ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "ec2_builders" {
  name        = "cloudbees_${var.env}_ec2_builders"
  path        = "/"
  description = "Cloudbees EC2 Builders Policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "cloudbeesec2cloud",
            "Action": [
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:TerminateInstances"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:ec2:*:*:instance/*",
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/created_by": [
                      "*.${var.domain}",
                      "${var.domain}"
                    ]
                }
            }
        },
        {
            "Action": [
                "ec2:DescribeSpotInstanceRequests",
                "ec2:CancelSpotInstanceRequests",
                "ec2:GetConsoleOutput",
                "ec2:RequestSpotInstances",
                "ec2:RunInstances",
                "ec2:CreateTags",
                "ec2:DeleteTags",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeRegions",
                "ec2:DescribeImages",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "iam:ListInstanceProfilesForRole",
                "ec2:GetPasswordData"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "iam:PassRole"
            ],
            "Effect": "Allow",
            "Resource": var.instance_profiles
        }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "secrets" {
  name        = "cloudbees_${var.env}_secrets_policy"
  path        = "/"
  description = "Cloudbees Secrets Policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sts:AssumeRole"
            ],
            "Effect": "Allow",
            "Resource": [
              "arn:aws:iam::${var.aws_account_id}:role/eks-iam-cloudbees-${var.env}-jenkins-secrets",
              "arn:aws:iam::${var.secrets_account_id}:role/eks-iam-cloudbees-${var.env}-jenkins-secrets"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": [
                "arn:*:secretsmanager:*:*:secret:cd/cloudbees/${var.env}/*",
                "arn:*:secretsmanager:*:*:secret:cd/cloudbees/oc/${var.env}/*"
            ]
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
            "Resource": concat([
              "arn:aws:kms:us-west-2:${var.aws_account_id}:key/${var.kms_id}",
            ], var.kms_key_arns)
        }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "cjoc_secrets" {
  name        = "cloudbees_${var.env}_cjoc_common_secrets_policy"
  path        = "/"
  description = "cloudbees_${var.env}_cjoc_common_secrets_policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": [
                "arn:*:secretsmanager:*:*:secret:cd/cloudbees/oc/${var.env}/*",
                "arn:*:secretsmanager:*:*:secret:cd/cloudbees/cjoc/${var.env}/*"
            ]
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
            "Resource": concat([
              "arn:aws:kms:us-west-2:${var.aws_account_id}:key/${var.kms_id}",
            ], var.kms_key_arns)
        }
    ]
  })

  tags = var.tags
}
