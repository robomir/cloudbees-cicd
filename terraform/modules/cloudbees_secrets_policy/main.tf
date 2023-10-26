resource "aws_iam_policy" "secrets" {
  name        = "cloudbees_${var.env}_${var.name}_secrets_policy"
  path        = "/"
  description = "Cloudbees ${var.name} Secrets Policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sts:AssumeRole"
            ],
            "Effect": "Allow",
            "Resource": [
              "arn:aws:iam::${var.secrets_account_id}:role/eks-iam-cloudbees-${var.env}-${var.name}-secrets"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": concat([
                for path in var.secrets_paths: "arn:*:secretsmanager:*:*:secret:cd/cloudbees/${path}/*"
            ], [
                "arn:*:secretsmanager:*:*:secret:cd/cloudbees/${var.name}/${var.env}/*"
            ])
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
            "Resource": "arn:aws:kms:us-west-2:*:key/${var.kms_id}"
        }
    ]
  })
}
