locals {
  oc_casc_version        = "105"

  default_cluster_name   = "fsecure-shadow-stack-tooling"
  default_secret_account = "956018147332"


  default_namespace      = "cloudbees-${local.environment}"

  tags = {
    service = "cloudbees"
    product = "f-secure"
    created_by = "terraform"

    source = "https://github.com/lookout-life-org/cd-cloudbees-oc.git"


    environment = local.environment
  }

  default_global_secrets = {
    cloudbees-test-token = {
      tags = {
        "jenkins:credentials:type"     = "string"
      }
    }
    deployer_ssh = {
      tags = {
        "jenkins:credentials:type"     = "sshUserPrivateKey"
        "jenkins:credentials:username" = "deployer"
      }
    }
    gerrit-jenkins-client-key = {
      tags = {
        "jenkins:credentials:type"     = "sshUserPrivateKey"
        "jenkins:credentials:username" = ""
      }
    }
    gerrit-ed25519-creds = {
      tags       = {
        "jenkins:credentials:type"     = "sshUserPrivateKey"
        "jenkins:credentials:username" = "jenkins"
      }
    }
    source-jenkins = {
      tags = {
        "jenkins:credentials:type"     = "string"
      }
    }
    artifactdeployer = {
      tags = {
        "jenkins:credentials:type"     = "usernamePassword"
        "jenkins:credentials:username" = "artifactdeployer"
      }
    }
    artifactdeployer-apikey = {
      tags = {
        "jenkins:credentials:type"     = "string"
      }
    }
    artifactdeployer-prod-apikey = {
      tags = {
        "jenkins:credentials:type"     = "string"
      }
    }
    hasslebot_slack_token = {
      tags = {
        "jenkins:credentials:type"     = "string"
      }
    }
    self-service-gerrit-github-access-token = {
      tags = {
        "jenkins:credentials:type"     = "string"
      }
    }
    opsgenie_token = {
      tags = {
        "jenkins:credentials:type"     = "string"
      }
    }
    general-jira-token = {
      tags = {
        "jenkins:credentials:type"     = "usernamePassword"
        "jenkins:credentials:username" = ""
      }
    }
    jenkins_builder_key = {
      tags = {
        "jenkins:credentials:type"     = "sshUserPrivateKey"
        "jenkins:credentials:username" = "jenkins"
      }
    }
    fa-consumer-token = {
      tags = {
        "jenkins:credentials:type"     = "usernamePassword"
        "jenkins:credentials:username" = "fa-consumer_lookout"
      }
    }
    fa-consumer-credentials = {
      tags = {
        "jenkins:credentials:type"     = "sshUserPrivateKey"
        "jenkins:credentials:username" = "git"
      }
    }
    sendgrid = {
      tags = {
        "jenkins:credentials:type"     = "usernamePassword"
        "jenkins:credentials:username" = "apikey"
      }
    }

  }

  default_controller_secrets = {
    github_token = {
      tags = {
        "jenkins:credentials:type"     = "usernamePassword"
        "jenkins:credentials:username" = ""
      }
    },
    datadog-api-key = {
      tags = {
        "jenkins:credentials:type"     = "string"
      }
    }
  }

  default_csi_secrets = {
    github_app = {
      mountPath  = "/run/secrets/github_app"
      tags       = {
        "jenkins:credentials:type"      = "gitHubApp"
        "jenkins:credentials:appID"     = "123456"
      }
    },
    docker_builder_key = {
      mountPath  = "/run/secrets/docker-builder-key"
      tags       = {
        "jenkins:credentials:type"     = "sshUserPrivateKey"
        "jenkins:credentials:username" = "jenkins"
      }
    },
    whitesource-api-key = {
      mountPath  = "/run/secrets/whitesource-api-key"
      tags       = {
        "jenkins:credentials:type" = "string"
      }
    },
    whitesource_user_token = {
      mountPath  = "/run/secrets/whitesource_user_token"
      tags       = {
        "jenkins:credentials:type" = "string"
      }
    },
    slack-bot-token = {
      mountPath  = "/run/secrets/slack-bot-token"
      tags       = {
        "jenkins:credentials:type" = "string"
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
}
