# Operação

## Fluxo padrão

```bash
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

## Recuperação de state

Como o bucket de state tem versionamento, é possível recuperar versões anteriores do objeto.

Procedimento de emergência:

1. Pausar pipelines
2. Identificar versão boa do objeto no S3
3. Validar impacto
4. Restaurar versão do state
5. Rodar `terraform plan`
6. Reconciliar recursos se necessário

## Drift

Rode `terraform plan` periodicamente para detectar drift.

## Rollback

Terraform não tem rollback automático universal. O padrão é:

- versionar código
- versionar state
- aplicar mudança corretiva
- evitar apply manual fora do pipeline
