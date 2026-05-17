# Terraform AWS Platform Tutorial

Tutorial prático e arquitetural para aprender Terraform em AWS com foco em:

- Plataforma e arquitetura, não apenas comandos básicos
- Estrutura de repositório profissional
- Remote state protegido em S3
- State versionado
- Locking com `use_lockfile`
- Segurança de backend
- Multiambiente: `dev` e `prod`
- Módulos reutilizáveis
- GitHub Actions com OIDC para AWS, sem access keys estáticas
- Validações de qualidade
- Scans de segurança com Checkov e Trivy
- Policy-as-code com OPA/Conftest
- Boas práticas de tagging, naming, least privilege e separação de responsabilidades

> Este repositório é um laboratório. Revise nomes, regiões, permissões e custos antes de aplicar em uma conta real.

---

## 1. Visão arquitetural

Este tutorial segue a ideia de uma plataforma Terraform mais madura:

```txt
terraform-aws-platform-tutorial/
├── bootstrap/
│   └── state-backend/          # cria bucket S3, KMS e IAM para backend remoto
├── envs/
│   ├── dev/                    # stack de desenvolvimento
│   └── prod/                   # stack de produção
├── modules/
│   ├── network/                # VPC, subnets, route tables
│   ├── secure-s3-bucket/       # bucket seguro reutilizável
│   ├── iam-github-oidc/        # OIDC GitHub Actions -> AWS
│   └── observability/          # CloudWatch logs e alarmes simples
├── policies/
│   └── opa/                    # políticas OPA/Conftest
├── scripts/                    # automações locais
├── docs/                       # explicações arquiteturais
└── .github/workflows/          # CI/CD Terraform
```

A separação conceitual é:

```txt
bootstrap = recursos necessários para o Terraform funcionar com segurança
envs      = stacks implantáveis por ambiente
modules   = blocos reutilizáveis
policies  = governança
ci        = validação, plano e apply controlado
```

---

## 2. Por que o backend remoto é crítico

O arquivo `terraform.tfstate` pode conter informações sensíveis e é o ponto de verdade entre o código Terraform e a infraestrutura real.

Em ambiente profissional, evite:

```txt
terraform.tfstate local
terraform.tfstate commitado no Git
state compartilhado por e-mail ou pasta local
credenciais estáticas no repositório
```

Use:

```txt
S3 com versionamento
SSE-KMS
Public Access Block
IAM least privilege
state lock
acesso via OIDC no CI/CD
```

O backend S3 do Terraform armazena o state em um objeto S3 e suporta state locking com `use_lockfile = true`. A documentação da HashiCorp também recomenda habilitar versionamento no bucket para recuperação em caso de erro humano ou exclusão acidental.

---

## 3. Pré-requisitos

Localmente:

```bash
terraform version
aws --version
git --version
```

Opcional para qualidade e segurança:

```bash
tflint --version
checkov --version
trivy --version
conftest --version
```

Com Homebrew/Linuxbrew:

```bash
brew install terraform tflint checkov trivy conftest awscli
```

Com apt/pip, adapte conforme sua distro.

---

## 4. Fluxo correto de uso

### Fase 1 — Bootstrap do backend remoto

A primeira stack cria os recursos usados pelo próprio Terraform:

```txt
S3 bucket de state
KMS key para criptografia
Bucket versioning
Bucket public access block
Bucket policy com TLS obrigatório
IAM role para GitHub Actions via OIDC
```

Entre na pasta:

```bash
cd bootstrap/state-backend
```

Copie o arquivo de variáveis:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edite:

```bash
nano terraform.tfvars
```

Inicialize localmente:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

> O bootstrap começa com state local porque ele cria o backend remoto. Depois de criado, os ambientes `dev` e `prod` usam S3 como backend.

---

### Fase 2 — Configurar backend dos ambientes

Edite os arquivos:

```txt
envs/dev/backend.hcl
envs/prod/backend.hcl
```

Exemplo:

```hcl
bucket       = "seu-bucket-tfstate"
key          = "envs/dev/terraform.tfstate"
region       = "us-east-1"
encrypt      = true
use_lockfile = true
```

Inicialize o ambiente dev:

```bash
cd envs/dev
terraform init -backend-config=backend.hcl
terraform plan -var-file=terraform.tfvars
```

Aplicar:

```bash
terraform apply -var-file=terraform.tfvars
```

---

## 5. Comandos úteis

Na raiz:

```bash
make fmt
make validate
make lint
make security
```

Ambiente dev:

```bash
make init-dev
make plan-dev
make apply-dev
```

Ambiente prod:

```bash
make init-prod
make plan-prod
make apply-prod
```

---

## 6. Modelo de branch e ambientes

Sugestão:

```txt
feature/*       -> validação e plan
main            -> plan dev
release/*       -> plan prod
tag/version     -> apply prod com aprovação
```

Para este tutorial:

```txt
pull_request -> fmt, validate, tflint, checkov, trivy, conftest, terraform plan
push main    -> validação e plan de dev
workflow_dispatch -> apply manual
```

---

## 7. Autenticação segura com AWS

Evite GitHub Secrets com:

```txt
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

Prefira OIDC:

```txt
GitHub Actions -> OIDC token -> AWS STS -> IAM Role temporária
```

O workflow usa:

```yaml
permissions:
  id-token: write
  contents: read
```

e:

```yaml
aws-actions/configure-aws-credentials
```

com `role-to-assume`.

---

## 8. Política de segurança implementada

Este repositório demonstra:

- Bucket de state com versionamento
- Criptografia SSE-KMS
- Bloqueio público em S3
- Bucket policy exigindo TLS
- Separação de ambientes
- Tags obrigatórias
- OIDC sem access keys estáticas
- `terraform fmt`
- `terraform validate`
- `tflint`
- `checkov`
- `trivy config`
- `conftest` com OPA
- `terraform plan` salvo como artifact
- Apply manual via `workflow_dispatch`

---

## 9. Estrutura de módulos

Cada módulo segue o padrão:

```txt
main.tf
variables.tf
outputs.tf
README.md
```

Quando fizer sentido, adicione:

```txt
versions.tf
examples/
tests/
```

---

## 10. Importante sobre secrets

Nunca coloque em `.tfvars`:

```txt
senhas
tokens
access keys
chaves privadas
connection strings sensíveis
```

Use:

```txt
AWS Secrets Manager
SSM Parameter Store
variáveis injetadas via CI/CD
assume role
OIDC
```

Mesmo marcando uma variável como `sensitive = true`, valores podem aparecer no state dependendo do recurso. O melhor padrão é evitar gerenciar secrets em plaintext pelo Terraform quando possível.

---

## 11. Deploy por ambiente

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

## 12. Boas práticas usadas neste tutorial

### Estado remoto

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

### Tags obrigatórias

```hcl
default_tags {
  tags = {
    ManagedBy = "Terraform"
    Platform  = "aws-platform-tutorial"
  }
}
```

### Separação de responsabilidades

```txt
bootstrap/state-backend = backend e roles
envs/dev                = ambiente dev
envs/prod               = ambiente prod
modules/*               = componentes reutilizáveis
```

---

## 13. Trilha de evolução avançada

Depois deste tutorial, a evolução natural é transformar este laboratório em uma plataforma corporativa de IaC. O roadmap recomendado é:

1. **Terragrunt para orquestração multiambiente**  
   Usar Terragrunt para reduzir repetição entre ambientes, centralizar configuração de backend, padronizar providers e organizar dependências entre stacks.

2. **HCP Terraform ou Terraform Enterprise**  
   Evoluir de execução local/GitHub Actions para execução remota, gestão de workspaces, políticas, RBAC, run tasks, approvals e auditoria centralizada.

3. **AWS Organizations e landing zone multi-account**  
   Separar workloads por contas AWS, como `shared-services`, `network`, `security`, `dev`, `staging` e `prod`, reduzindo blast radius e melhorando governança.

4. **SCPs e permission boundaries**  
   Aplicar guardrails organizacionais com Service Control Policies e permission boundaries para impedir ações proibidas mesmo quando roles locais têm permissões amplas.

5. **Argo CD / GitOps para workloads em Kubernetes**  
   Usar Terraform para provisionar a infraestrutura base e GitOps para controlar o ciclo de vida de aplicações Kubernetes.

6. **OPA/Sentinel com políticas corporativas**  
   Substituir validações simples por políticas formais: tags obrigatórias, regiões permitidas, tipos de instância aprovados, criptografia obrigatória e bloqueio de recursos públicos.

7. **Drift detection recorrente**  
   Rodar `terraform plan` periodicamente para detectar mudanças feitas fora do Terraform e gerar alertas antes que o ambiente fique inconsistente.

8. **Cost estimation com Infracost**  
   Adicionar estimativa de custo no pull request para que mudanças de infraestrutura sejam avaliadas tecnicamente e financeiramente antes do merge.

9. **Pipeline com aprovações por ambiente**  
   Exigir aprovação manual para `prod`, com ambientes protegidos no GitHub, revisores obrigatórios e separação clara entre plan e apply.

10. **Módulos publicados em registry privado**  
    Evoluir os módulos locais para um registry privado, com versionamento semântico, changelog, documentação e contrato estável para múltiplos times.
