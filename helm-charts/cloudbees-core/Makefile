ENVIRONMENT?=dev
NAMESPACE:=cloudbees-$(ENVIRONMENT)
AWS_PROFILE?=
VOLUMEID?=$(shell kubectl -n $(NAMESPACE) get pv -o 'jsonpath={.spec.csi.volumeHandle}' $(shell kubectl -n $(NAMESPACE) get pvc -o jsonpath='{.spec.volumeName}' jenkins-home-$(CONTROLLER)-0))

helm-template:
	mv cloudbees-$(ENVIRONMENT).yaml cloudbees-$(ENVIRONMENT).yaml.$(shell date +%Y%m%d-%H%S) || true
	helm template .  --name-template lookout -n $(NAMESPACE) -f values.$(ENVIRONMENT).yaml --api-versions networking.k8s.io/v1/Ingress > cloudbees-$(ENVIRONMENT).yaml
deploy: helm-template
	kubectl -n $(NAMESPACE) apply -f cloudbees-$(ENVIRONMENT).yaml
volume-id:
	@echo $(CONTROLLER): $(VOLUMEID)
create-snapshot:
	aws --profile=$(AWS_PROFILE) ec2 create-snapshot --description "cloudbees $(ENVIRONMENT) $(CONTROLLER) $(shell date +%Y%m%d)" --volume-id $(VOLUMEID) --tag-specifications 'ResourceType=snapshot,Tags=[{Key=purpose,Value=$(ENVIRONMENT)},{Key=product,Value=cd},{Key=service,Value=cloudbees},{Key=environment,Value=$(ENVIRONMENT)},{Key=controller,Value=$(CONTROLLER)}]' 
