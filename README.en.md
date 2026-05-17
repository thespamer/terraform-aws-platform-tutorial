# Terraform AWS Platform Tutorial

A practical and architectural tutorial to learn Terraform on AWS with a focus on:

- Platform and architecture, not only basic commands
- Professional repository structure
- Protected remote state in S3
- Versioned state
- State locking with `use_lockfile`
- Backend security
- Multi-environment structure: `dev` and `prod`
- Reusable modules
- GitHub Actions with OIDC for AWS, without static access keys
- Quality validations
- Security scans with Checkov and Trivy
- Policy-as-code with OPA/Conftest
- Best practices for tagging, naming, least privilege, and separation of responsibilities

> This repository is a lab. Review names, regions, permissions, and costs before applying it to a real AWS account.

---

## 1. Architectural overview

This tutorial follows the idea of a more mature Terraform platform foundation:

```txt
terraform-aws-platform-tutorial/
├── bootstrap/
│   └── state-backend/          # creates S3 bucket, KMS key, and IAM for remote state
├── envs/
│   ├── dev/                    # development stack
│   └── prod/                   # production stack
├── modules/
│   ├── network/                # VPC, subnets, route tables
│   ├── secure-s3-bucket/       # reusable secure bucket
│   ├── iam-github-oidc/        # GitHub Actions OIDC -> AWS
│   └── observability/          # CloudWatch logs and simple alarms/log resources
├── policies/
│   └── opa/                    # OPA/Conftest policies
├── scripts/                    # local automation
├── docs/                       # architectural explanations
└── .github/workflows/          # Terraform CI/CD
```

The conceptual separation is:

```txt
bootstrap = resources required for Terraform to operate securely
envs      = deployable stacks by environment
modules   = reusable building blocks
policies  = governance
ci        = validation, plan, and controlled apply
```

---

## 2. Why remote backend is critical

The `terraform.tfstate` file can contain sensitive information and is the source of truth between Terraform code and the real infrastructure.

In a professional environment, avoid:

```txt
local terraform.tfstate
terraform.tfstate committed to Git
state shared by email or local folders
static credentials in the repository
```

Use:

```txt
S3 with versioning
SSE-KMS
S3 Public Access Block
IAM least privilege
state locking
CI/CD access through OIDC
```

The Terraform S3 backend stores state in an S3 object and supports state locking with `use_lockfile = true`. HashiCorp also recommends enabling versioning on the bucket to allow recovery from human error or accidental deletion.

---

## 3. Prerequisites

Locally:

```bash
terraform version
aws --version
git --version
```

Optional tools for quality and security:

```bash
tflint --version
checkov --version
trivy --version
conftest --version
```

With Homebrew/Linuxbrew:

```bash
brew install terraform tflint checkov trivy conftest awscli
```

With `apt` or `pip`, adapt the commands according to your distribution.

---

## 4. Correct usage flow

### Phase 1 — Bootstrap the remote backend

The first stack creates the resources used by Terraform itself:

```txt
S3 bucket for state
KMS key for encryption
Bucket versioning
Bucket public access block
Bucket policy enforcing TLS
IAM role for GitHub Actions through OIDC
```

Go to the folder:

```bash
cd bootstrap/state-backend
```

Copy the variable file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit it:

```bash
nano terraform.tfvars
```

Initialize locally:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

> The bootstrap starts with local state because it creates the remote backend. After it is created, the `dev` and `prod` environments use S3 as backend.

---

### Phase 2 — Configure the environment backends

Edit the files:

```txt
envs/dev/backend.hcl
envs/prod/backend.hcl
```

Example:

```hcl
bucket       = "your-tfstate-bucket"
key          = "envs/dev/terraform.tfstate"
region       = "us-east-1"
encrypt      = true
use_lockfile = true
```

Initialize the dev environment:

```bash
cd envs/dev
terraform init -backend-config=backend.hcl
terraform plan -var-file=terraform.tfvars
```

Apply:

```bash
terraform apply -var-file=terraform.tfvars
```

---

## 5. Useful commands

From the repository root:

```bash
make fmt
make validate
make lint
make security
```

Development environment:

```bash
make init-dev
make plan-dev
make apply-dev
```

Production environment:

```bash
make init-prod
make plan-prod
make apply-prod
```

---

## 6. Branch and environment model

Suggested model:

```txt
feature/*       -> validation and plan
main            -> dev plan
release/*       -> prod plan
tag/version     -> prod apply with approval
```

For this tutorial:

```txt
pull_request      -> fmt, validate, tflint, checkov, trivy, conftest, terraform plan
push main         -> validation and dev plan
workflow_dispatch -> manual apply
```

---

## 7. Secure AWS authentication

Avoid GitHub Secrets such as:

```txt
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

Prefer OIDC:

```txt
GitHub Actions -> OIDC token -> AWS STS -> temporary IAM Role
```

The workflow uses:

```yaml
permissions:
  id-token: write
  contents: read
```

and:

```yaml
aws-actions/configure-aws-credentials
```

with `role-to-assume`.

---

## 8. Security policy implemented

This repository demonstrates:

- State bucket with versioning
- SSE-KMS encryption
- S3 public access block
- Bucket policy requiring TLS
- Environment separation
- Required tags
- OIDC without static access keys
- `terraform fmt`
- `terraform validate`
- `tflint`
- `checkov`
- `trivy config`
- `conftest` with OPA
- `terraform plan` saved as an artifact
- Manual apply through `workflow_dispatch`

---

## 9. Module structure

Each module follows the pattern:

```txt
main.tf
variables.tf
outputs.tf
README.md
```

When useful, add:

```txt
versions.tf
examples/
tests/
```

---

## 10. Important note about secrets

Never put the following in `.tfvars` files:

```txt
passwords
tokens
access keys
private keys
sensitive connection strings
```

Use:

```txt
AWS Secrets Manager
SSM Parameter Store
variables injected through CI/CD
assume role
OIDC
```

Even when a variable is marked as `sensitive = true`, values may still appear in the state depending on the resource. The better pattern is to avoid managing plaintext secrets through Terraform whenever possible.

---

## 11. Deploy by environment

Dev:

```bash
cd envs/dev
terraform init -backend-config=backend.hcl
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Prod:

```bash
cd envs/prod
terraform init -backend-config=backend.hcl
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

---

## 12. Best practices used in this tutorial

### Remote state

```hcl
terraform {
  backend "s3" {
    bucket       = "..."
    key          = "envs/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

### Version pinning

```hcl
terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

### Required tags

```hcl
default_tags {
  tags = {
    ManagedBy = "Terraform"
    Platform  = "aws-platform-tutorial"
  }
}
```

### Separation of responsibilities

```txt
bootstrap/state-backend = backend and roles
envs/dev                = dev environment
envs/prod               = prod environment
modules/*               = reusable components
```

---

## 13. Recommended next steps

After this tutorial, evolve toward:

1. Terragrunt for multi-environment orchestration
2. HCP Terraform or Terraform Enterprise
3. AWS Organizations and multi-account landing zone
4. SCPs and permission boundaries
5. Argo CD / GitOps for Kubernetes workloads
6. OPA/Sentinel with corporate policies
7. Recurring drift detection
8. Cost estimation with Infracost
9. Pipeline with environment approvals
10. Modules published in a private registry
