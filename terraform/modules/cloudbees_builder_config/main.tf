locals {
  controller_path    = length(var.controller_name) == 0 ? "" : "${var.controller_name}/"
  controller_tag     = length(var.controller_name) == 0 ? "all" : "controller:${var.controller_name}:"
}


resource "aws_secretsmanager_secret" "config" {
  provider    = aws
  name        = "cd/cloudbees/${local.controller_path}${var.env}/${var.name}"
  description = "cd/cloudbees/${local.controller_path}${var.env}/${var.name}"
  kms_key_id  = var.kms_key_id

#  policy      = jsonencode({
#    "Version" : "2012-10-17",
#    "Statement" : [
#      for arn in var.service_accounts: {
#        "Effect" : "Allow",
#        "Principal" : {
#          "AWS" : arn
#        },
#        "Action" : [ "secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret" ],
#        "Resource" : "*"
#      }
#    ]
#  })

  tags        = merge({
    product                  = "cd"
    service                  = "cloudbees"
    environment              = var.env
  }, merge({"cloudbees:controller:name" = "${local.controller_tag}"}, var.tags))
}

data "aws_iam_role" "builder_profile" {
  provider    = aws
  name        = var.builder_profile_name
}

resource "aws_secretsmanager_secret_version" "config" {
  provider      = aws
  secret_id     = aws_secretsmanager_secret.config.id
  secret_string = jsonencode({
    iamInstanceProfile               = replace(data.aws_iam_role.builder_profile.arn, "role", "instance-profile")
    useInstanceProfileForCredentials = var.use_instance_profile_for_credentials
    instanceCapStr                   = var.instance_cap
    subnetId                         = var.builder_subnet_id
    idleTerminationMinutes           = var.idle_termination_minutes
    securityGroups                   = var.builder_security_group_name
    "arm64/javaPath"                 = "/usr/lib/jvm/java-1.11.0-openjdk-arm64/bin/java"
    "amd64/javaPath"                 = "/usr/lib/jvm/java-1.11.0-openjdk-amd64/bin/java"
  })
}
