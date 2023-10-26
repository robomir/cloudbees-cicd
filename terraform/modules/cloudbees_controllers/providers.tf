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
#      configuration_aliases = [ kubernetes, kubernetes.nonfr ]
      configuration_aliases = [ kubernetes ]
    }
  }
}
