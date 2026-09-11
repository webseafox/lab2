# 15. Service Connections Específicas para Role Assignment e APIM

Date: 2026-06-05

## Status

Accepted

## Context

Anteriormente, as Service Connections/Managed Identities utilizadas para provisionamento de recursos Azure via Terraform também eram responsáveis por:
- Tarefas de role assignment (com privilégios de Owner em subscription)
- Manipulação do Azure API Management (APIM)

Esta configuração não seguia o **princípio do menor privilégio**, gerando riscos de segurança ao concentrar múltiplas responsabilidades críticas em credenciais com permissões elevadas.

As Service Connections originais eram:
- `mi-terraform-dev` / `sp-terraform-dev`
- `mi-terraform-test` / `sp-terraform-test`
- `mi-terraform-prod` / `sp-terraform-prod`

## Decision

Separar as responsabilidades em Service Connections/Managed Identities específicas, seguindo o princípio do menor privilégio e boas práticas de segurança:

### 1. Provisionamento de Recursos (IaC com Terraform)
Mantidas para provisionamento de recursos Azure, **exceto** role assignment e APIM:
- `mi-terraform-dev` / `sp-terraform-dev`
- `mi-terraform-test` / `sp-terraform-test`
- `mi-terraform-prod` / `sp-terraform-prod`

### 2. Role Assignment (Foundation)
Criadas Managed Identities específicas para role assignment com processo automatizado e aprovação via PIM (Privileged Identity Management) para elevação temporária:
- `mi-terraform-foundation-dev`
- `mi-terraform-foundation-test`
- `mi-terraform-foundation-prod`

### 3. Azure API Management (APIM)
Criadas Managed Identities específicas para manipulação do APIM:
- `id-apim-brsouth-001-dev`
- `id-apim-brsouth-001-test`
- `id-apim-brsouth-001-prod`

### Localização
Todas as Service Connections estão disponíveis no projeto **"IAC - FOUNDATION"** do Azure DevOps.

## Consequences

### Positivas
- ✅ **Segurança aprimorada**: Redução de privilégios excessivos e superfície de ataque
- ✅ **Princípio do menor privilégio**: Cada credencial possui apenas as permissões necessárias
- ✅ **Auditoria melhorada**: Rastreamento específico de operações por tipo (provisionamento, role assignment, APIM)
- ✅ **Controle de acesso**: Aprovação via PIM para operações sensíveis de role assignment
- ✅ **Conformidade**: Atendimento a requisitos de segurança e compliance

### Desafios
- ⚠️ **Atualização de pipelines**: Pipelines existentes precisam ser atualizados para usar as Service Connections adequadas
- ⚠️ **Processo de aprovação**: Role assignments requerem processo de aprovação via PIM
- ⚠️ **Documentação**: Necessidade de documentar e comunicar as mudanças para os times
- ⚠️ **Gerenciamento de credenciais**: Mais Service Connections para gerenciar e monitorar
