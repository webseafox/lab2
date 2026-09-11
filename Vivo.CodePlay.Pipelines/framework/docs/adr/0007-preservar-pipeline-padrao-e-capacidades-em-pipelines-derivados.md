# 7. Preservar pipeline padrão e habilitar capacidades via pipelines derivados

Date: 2026-04-27

## Status

Accepted

## Context

O CodePlay Framework adota o princípio de Plug and Play, onde o pipeline padrão deve atender à maioria dos cenários com o menor número possível de parâmetros e com resolução por convenção.

Na evolução do framework, novas capacidades não padrão podem exigir lógicas, parâmetros ou etapas adicionais. Quando essas mudanças são aplicadas no pipeline, há risco de:

- Quebrar compatibilidade com consumidores que não precisam ou não querem usar as novas capacidades.
- Aumentar complexidade para todos os consumidores.
- Introduzir regressão em cenários que hoje funcionam sem configuração adicional.
- Quebrar a promessa de simplicidade do modo padrão.

Também é necessário garantir que, ao habilitar capacidades novas, o comportamento do fluxo padrão continue preservado.

## Decision

Decidimos estabelecer as seguintes regras para evolução de capacidades nos pipelines do framework:

1. O pipeline padrão deve permanecer estável e conter o mínimo de parâmetros possível.
2. O pipeline padrão deve priorizar convenções e defaults inteligentes, evitando configurações obrigatórias desnecessárias.
3. Capacidades não padrão não devem ser introduzidas alterando o comportamento base do pipeline padrão.
4. Quando uma capacidade não padrão for necessária, deve ser criado um pipeline derivado específico para essa capacidade.
5. Toda entrega que habilite nova capacidade deve executar e validar o pipeline padrão e da capacidade alterada/adicionada para comprovar que não houve impacto.

### Convenção de nomenclatura para derivados

Como referência, manter o pipeline base e criar variante para capacidade:

- testes-codeplay-framework/build-java-docker
- testes-codeplay-framework/build-java-docker-capacidade-x

A mesma abordagem deve ser aplicada aos demais tipos de pipeline (CI/CD) quando houver capacidades opcionais que aumentem complexidade do fluxo base.

## Consequences

### Consequências positivas

- Preserva simplicidade e previsibilidade do pipeline padrão.
- Reduz risco de regressão para consumidores que usam apenas o fluxo convencional.
- Melhora governança da evolução de capacidades, com isolamento por pipeline derivado.
- Facilita manutenção e troubleshooting ao separar claramente fluxo base de variações avançadas.

### Consequências negativas / trade-offs

- Pode aumentar a quantidade de pipelines mantidos no framework.
- Exige disciplina de validação para sempre executar o pipeline padrão em mudanças de capacidade.
- Requer documentação clara sobre quando usar o pipeline base versus um derivado.

### Implicações práticas

- PRs que adicionarem novas capacidades ou atualizarem capacidades existentes devem anexar evidências de execução tanto do pipeline padrão quanto da capacidade nova ou atualizada.
- Novos pipelines derivados devem manter consistência de nomenclatura, parâmetros e documentação com o pipeline base.
- O pipeline padrão não deve receber parâmetros que existam apenas para capacidades opcionais de baixo uso.
