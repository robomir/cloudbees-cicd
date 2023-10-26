environment            = "dev"
cluster_name           = "fsecure-shadow-stack-tooling"
backup_bucket_name     = "fsecure-dev-cloudbees-backup"
artifacts_bucket_name  = "fsecure-dev-cloudbees-artifacts"
domain                 = "cloudbees.dev.fsecure.com"
secrets_account_id     = "956018147332"
config_kms_key_id      = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
instance_profiles     = [
  "arn:aws:iam::XXXXXXXXXXXX:role/ci-builder",
  "arn:aws:iam::XXXXXXXXXXXX:role/jenkins-declarative-pipelines-builder",
  "arn:aws:iam::*:role/cloudbees-builder-*"
]
name = "controller-name"
builder_subnet_id           = "subnet-0f6fd8e3175311f8d"
builder_profile_name        = "ci-builder"
builder_security_group_name = "jenkins-builder"

owner = "956018147332"
owners = ["956018147332"]

controllers           = {
  "cd" = {
    "config"             = {
      "cluster_name"       = "fsecure-shadow-stack-tooling",
      "clusterEndpointId"  = "default"             # cluster endpoint refers to the ID for the kubernetes endpoint configuration defined in the OC casc jenkins.yaml#masterprovisioning.kubernetes.clusterEndpoints
    }
    "cluster_name"       = "fsecure-shadow-stack-tooling",
    "secrets_account_id" = "956018147332",
    "controller_secrets" = {}                      # create controller-specific secrets 
    "secrets"            = {}                      # secret resources are created with access policies but the values are typicall not managed in TF. !! be careful to ensure TF doesn't try to destroy secrets you might need to keep
    "systemProperties"   = {}
  }
  "common" = {
    "config"             = {
      "cluster_name"       = "fsecure-shadow-stack-tooling",
      "clusterEndpointId"  = "default"
    }
    "cluster_name"       = "fsecure-shadow-stack-tooling",
    "secrets_account_id" = "956018147332",
    "controller_secrets" = {}
    "secrets"            = {}
    "systemProperties"   = {}
  }
  "csrv" = {
    "config"             = {
      "cluster_name"       = "fsecure-shadow-stack-tooling",
      "clusterEndpointId"  = "default"
#      "team_secret_role"   = "consumer-team-secrets-role"
      "use_global_secrets" = false
    }
    "cluster_name"       = "fsecure-shadow-stack-tooling",
    "secrets_account_id" = "956018147332",
    "controller_secrets" = {
      fa-consumer-token = {
        tags = {
          "jenkins:credentials:type"     = "usernamePassword"
          "jenkins:credentials:username" = "fa-consumer_lookout"
        }
      },
      fa-consumer-credentials = {
        tags = {
          "jenkins:credentials:type"     = "sshUserPrivateKey"
          "jenkins:credentials:username" = "git"
        }
      },
      github-token = {
        tags = {
          "jenkins:credentials:type"     = "usernamePassword"
          "jenkins:credentials:username" = "fa-consumer_lookout"
        }
      },
      datadog-api-key = {
        tags = {
          "jenkins:credentials:type"     = "string"
        }
      }
    },
    "secrets"            = {
      docker_builder_key = {
        tags = {
          "jenkins:credentials:type"     = "sshUserPrivateKey"
          "jenkins:credentials:username" = "jenkins"
        }
      },
      whitesource-api-key = {
        tags = {
          "jenkins:credentials:type" = "string"
        }
      },
      whitesource_user_token = {
        tags = {
          "jenkins:credentials:type" = "string"
        }
      },
      git-credentials = {
        tags = {
          "jenkins:credentials:type"     = "sshUserPrivateKey"
          "jenkins:credentials:username" = "git"
        }
      }
    }
    "systemProperties"   = {}
  }

  "test" = {
    "config"             = {
      "cluster_name"       = "fsecure-shadow-stack-tooling",
      "clusterEndpointId"  = "default"
      "disk"               = 100
    }
    "cluster_name"       = "fsecure-shadow-stack-tooling",
    "secrets_account_id" = "956018147332",
    "controller_secrets" = {},
    "secrets"            = {}
    "systemProperties"   = {}
  }
}
