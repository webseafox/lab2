# 1. Record architecture decisions

Date: 2025-11-18

## Status

Accepted

## Context

Precisamos registrar as decisões arquiteturais tomadas no DevOps Corporativo.

## Decision

Usaremos Registros de Decisões Arquiteturais, conforme [descrito por Michael Nygard](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions).

As Decisões serão mantidas no repositório git do [CodePlay](https://dev.azure.com/telefonica-vivo-brasil/DevOps/_git/Vivo.CodePlay.Pipelines), por alguns motivos:

- Decisões mantidas junto com o código dos pipelines.
- Facilita a colaboração entre os membros da equipe.
- Facilita a consulta das decisões durante o desenvolvimento.
- Facilita o rastreamento de mudanças ao longo do tempo.
- Permite que as decisões sejam revisadas e discutidas por meio de pull requests.
- Possibilidade de utilização do **Revisor de Código** para garantir a qualidade das decisões.
- Utilização do **GitHub Copilot** para auxiliar na geração e manutenção das ADRs.


## Consequences

Veja o artigo de Michael Nygard, vinculado acima. Para um conjunto de ferramentas ADR leve, veja [adr-tools](https://github.com/npryce/adr-tools) de Nat Pryce.
