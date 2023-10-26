resource "aws_iam_policy" "backup" {
  name        = "cloudbees_${var.env}_${var.name}_backup_policy"
  path        = "/"
  description = "Cloudbees ${var.name} Backup Policy"

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
                "arn:aws:s3:::${var.backup_bucket_name}/controllers/${var.name}/*",
                "arn:aws:s3:::${var.backup_bucket_name}/controllers/*"
              ]
          },
          {
              "Effect": "Allow",
              "Action": [
                  "s3:GetBucketLocation"
              ],
              "Resource": [
                "arn:aws:s3:::${var.backup_bucket_name}"
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
