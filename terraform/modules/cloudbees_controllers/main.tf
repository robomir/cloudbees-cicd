
# cloudbees-${var.env}-controllers namespace used for specific controllers - moved them back to the cloudbees-${env} namespace
# due to some problems with the oc losing control of the client controller in some circumstances

module "cloudbees_namespace_controllers" {
  providers        = {
    kubernetes     = kubernetes
  }
  source           = "../cloudbees_namespace_controllers"
  env              = var.env
  namespace        = "cloudbees-${var.env}-controllers"
  certs_dir        = var.certs_dir
  tags             = local.tags
}

# jenkins serviceaccount is initially created by the Cloudbees helm chart and used
# by default with the client controllers.  In TF we create a service account for each controller
# to allow customizing configuration.

module "jenkins_serviceaccount" {
  providers      = {
    kubernetes   = kubernetes
  }
  source         = "../serviceaccount"
  name           = "jenkins"
  cluster_name   = var.cluster_name
  env            = var.env
  tags           = local.tags
  policies       = []
  token_suffix   = var.jenkins_token_suffix
  secret         = true
}

# Create the secretproviderclass definition to specify which secrets can be mounted using the SecretsManager CSI driver
# in each pod
module "secrets_store" {
  providers      = {
    kubernetes   = kubernetes
  }
  source         = "../cloudbees_secrets_store"
  name           = "controllers"
  env            = var.env
  secrets        = [
    "arn:aws:secretsmanager:us-west-2:${var.secrets_account_id}:secret:cd/cloudbees/${var.env}/github_app",
    "arn:aws:secretsmanager:us-west-2:${var.secrets_account_id}:secret:cd/cloudbees/${var.env}/docker_builder_key",
    "arn:aws:secretsmanager:us-west-2:${var.secrets_account_id}:secret:cd/cloudbees/${var.env}/whitesource-api-key",
    "arn:aws:secretsmanager:us-west-2:${var.secrets_account_id}:secret:cd/cloudbees/${var.env}/whitesource_user_token",
    "arn:aws:secretsmanager:us-west-2:${var.secrets_account_id}:secret:cd/cloudbees/${var.env}/cd-builds_slack_token",
    "arn:aws:secretsmanager:us-west-2:${var.secrets_account_id}:secret:cd/cloudbees/${var.env}/slack-bot-token",
    "arn:aws:secretsmanager:us-west-2:${var.secrets_account_id}:secret:cd/cloudbees/${var.env}/gerrit-creds",
    "arn:aws:secretsmanager:us-west-2:${var.secrets_account_id}:secret:cd/cloudbees/${var.env}/git-credentials"
  ]
  tags           = local.tags
}

module "controllers_secrets_store" {
  providers      = {
    kubernetes   = kubernetes
  }
  source         = "../cloudbees_secrets_store"
  name           = "controllers"
  env            = var.env
  namespace      = "cloudbees-${var.env}-controllers"
  secrets        = [
    "arn:aws:secretsmanager:us-west-2:${var.secrets_account_id}:secret:cd/cloudbees/${var.env}/github_app",
    "arn:aws:secretsmanager:us-west-2:${var.secrets_account_id}:secret:cd/cloudbees/${var.env}/docker_builder_key",
    "arn:aws:secretsmanager:us-west-2:${var.secrets_account_id}:secret:cd/cloudbees/${var.env}/whitesource-api-key",
    "arn:aws:secretsmanager:us-west-2:${var.secrets_account_id}:secret:cd/cloudbees/${var.env}/whitesource_user_token",
    "arn:aws:secretsmanager:us-west-2:${var.secrets_account_id}:secret:cd/cloudbees/${var.env}/cd-builds_slack_token",
    "arn:aws:secretsmanager:us-west-2:${var.secrets_account_id}:secret:cd/cloudbees/${var.env}/slack-bot-token",
    "arn:aws:secretsmanager:us-west-2:${var.secrets_account_id}:secret:cd/cloudbees/${var.env}/gerrit-creds",
    "arn:aws:secretsmanager:us-west-2:${var.secrets_account_id}:secret:cd/cloudbees/${var.env}/git-credentials"
  ]
  tags           = local.tags
}

# Creates resources for all the defined controllers
module "cloudbees_controllers" {
  providers        = {
    aws                = aws
    aws.secrets        = aws.secrets
    aws.secrets-update = aws.secrets-update
    kubernetes         = kubernetes
  }
  for_each           = { for k,v in var.controllers: k => v if lookup(v["config"], "provision", true) }
  source             = "../cloudbees_controller"
  name               = each.key
  namespace          = lookup(each.value.config, "namespace", local.default_namespace)
  cluster_name       = lookup(each.value.config, "cluster_name", var.cluster_name)
  env                = var.env
  aws_accounts       = [ var.aws_account_id, each.value.secrets_account_id ]
  service_accounts   = []
  kms_key_id         = var.config_kms_key_id
  kms_keys           = []
  kms_roles          = concat(var.kms_roles, contains(keys(each.value.config), "team_secret_role") ? [ "arn:aws:iam::${each.value.secrets_account_id}:role/${each.value.config.team_secret_role}" ] : [])
  policies           = []

  owners                      = [ "var.owners" ]

  builder_profile_name        = var.builder_profile_name
  builder_subnet_id           = var.builder_subnet_id
  builder_security_group_name = var.builder_security_group_name

  dcd_builder_profile_name    = var.dcd_builder_profile_name
  instance_cap                = var.instance_cap
  idle_termination_minutes    = var.idle_termination_minutes
  use_instance_profile_for_credentials = var.use_instance_profile_for_credentials

  artifacts_bucket_name = var.artifacts_bucket_name
  backup_bucket_name    = var.backup_bucket_name
  instance_profiles     = contains(keys(each.value.config), "instsance_profiles") ? lookup(each.value.config, "instance_profiles", []) : var.instance_profiles
  domain                = lookup(each.value.config, "domain", var.domain)

  secrets            = length(each.value.secrets) < 1 && ! lookup(each.value.config, "use_global_secrets", true) ? local.default_csi_secrets : each.value.secrets
  controller_secrets = length(each.value.controller_secrets) < 1 && ! lookup(each.value.config, "use_global_secrets", true) ? local.default_controller_secrets : each.value.controller_secrets
  tags               = local.tags
}

# KMS key for shared secrets (e.g. cd/cloudbees/${var.env}/*) stored in the secrets account
module "cloudbees_global_kms_key" {
  providers      = {
    aws          = aws.secrets
  }
  source         = "../cloudbees_kms_key"
  name           = "global"
  env            = var.env
  aws_accounts   = [ var.aws_account_id, var.secrets_account_id ]
  roles          = concat(var.kms_roles, [
    "arn:aws:iam::${var.aws_account_id}:role/eks-iam-cloudbees-${var.env}-jenkins",
  ],
  flatten([for k,v in module.cloudbees_controllers: [for arn in v.service_account_roles: arn]]),
  [for k,v in module.cloudbees_controllers: v.secret_role])
  tags           = local.tags
}

# KMS key for shared secrets stored in the service account
module "cloudbees_global_kms_key_deploy" {
  providers      = {
    aws          = aws
  }
  source         = "../cloudbees_kms_key"
  name           = "global"
  env            = var.env
  aws_accounts   = [ var.aws_account_id, var.secrets_account_id ]
  roles          = concat(
    var.service_roles,
    flatten([for k,v in module.cloudbees_controllers: [for arn in v.service_account_roles: arn]]),
    [for k,v in module.cloudbees_controllers: v.secret_role],
    var.oc_roles)
  tags           = local.tags
}

# Create the shared secrets in the secrets account
resource "aws_secretsmanager_secret" "global_secrets" {
  provider    = aws.secrets-update
  for_each    = merge(local.default_csi_secrets, local.default_controller_secrets, local.default_global_secrets)
  name        = "cd/cloudbees/${var.env}/${each.key}"
  description = "cd/cloudbees/${var.env}/${each.key}"
  kms_key_id  = module.cloudbees_global_kms_key.kms_id
  policy      = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : concat([{
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.aws_account_id}:role/eks-iam-cloudbees-${var.env}-cjoc"
        },      
        "Action" : [ "secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret" ],
        "Resource" : "*"
      },{
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.aws_account_id}:role/eks-iam-cloudbees-${var.env}-jenkins"
        },      
        "Action" : [ "secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret" ],
        "Resource" : "*"
      }], flatten([
      for k,v in module.cloudbees_controllers: [for arn in v.service_account_roles: {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : arn
        },
        "Action" : [ "secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret" ],
        "Resource" : "*"
      }
    ]]))
  })
  tags        = merge(local.tags, {
    product                  = "cd"
    service                  = "cloudbees"
    environment              = var.env
  }, merge({"cloudbees:controller:name" = "all"}, each.value["tags"]))
}

# Create the IAM policy that allows access to the shared KMS key/secrets
resource "aws_iam_policy" "global_secrets" {
  name        = "cloudbees_${var.env}_global_secrets_policy"
  path        = "/"
  description = "Cloudbees Secrets Policy"

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
              "arn:*:secretsmanager:*:*:secret:cd/cloudbees/${var.env}/*"
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
            "Resource": [
              "arn:aws:kms:us-west-2:*:key/${module.cloudbees_global_kms_key_deploy.kms_id}",
              "arn:aws:kms:us-west-2:*:key/${module.cloudbees_global_kms_key.kms_id}"
            ]
        }
    ]
  })
}

#module "jenkins_service_account_policies" {
#  source   = "../cloudbees_policy_attachment"
#  roles    = module.jenkins_serviceaccount.role_name
#  policies = var.policies
#}

module "service_account_policies" {
  for_each = module.cloudbees_controllers
  source   = "../cloudbees_policy_attachment"
  roles    = each.value.service_account_roles
  policies = [
    aws_iam_policy.global_secrets.arn
  ]
}

#
# builder_config/builder_ami modules create secrets in the service account which store config values
# which are used by the CasC bundle when creating the EC2 cloud builder configuration
# (e.g. subnetid, instsancecap, instance profile, etc)
#
module "builder_ami" {
  providers                   = {
    aws                       = aws
  }
  source                      = "../cloudbees_builder_ami"
  name                        = "builder_ami"
  builder_ami_name            = "jenkins-builder-docker"
  env                         = var.env
  kms_key_id                  = module.cloudbees_global_kms_key_deploy.kms_id
  owners = "var.owners"
  tags                        = local.tags
}

module "builder_ami_dcd" {
  providers                   = {
    aws                       = aws
  }
  source                      = "../cloudbees_builder_ami"
  name                        = "builder_ami_dcd"
  builder_ami_name            = "jenkins-builder-declarative-pipelines"
  builder_distributions       = {
    "ubuntu18/amd64" = { "dist" = "bionic", "arch" = "x86_64" }
    "ubuntu20/amd64" = { "dist" = "focal", "arch" = "x86_64" }
  }
  env                         = var.env
  kms_key_id                  = module.cloudbees_global_kms_key_deploy.kms_id
  owners = "var.owners"
  tags                        = local.tags
}

module "builder_config" {
  providers                   = {
    aws                       = aws
  }
  source                      = "../cloudbees_builder_config"
  name                        = "builder_config"
  env                         = var.env
  controller_name             = "module.cloudbees_controllers.name"
  kms_key_id                  = module.cloudbees_global_kms_key_deploy.kms_id
  builder_profile_name        = "jenkins-declarative-pipelines-builder"
  use_instance_profile_for_credentials = var.use_instance_profile_for_credentials
  instance_cap                = var.instance_cap
  builder_subnet_id           = var.builder_subnet_id
  builder_security_group_name = var.builder_security_group_name
  idle_termination_minutes    = var.idle_termination_minutes
  tags                        = local.tags
}

module "dcd_builder_config" {
  providers                   = {
    aws                       = aws
  }
  source                      = "../cloudbees_builder_config"
  name                        = "builder_config_dcd"
  env                         = var.env
  controller_name             = "module.cloudbees_controllers.name"
  kms_key_id                  = module.cloudbees_global_kms_key_deploy.kms_id
  builder_profile_name        = "jenkins-declarative-pipelines-builder"
  builder_subnet_id           = var.builder_subnet_id
  builder_security_group_name = var.builder_security_group_name
  idle_termination_minutes    = "30"
  tags                        = local.tags
}

module "tf_builder_config" {
  providers                   = {
    aws                       = aws
  }
  source                      = "../cloudbees_builder_config"
  name                        = "builder_config_tf"
  env                         = var.env
  controller_name             = "module.cloudbees_controllers.name"
  kms_key_id                  = module.cloudbees_global_kms_key_deploy.kms_id
  builder_profile_name        = "jenkins-declarative-pipelines-builder"
  builder_subnet_id           = var.builder_subnet_id
  builder_security_group_name = var.builder_security_group_name
  idle_termination_minutes    = "60"
  instance_cap                = "10"
  tags                        = local.tags
}

