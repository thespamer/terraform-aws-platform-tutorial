#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Validating Terraform directories..."

for dir in \
  "$ROOT_DIR/bootstrap/state-backend" \
  "$ROOT_DIR/envs/dev" \
  "$ROOT_DIR/envs/prod"
do
  echo "==> $dir"
  cd "$dir"
  terraform init -backend=false
  terraform validate
done

echo "All validations completed."
