# 2. Decisões do Framework CodePlay

Date: 2025-11-18

## Status

Accepted

## Context

No CodePlay Framework Precisamos de um conjunto padrão de decisões arquiteturais para garantir a consistência e a qualidade das pipelines.

Espera-se que muitas decisões sejam feitas tanto no Framework quanto no próprio CodePlay.

Para não confundir as decisões específicas do CodePlay com as decisões do Framework, decidimos criar um conjunto separado de ADRs para o CodePlay Framework.

## Decision

Todas as decisões arquiteturais específicas do CodePlay Framework serão documentadas em ADRs separados, localizados na pasta `framework/docs/adr`.

## Consequences

Como o [adr-tools](https://github.com/npryce/adr-tools) não suporta múltiplas pastas de ADR, as ADRs do Framework precisarão ser gerenciada a partir da pasta `framework` ou manualmente.

```bash
cd framework
adr new "Título da Decisão"
adr list
cd ..
```

Isso pode introduzir alguma complexidade adicional no gerenciamento das ADRs, mas garante que as decisões do Framework sejam claramente separadas das decisões do CodePlay.