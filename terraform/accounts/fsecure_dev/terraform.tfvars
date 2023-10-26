aws_account_id        = "956018147332"
secrets_account_id    = "956018147332"
aws_profile           = "fsecure-shadow-stack-dev-admin-role"
aws_secrets_profile   = "fsecure-shadow-stack-pods-secrets-access"
aws_role              = "fsecure-shadow-stack-dev-admin-role"
cluster_name          = "fsecure-shadow-stack-tooling"
region                = "us-west-2"

artifacts_bucket_name = "fsecure-dev-cloudbees-artifacts" # used to store build artifacts 
backup_bucket_name    = "fsecure-dev-cloudbees-backup" #

builder_subnet_id     = "subnet-0f6fd8e3175311f8d" # must be ec2 network 

config_kms_key_id     = "ao8eft"

controllers           = {01="controller1", 02="controller2", 03="controller3"}

datadog_api_key       = "skdjhagLIUFGASO"

instance_profiles     = ["fsecure-shadow-stack-bulder_instance_profile"] #must exists in advance of the deployment
