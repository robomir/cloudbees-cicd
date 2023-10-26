ENVIRONMENT?=dev
AWS_ACCOUNT_ID=956018147332
ifeq ($(ENVIRONMENT), staging)
export AWS_PROFILE?=my-priviled-aws-role-name
export SECRETS_AWS_PROFILE?=my-priviled-aws-secrets-account-role-name
else ifeq ($(ENVIRONMENT), dev)
export AWS_PROFILE?=fsecure-shadow-stack-tooling-admin
export SECRETS_AWS_PROFILE?=fsecure-shadow-stack-tooling-admin
endif
export TF_DATA_DIR?=$(shell pwd)/$(ENVIRONMENT)/.terraform
NAMESPACE?=cloudbees-$(ENVIRONMENT)

export TF_VAR_datadog_api_key?=$(shell cat ${HOME}/.datadog-token)

.PHONY: init plan apply refresh

#login:
#	oktatool --profile $(AWS_PROFILE)
#	oktatool --profile $(SECRETS_AWS_PROFILE)
#	oktatool --profile $(SECRETS_AWS_PROFILE)-secrets
#	oktatool --profile $(FR_SECRETS_AWS_PROFILE)
#	oktatool --profile $(FR_SECRETS_AWS_PROFILE)-secrets

init:
	terraform init -backend-config "key=lookout-cloudbees-$(AWS_ACCOUNT_ID)/us-west-2/$(ENVIRONMENT)/cloudbees.tfstate" 

plan:
	terraform plan -var-file $(ENVIRONMENT)/env.tfvars -out $(ENVIRONMENT)/terraform.plan $(TARGET)

refresh:
	terraform refresh -var-file $(ENVIRONMENT)/env.tfvars
apply:
	terraform apply $(ENVIRONMENT)/terraform.plan
import:
	terraform import -var-file $(ENVIRONMENT)/env.tfvars $(ADDR) $(ID)
state-mv:
	terraform state mv $(SRC) $(DEST)
state-rm:
	terraform state rm $(ADDR)
state-list:
	terraform state list
console:
	terraform console

create-ca-bundles-config:
	rm -f certs/$(ENVIRONMENT)/{cacerts,ca-certificates.crt}
	kubectl -n $(NAMESPACE) cp cjoc-0:etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem certs/$(ENVIRONMENT)/ca-certificates.crt
	kubectl -n $(NAMESPACE) cp cjoc-0:etc/pki/ca-trust/extracted/java/cacerts certs/$(ENVIRONMENT)/cacerts
	keytool -import -noprompt -keystore certs/$(ENVIRONMENT)/cacerts -file ../../../lookout-private-ca-root.pem -storepass changeit -alias lookout-ca;
	cat ../../../fsecure-private-ca-root.pem >> certs/$(ENVIRONMENT)/ca-certificates.crt
#	kubectl -n $(NAMESPACE) create configmap --from-file=ca-certificates.crt,cacerts ca-bundles
