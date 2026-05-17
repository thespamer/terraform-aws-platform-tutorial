# Module: network

Módulo simples de VPC com subnets públicas.

## Boas práticas demonstradas

- DNS habilitado
- Subnets com `map_public_ip_on_launch = false`
- Tags consistentes
- Saídas explícitas

Em produção, adicione private subnets, NAT Gateway, VPC endpoints, NACLs e flow logs.
