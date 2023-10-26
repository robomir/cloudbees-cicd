resource "aws_iam_policy" "artifacts" {
  name        = "cloudbees_${var.env}_${var.name}_artifacts_policy"
  path        = "/"
  description = "Cloudbees ${var.name} Artifacts Policy"

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
                "arn:aws:s3:::${var.artifacts_bucket_name}/${var.name}/*"
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
