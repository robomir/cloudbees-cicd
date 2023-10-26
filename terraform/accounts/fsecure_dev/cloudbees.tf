# S3 bucket for cloudbees backups
module "cloudbees_backup" {
  source         = "../../modules/s3_bucket"
  name           = var.backup_bucket_name
  tags           = local.tags
}

# S3 bucket for cloudbees artifacts
module "cloudbees_artifacts" {
  source         = "../../modules/s3_bucket"
  name           = var.artifacts_bucket_name
  tags           = local.tags
}

module "cloudbees_global_kms_key" {
  source = "../../modules/cloudbees_kms_key"
  name = "cloudbees_global_kms_key"
  roles = ["fsecure-shadow-stack-tooling-admin"]
  aws_accounts = ["956018147332"]
  tags = local.tags
}

module "cloudbees_policies" {
  source                = "../../modules/cloudbees_policies"
  env                   = var.environment
  domain                = var.domain
  aws_account_id        = var.aws_account_id
  secrets_account_id    = var.secrets_account_id
  kms_id                = var.config_kms_key_id
  kms_key_arns          = [ module.cloudbees_global_kms_key.kms_arn ]
  backup_bucket_name    = var.backup_bucket_name
  artifacts_bucket_name = var.artifacts_bucket_name
  instance_profiles     = var.instance_profiles
  tags                  = local.tags
}

module "oc_casc_configmap" {
  providers      = {
    kubernetes   = kubernetes
  }
  source              = "../../modules/cloudbees_oc_casc_configmap"
  env                 = var.environment
  casc_version        = local.oc_casc_version
  casc_dir            = "${path.root}/../../../casc/oc"
  controllers         = var.controllers
  default_csi_secrets = local.default_csi_secrets
  tags                = local.tags
}

module "cloudbees_oc" {
  providers        = {
    aws                = aws
    aws.secrets        = aws.secrets
    aws.secrets-update = aws.secrets-update
    kubernetes         = kubernetes
#    kubernetes.nonfr   = kubernetes.nonfr
  }
  source             = "../../modules/cloudbees_oc"
  namespace          = "cloudbees-${var.environment}"
  cluster_name       = var.cluster_name
  env                = var.environment
  aws_accounts       = [ var.aws_account_id, var.secrets_account_id ]
  service_accounts   = []
  kms_key_id         = var.config_kms_key_id
  kms_roles          = [
    "arn:aws:iam::${var.secrets_account_id}:role/${var.aws_secrets_profile}",
    "arn:aws:iam::${var.secrets_account_id}:role/${var.aws_secrets_profile}-secrets"
  ]
  policies           = [
    module.cloudbees_policies.backup_arn,
    module.cloudbees_policies.secrets_arn,
    module.cloudbees_policies.cjoc_secrets_arn
  ]

  token_suffix       = var.cjoc_token_suffix
  secrets            = {
    eks-sse-credentials = {
      mountPath  = "/run/secrets/eks-sse-credentials"
      tags       = {
        "jenkins:credentials:type"     = "string"
      }
    },
    "eks-${var.environment}-credentials" = {
      mountPath  = "/run/secrets/eks-${var.environment}-credentials"
      tags       = {
        "jenkins:credentials:type"     = "string"
      }
    },
    cloudbees-token = {
      mountPath  = "/run/secrets/cloudbees-token"
      tags       = {
        "jenkins:credentials:type" = "string"
      }
    },
    github-token = {
      mountPath  = "/run/secrets/github-token"
      tags       = {
        "jenkins:credentials:type" = "string"
      }
    },
    secret_key = {
      mountPath  = "/run/secrets/secret_key"
      tags       = {
        "jenkins:credentials:type" = "string"
      }
    },
    instance_id = {
      mountPath  = "/run/secrets/instance_id"
      tags       = {
        "jenkins:credentials:type" = "string"
      }
    },
    "secrets.properties" = {
      mountPath  = "/run/secrets/secrets.properties"
      tags       = {
        "jenkins:credentials:type"     = "string"
      }
    },
    gerrit-creds = {
      mountPath  = "/var/jenkins_home/.ssh/id_rsa"
      tags       = {
        "jenkins:credentials:type"     = "sshUserPrivateKey"
        "jenkins:credentials:username" = "jenkins"
      }
    },
    git-credentials = {
      mountPath  = "/run/secrets/git-credentials"
      tags       = {
        "jenkins:credentials:type"     = "sshUserPrivateKey"
        "jenkins:credentials:username" = "git"
      }
    }
  }
  controller_secrets = merge({
    cloudbees-token = {
      tags = {
        "jenkins:credentials:type" = "string"
      }
    },
    github-token = {
      tags = {
        "jenkins:credentials:type" = "string"
      }
    },
    secret_key  = {
      tags = {
        "jenkins:credentials:type" = "string"
      }
    },
    instance_id = {
      tags = {
        "jenkins:credentials:type" = "string"
      }
    },
    "secrets.properties" = {
      tags = {
        "jenkins:credentials:type" = "string"
      }
    },
    gerrit-creds = {
      tags = {
        "jenkins:credentials:type"     = "sshUserPrivateKey"
        "jenkins:credentials:username" = "jenkins"
      }
    },
    git-credentials = {
      tags = {
        "jenkins:credentials:type"     = "sshUserPrivateKey"
        "jenkins:credentials:username" = "git"
      }
    }
  }, local.default_controller_secrets)
  tags               = local.tags

}

module "cloudbees_nonfr_namespace_controllers" {
  providers        = {
    kubernetes     = kubernetes
  }
  source           = "../../modules/cloudbees_namespace_controllers"
  env              = var.environment
  namespace        = "cloudbees-${var.environment}-controllers"
  certs_dir        = "${path.root}/certs/${var.environment}"
  tags             = local.tags
}

module "cloudbees_nonfr_namespace" {
  providers        = {
    kubernetes     = kubernetes
  }
  source           = "../../modules/cloudbees_namespace_controllers"
  env              = var.environment
  namespace        = "cloudbees-${var.environment}"
  certs_dir        = "${path.root}/certs/${var.environment}"
  tags             = local.tags
}

module "service_account_policies" {
  for_each = module.cloudbees_controllers
  source   = "../../modules/cloudbees_policy_attachment"
  roles    = each.value.service_account_roles
  policies = [
    module.cloudbees_policies.backup_arn,
    module.cloudbees_policies.secrets_arn,
    module.cloudbees_policies.ec2_builders_arn
  ]
}

module "cloudbees_controllers" {
  providers                   = {
    aws                       = aws
    aws.secrets               = aws.secrets
    aws.secrets-update        = aws.secrets-update
    kubernetes                = kubernetes
#    kubernetes.nonfr          = kubernetes.nonfr
  }
  source                      = "../../modules/cloudbees_controllers"
  env                         = var.environment
  cluster_name                = var.cluster_name
  aws_account_id              = var.aws_account_id
  secrets_account_id          = var.secrets_account_id
  certs_dir                   = "${path.root}/certs/${var.environment}"
  policies                    = []
  controllers                 = var.controllers
  kms_roles                   = [
    "arn:aws:iam::${var.secrets_account_id}:role/${var.aws_secrets_profile}",
    "arn:aws:iam::${var.secrets_account_id}:role/${var.aws_secrets_profile}-secrets"
  ]
  service_roles               = ["arn:aws:iam::${var.aws_account_id}:role/${var.aws_role}"]
  oc_roles                    = concat(
    flatten([for k,v in module.cloudbees_oc: [for arn in v.service_account_roles: arn]]),
    [for k,v in module.cloudbees_oc: v.secret_role])
  domain                      = var.domain
  backup_bucket_name          = var.backup_bucket_name
  artifacts_bucket_name       = var.artifacts_bucket_name
  instance_profiles           = var.instance_profiles
  builder_profile_name        = var.builder_profile_name
  builder_subnet_id           = var.builder_subnet_id
  builder_security_group_name = var.builder_security_group_name
  jenkins_token_suffix        = var.jenkins_token_suffix
  config_kms_key_id           = var.config_kms_key_id

  tags                        = local.tags
}
