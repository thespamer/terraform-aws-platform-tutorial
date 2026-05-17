.PHONY: fmt validate lint security init-dev plan-dev apply-dev init-prod plan-prod apply-prod clean

fmt:
	terraform fmt -recursive

validate:
	./scripts/validate-all.sh

lint:
	tflint --init
	tflint --recursive

security:
	checkov -d .
	trivy config --severity HIGH,CRITICAL .
	conftest test envs modules bootstrap -p policies/opa || true

init-dev:
	cd envs/dev && terraform init -backend-config=backend.hcl

plan-dev:
	cd envs/dev && terraform plan -var-file=terraform.tfvars

apply-dev:
	cd envs/dev && terraform apply -var-file=terraform.tfvars

init-prod:
	cd envs/prod && terraform init -backend-config=backend.hcl

plan-prod:
	cd envs/prod && terraform plan -var-file=terraform.tfvars

apply-prod:
	cd envs/prod && terraform apply -var-file=terraform.tfvars

clean:
	find . -type d -name ".terraform" -prune -exec rm -rf {} \;
	find . -type f -name ".terraform.lock.hcl" -delete
	find . -type f -name "*.tfplan" -delete
