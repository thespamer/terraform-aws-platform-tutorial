# Arquitetura do Tutorial

Este repositório demonstra uma fundação Terraform mais madura para AWS.

## Camadas

```txt
Developer laptop / GitHub Actions
        |
        v
Terraform CLI
        |
        v
S3 Remote State + KMS + Lockfile
        |
        v
AWS resources por ambiente
```

## Separação de state

Cada ambiente tem seu próprio state:

```txt
envs/dev/terraform.tfstate
envs/prod/terraform.tfstate
```

Isso reduz blast radius e facilita permissões diferentes.

## Por que não usar um state único?

Um state único para tudo:

- aumenta risco de lock global
- aumenta blast radius
- dificulta ownership por time
- torna rollback e troubleshooting mais difíceis

## Padrão recomendado

```txt
state por ambiente
state por domínio/plataforma quando crescer
módulos reutilizáveis
pipeline com aprovação
OIDC no CI/CD
```
