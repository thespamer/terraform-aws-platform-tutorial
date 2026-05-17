# Module: iam-github-oidc

Cria um OIDC provider para GitHub Actions e uma role assumível pelo repositório autorizado.

## Segurança

- Usa `AssumeRoleWithWebIdentity`
- Restringe por `aud = sts.amazonaws.com`
- Restringe por repo/branch/pull_request
- Evita access keys estáticas no GitHub Secrets

Em produção, refine permissões por stack e ambiente.
