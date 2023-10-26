terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.5.0"
    }
    datadog = {
      source = "DataDog/datadog"
    }
  }
  required_version = "~> 1.0.11"

  backend "s3" {
    bucket  = "shadow-stack-terraform"
    region  = "us-west-2"
    encrypt = true
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/${var.aws_profile}"
  }
}

provider "aws" {
  alias   = "secrets"
  region  = var.region
  profile = var.aws_secrets_profile
  assume_role {
    role_arn = "arn:aws:iam::${var.secrets_account_id}:role/${var.aws_secrets_profile}"
  }
}

provider "aws" {
  alias   = "secrets-update"
  region  = var.region
  profile = "${var.aws_secrets_profile}-secrets"
  assume_role {
    role_arn = "arn:aws:iam::${var.secrets_account_id}:role/${var.aws_secrets_profile}-secrets"
  }
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }
  config_path    = "~/.kube/config"
  config_context = "arn:aws:eks:us-west-2:${var.aws_account_id}:cluster/${var.cluster_name}"
}

provider "datadog" {
  api_key = var.datadog_api_key
}
