# Structure

The terraform projects are located in the terraform directory.

## terraform/accounts

The accounts directory contains a directory for each AWS deployment account that will be managed.  The `lookout_dev` directory
contains the configuration for the dev and staging Cloudbees environments which are deployed in the lookout_dev account.

Account values are specified in terraform.tfvars (example)

    aws_account_id        = "XXXXXXXXXX"
    secrets_account_id    = "XXXXXXXXXX"
    aws_profile           = "my-priviled-aws-role-name"
    aws_secrets_profile   = "my-priviled-aws-secrets-account-role-name"
    aws_role              = "my-priviled-aws-role-name"
    cluster_name          = "eks_default_cloudbees_cluster_name"
    region                = "us-west-2"

environment-specific configuration is stored in dev/env.tfvars, staging/env.tfvars, etc.

    environment            = "dev"
    cluster_name           = "eks_dev_env_cloudbees_cluster_name"
    backup_bucket_name     = "lookout-dev-cloudbees-backup"
    artifacts_bucket_name  = "lookout-dev-cloudbees-artifacts"
    domain                 = "cloudbees.dev.flexilis.com"
    secrets_account_id     = "XXXXXXXXXX"
    instance_profiles     = [
      "arn:aws:iam::XXXXXXXXXX:role/ci-builder",
      "arn:aws:iam::XXXXXXXXXX:role/additional-privileged-role-for-ec2-builders",
      "arn:aws:iam::*:role/cloudbees-builder-*"
    ]

    builder_subnet_id           = "subnet-XXXXXX"
    builder_profile_name        = "ci-builder"
    builder_security_group_name = "jenkins-builder"


# Dependencies

* tfenv
* terraform
* oktatool
* awscli

# Setup

The dev environment is assumed to be OSX.

## Terraform

Install the required terraform version by using the tfenv tool.

    brew install tfenv

    tfenv install 1.0.11

## AWS Profile

Ensure a working version of the AWS cli is installed, using brew or the pkg provided by AWS.

    brew install awscli

Install oktatool

This tool is used by Lookout to provide Okta authentication for AWS roles.  The only requirement is a working AWS profile.

### Configure the AWS profile

If you aren't using oktatool then you can configure the profile in ~/.aws/credentials and ~/.aws/config

~/.aws/config

    [profile my-priviled-aws-role-name]
    role_arn = arn:aws:iam::XXXXXXXXXX:role/my-priviled-aws-role-name
    source_profile = my-priviled-aws-role-name
    region = us-west-2

~/.aws/credentials

    [my-priviled-aws-role-name]
    aws_access_key_id = XXXXXXXXXX
    aws_secret_access_key = YYYYYYYYYYYYYYYYYYYY
    aws_session_token = ZZZZZZZZZZZZZZZZZZZZZZZ

# Running

Once you have working profile you can configure the terraform project to use the profile by configuring the account variables in terraform/accounts/.

## Generating a plan

    cd terraform/accounts/fsecure_dev
    make ENVIRONMENT=dev plan

## Applying a plan

    cd terraform/accounts/fsecure_dev
    make ENVIRONMENT=dev apply


