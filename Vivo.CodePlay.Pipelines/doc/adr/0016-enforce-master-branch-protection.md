# 16. Service policy — proteção da branch padrão (master)

Date: 2026-06-24

## Status

Accepted

## Context

Garantir a qualidade e a segurança do código antes do merge na branch padrão do projeto, controlando as aprovações por um grupo centralizado.

- Grupo de aprovadores: `DevOpsCodePlayAdministrators`
- Aprovadores obrigatórios: 1 (uma aprovação deve ser de um membro do grupo)

Nota: aplica-se à branch padrão do repositório (ex.: `master`).

## Decision

Aplicar proteção à branch padrão do projeto com as regras abaixo:

1. Habilitar "Minimum number of reviewers" com `minimumApproverCount = 1`.
2. Exigir que pelo menos **1 aprovação** seja proveniente de um membro do grupo `DevOpsCodePlayAdministrators` para que o merge seja permitido.
3. Tornar a política bloqueante (impedir merges que não atendam aos requisitos).
4. Aplicar a política em nível de projeto (cross-repository) para o namespace da branch padrão.

## Consequences

### Positivas

- Melhora da qualidade do código por revisões obrigatórias.
- Centralização das aprovações no grupo `DevOpsCodePlayAdministrators` aumenta o controle e a responsabilidade.
- Redução do risco de regressões e mudanças não revisadas em produção.

### Desafios

- Necessidade de monitoramento para garantir a conformidade das aprovações.
- Possível impacto na velocidade de entrega se aprovadores não estiverem disponíveis.

## Localização

- Configuração aplicada via: Project settings → Repositories → Branch Policies → Protect important branch namespaces across all repositories in this project

Explicação: a opção "Protect important branch namespaces across all repositories in this project" aplica a política ao namespace da branch padrão de todos os repositórios do projeto (por exemplo, `refs/heads/master`). Essa aplicação é aditiva: ela adiciona ou estende as regras para o namespace da branch padrão, sem sobrescrever configurações de política já definidas em repositórios individuais.