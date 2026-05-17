#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-}"

if [ -z "$ENVIRONMENT" ]; then
  echo "Uso: ./scripts/plan-env.sh <dev|prod>"
  exit 1
fi

cd "envs/${ENVIRONMENT}"

terraform init -backend-config=backend.hcl
terraform fmt -check -recursive
terraform validate
terraform plan -var-file=terraform.tfvars -out="${ENVIRONMENT}.tfplan"
terraform show -json "${ENVIRONMENT}.tfplan" > "${ENVIRONMENT}.plan.json"
