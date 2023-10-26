data "aws_caller_identity" "secrets" {
  provider = aws.secrets
}

locals {
  secrets_account_id    = data.aws_caller_identity.secrets.account_id
  namespace             = ( var.namespace == "" ? "cloudbees-${var.env}-controllers" : var.namespace )
  controller_secrets    = merge({}, var.controller_secrets)
}

module "secrets_policy" {
  source             = "../cloudbees_secrets_policy"
  name               = var.name
  env                = var.env
  kms_id             = module.cloudbees_secrets.kms_id
  secrets_account_id = local.secrets_account_id
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "attach_serviceaccount" {
  role       = module.serviceaccount.role_name
  policy_arn = module.secrets_policy.arn
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
  policies       = var.policies
  automount_service_account_token = true
  secret         = true
  token_suffix   = "${var.token_suffix}"
#  rolebinding    = true
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
  name           = "oc"
  env            = var.env
  namespace      = local.namespace
  secrets        = [
    for k,v in var.secrets: "arn:aws:secretsmanager:us-west-2:${local.secrets_account_id}:secret:cd/cloudbees/${var.name}/${var.env}/${k}"
  ]
  tags           = var.tags
}
