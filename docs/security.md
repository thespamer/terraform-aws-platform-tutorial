# Segurança Terraform na AWS

## Princípios

1. Least privilege
2. Credenciais temporárias
3. State remoto criptografado
4. Versionamento do state
5. Locking do state
6. Separação de ambientes
7. Scans antes do apply
8. Revisão humana antes de produção

## State file

O state pode conter dados sensíveis. Proteja com:

- S3 bucket privado
- SSE-KMS
- bucket versioning
- bucket policy exigindo TLS
- IAM específico
- logs e monitoramento
- bloqueio de acesso público

## CI/CD

Use OIDC em vez de access keys estáticas.

## Policy-as-code

Use OPA/Conftest, Sentinel, Checkov custom policies ou controles equivalentes.
