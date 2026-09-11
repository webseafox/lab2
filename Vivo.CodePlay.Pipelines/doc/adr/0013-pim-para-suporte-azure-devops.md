# 13. PIM para Suporte do Azure DevOps

Date: 2026-06-05

## Status

Accepted

## Context

O time Dev Support é responsável pela linha de frente do suporte ao usuário da plataforma DevOps da Vivo (Azure DevOps) e muitas vezes precisam de acesso a múltiplos projetos e nível mais elevado do que um usuário comum.

Seguindo o conceito de mínimo privilégio possível o time Dev Support não deve fazer parte do grupo Project Collection Administrator do Azure DevOps.

## Decision

- Estipular nível de acesso **Maintainer+** (acima de Maintainer e abaixo de Project Collection Administrator) para atender atividades diárias do time Dev Support
- Implementar fluxo via PIM (Privileged Identity Management) para acesso ao grupo `[TEAM FOUNDATION]\BRTLV-DEVOPS-DEVSUPPORT` (Maintainer+)
- Time Dev Support terá por padrão acesso **Reader All Projects** ao Azure DevOps via grupo `BRTLV-DEVOPS-DEVSUPPORT-READER`

**Aprovadores PIM**: Liderança do time Dev Support  
**Duração máxima**: Conforme política de segurança da Vivo (8 horas)
**Documentação**: Ver [Acesso Maintainer+ Dev Support](https://wikicorp.telefonica.com.br/spaces/DCE/pages/796287472/Acesso+Maintainer+Dev+Support)

### Permissões por categoria

#### 1. Projeto

##### General

| Permissão | Configuração |
|---|---|
| Delete team project | ❌ Not Set |
| Edit project-level information | ✅ Allow |
| Manage project properties | ✅ Allow |
| Rename team project | ✅ Allow |
| Suppress notifications for work item updates | ✅ Allow |
| Update project visibility | ❌ Not Set |
| View project-level information | ✅ Allow |

##### Boards

| Permissão | Configuração |
|---|---|
| Bypass rules on work item updates | ✅ Allow |
| Change process of team project | ❌ Not Set |
| Create tag definition | ✅ Allow |
| Delete and restore work items | ✅ Allow |
| Move work items out of this project | ❌ Not Set |
| Permanently delete work items | ❌ Not Set |

##### Analytics

| Permissão | Configuração |
|---|---|
| Delete shared Analytics views | ✅ Allow |
| Edit shared Analytics views | ✅ Allow |
| View analytics | ✅ Allow |

#### Test Plans

| Permissão | Configuração |
|---|---|
| Create test runs | ❌ Not Set |
| Delete test runs | ❌ Not Set |
| Manage test configurations | ❌ Not Set |
| Manage test environments | ❌ Not Set |
| View test runs | ❌ Not Set |

##### Other

| Permissão | Configuração |
|---|---|
| Manage delivery plans | ❌ Not Set |

#### 2. Repositories (Repos)

> Permissões relacionadas ao gerenciamento e manutenção de repositórios de código-fonte.

| Permissão | Configuração |
|---|---|
| Advanced Security: manage and dismiss alerts | ❌ Not Set |
| Advanced Security: manage settings | ❌ Not Set |
| Advanced Security: view alerts | ✅ Allow |
| Bypass policies when completing pull requests | ❌ Not Set |
| Bypass policies when pushing | ❌ Not Set |
| Contribute | ✅ Allow |
| Contribute to pull requests | ✅ Allow |
| Create branch | ✅ Allow |
| Create repository | ❌ Not Set |
| Create tag | ✅ Allow |
| Delete or disable repository | ✅ Allow |
| Edit policies | ✅ Allow |
| Force push (rewrite history, delete branches and tags) | ✅ Allow |
| Manage notes | ✅ Allow |
| Manage permissions | ✅ Allow |
| Read | ✅ Allow |
| Remove others' locks | ✅ Allow |
| Rename repository | ✅ Allow |

#### 3. Pipelines / Build

> Permissões relacionadas à criação, execução e administração de pipelines de build.

| Permissão | Configuração |
|---|---|
| Administer build permissions | ✅ Allow |
| Create build pipeline | ✅ Allow |
| Delete build pipeline | ✅ Allow |
| Delete builds | ✅ Allow |
| Destroy builds | ✅ Allow |
| Edit build pipeline | ✅ Allow |
| Edit build quality | ✅ Allow |
| Edit queue build configuration | ✅ Allow |
| Manage build qualities | ✅ Allow |
| Manage build queue | ✅ Allow |
| Override check-in validation by build | ✅ Allow |
| Queue builds | ✅ Allow |
| Retain indefinitely | ✅ Allow |
| Stop builds | ✅ Allow |
| Update build information | ✅ Allow |
| View build pipeline | ✅ Allow |
| View builds | ✅ Allow |

#### 4. Library & Service Connections & Environments

| Recurso | Papel |
|---|---|
| Variable Groups | ✅ Administrator |
| Service Connections | ✅ Administrator |
| Environments | ✅ Administrator |

## Consequences

**Positivas:**
- Maior controle sobre acessos elevados de suporte sem conceder privilégios administrativos completos
- Rastreabilidade e auditoria de todas as atividades de suporte com privilégios elevados
- Acesso Reader permanente permite triagem inicial sem necessidade de elevação
- Conformidade com princípio de menor privilégio

**Negativas:**
- Pedidos de acesso elevado sujeitos à disponibilidade dos aprovadores
- Possível impacto no SLA de atendimento de RITMs e INCs durante processo de aprovação
- Necessidade de planejamento para atividades de suporte que exigem acesso elevado

**Mitigações:**
- Definir SLA de aprovação diferenciado por severidade (SEV1: imediato, SEV2: 1h, SEV3+: 4h)
- Manter múltiplos aprovadores disponíveis em horário comercial e pré-aprovar acessos para períodos de sobreavisos e release.
- Avaliar extensão de duração de acesso para casos de troubleshooting prolongado

## Related Decisions

- [ADR-0012](0012-pim-para-administracao-azure-devops.md) - PIM para Administração do Azure DevOps
