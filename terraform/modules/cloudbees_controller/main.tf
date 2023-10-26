terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20"
      configuration_aliases = [ aws, aws.secrets, aws.secrets-update ]
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.5.0"
      configuration_aliases = [ kubernetes ]
    }
  }
}

data "aws_caller_identity" "secrets" {
  provider = aws.secrets
}

locals {
  secrets_account_id    = data.aws_caller_identity.secrets.account_id
  namespace             = ( var.namespace == "" ? "cloudbees-${var.env}-controllers" : var.namespace )
  controller_secrets    = merge({}, var.controller_secrets)
  builder_distributions = {
    "ubuntu18/arm64"    = { "dist" = "bionic", "arch" = "arm64" }
    "ubuntu18/amd64"    = { "dist" = "bionic", "arch" = "x86_64" }
    "ubuntu20/arm64"    = { "dist" = "focal", "arch" = "arm64" }
    "ubuntu20/amd64"    = { "dist" = "focal", "arch" = "x86_64" }
  }
  builder_distributions_dcd = {
    "ubuntu18/amd64"        = { "dist" = "bionic", "arch" = "x86_64" }
    "ubuntu20/amd64"        = { "dist" = "focal", "arch" = "x86_64" }
  }
}

module "secrets_policy" {
  source             = "../cloudbees_secrets_policy"
  name               = var.name
  env                = var.env
  kms_id             = module.cloudbees_secrets.kms_id
  secrets_account_id = local.secrets_account_id
  tags               = var.tags
}

module "builder_policy" {
  source             = "../cloudbees_builder_policy"
  name               = var.name
  env                = var.env
  domain             = var.domain
  instance_profiles  = var.instance_profiles
  tags               = var.tags
}

module "artifacts_policy" {
  source                = "../cloudbees_artifacts_policy"
  name                  = var.name
  env                   = var.env
  artifacts_bucket_name = var.artifacts_bucket_name
  tags                  = var.tags
}

module "backup_policy" {
  source                = "../cloudbees_backup_policy"
  name                  = var.name
  env                   = var.env
  backup_bucket_name    = var.backup_bucket_name
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "attach_serviceaccount" {
  role       = module.serviceaccount.role_name
  policy_arn = module.secrets_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_builder_serviceaccount" {
  role       = module.serviceaccount.role_name
  policy_arn = module.builder_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_artifacts_serviceaccount" {
  role       = module.serviceaccount.role_name
  policy_arn = module.artifacts_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_backup_serviceaccount" {
  role       = module.serviceaccount.role_name
  policy_arn = module.backup_policy.arn
}

module "serviceaccount" {
  providers      = {
    kubernetes   = kubernetes
  }
  source         = "../serviceaccount"
  name           = var.name
  cluster_name   = var.cluster_name
  env            = var.env
  namespace      = local.namespace
  tags           = var.tags
  policies       = concat([], var.policies)
  automount_service_account_token = true
  secret         = true
  rolebinding    = true
}

module "cloudbees_secrets" {
  providers           = {
    aws.secrets        = aws.secrets
    aws.secrets-update = aws.secrets-update
  }
  source              = "../cloudbees_secrets"
  name                = var.name
  env                 = var.env
  aws_accounts        = var.aws_accounts
  service_accounts    = concat([module.serviceaccount.arn], var.service_accounts)
  kms_roles           = var.kms_roles
  kms_keys            = var.kms_keys
  secrets             = var.secrets
  controller_secrets  = local.controller_secrets
  tags                = var.tags
}

module "secrets_store" {
  providers      = {
    kubernetes   = kubernetes
  }
  source         = "../cloudbees_secrets_store"
  name           = "controller-${var.name}"
  env            = var.env
  namespace      = local.namespace
  secrets        = [
    for k,v in var.secrets: "arn:aws:secretsmanager:us-west-2:${local.secrets_account_id}:secret:cd/cloudbees/${var.name}/${var.env}/${k}"
  ]
  tags           = var.tags
}

module "cloudbees_controller_kms_key_deploy" {
  providers      = {
    aws          = aws
  }
  source         = "../cloudbees_kms_key"
  name           = var.name
  env            = var.env
  aws_accounts   = [ for id in var.aws_accounts : id if id != local.secrets_account_id ]
  roles          = concat([module.serviceaccount.arn], var.service_accounts)
  tags           = var.tags
}

module "builder_config" {
  providers                   = {
    aws                       = aws
  }
  source                      = "../cloudbees_builder_config"
  name                        = "builder_config"
  controller_name             = var.name
  env                         = var.env
  namespace                   = local.namespace
  kms_key_id                  = module.cloudbees_controller_kms_key_deploy.kms_id
  builder_profile_name        = "jenkins-declarative-pipelines-builder"
  use_instance_profile_for_credentials = var.use_instance_profile_for_credentials
  instance_cap                = var.instance_cap
  builder_subnet_id           = var.builder_subnet_id
  builder_security_group_name = var.builder_security_group_name
  idle_termination_minutes    = var.idle_termination_minutes
  tags                        = var.tags
}

module "dcd_builder_config" {
  providers                   = {
    aws                       = aws
  }
  source                      = "../cloudbees_builder_config"
  name                        = "builder_config_dcd"
  controller_name             = var.name
  env                         = var.env
  namespace                   = local.namespace
  kms_key_id                  = module.cloudbees_controller_kms_key_deploy.kms_id
  builder_profile_name        = "jenkins-declarative-pipelines-builder"
  builder_subnet_id           = var.builder_subnet_id
  builder_security_group_name = var.builder_security_group_name
  idle_termination_minutes    = "30"
  tags                        = var.tags
}

module "tf_builder_config" {
  providers                   = {
    aws                       = aws
  }
  source                      = "../cloudbees_builder_config"
  name                        = "builder_config_tf"
  controller_name             = var.name
  env                         = var.env
  namespace                   = local.namespace
  kms_key_id                  = module.cloudbees_controller_kms_key_deploy.kms_id
  builder_profile_name        = "jenkins-declarative-pipelines-builder"
  builder_subnet_id           = var.builder_subnet_id
  builder_security_group_name = var.builder_security_group_name
  idle_termination_minutes    = "60"
  instance_cap                = "10"
  tags                        = var.tags
}

module "builder_ami" {
  providers                   = {
    aws                       = aws
  }
  source                      = "../cloudbees_builder_ami"
  name                        = "builder_ami"
  controller_name             = var.name
  builder_ami_name            = "jenkins-builder-docker"
  env                         = var.env
  kms_key_id                  = module.cloudbees_controller_kms_key_deploy.kms_id
#  owner = [ var.owner ]
  owners = "var.owners"
  tags                        = var.tags
}

module "builder_ami_dcd" {
  providers                   = {
    aws                       = aws
  }
  source                      = "../cloudbees_builder_ami"
  name                        = "builder_ami_dcd"
  controller_name             = var.name
  builder_ami_name            = "jenkins-builder-declarative-pipelines"
  builder_distributions       = {
    "ubuntu18/amd64" = { "dist" = "bionic", "arch" = "x86_64" }
    "ubuntu20/amd64" = { "dist" = "focal", "arch" = "x86_64" }
  }
  env                         = var.env
  kms_key_id                  = module.cloudbees_controller_kms_key_deploy.kms_id
  owners = "var.owners"
  tags                        = var.tags
}

#module "cloudbees_snapshotgroup" {
#  providers     = {
#    kubernetes  = kubernetes
#  }
#  source             = "../cloudbees_snapshotgroup"
#  name          = var.name
#  namespace     = local.namespace
#  env           = var.env
#  keep          = var.env == "dev" ? 1 : 7
#  tags        = merge({
#    product                  = "cd"
#    service                  = "cloudbees"
#    environment              = var.env
#  }, merge({"cloudbees:controller:name" = "controller:${var.name}:"}, var.tags))
#}
