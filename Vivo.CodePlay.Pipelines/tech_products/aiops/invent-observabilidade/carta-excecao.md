# Carta de Excecao - Pipeline Python Invent Observabilidade

## Contexto

Este pipeline foi criado para executar rotinas Python operacionais do dominio de observabilidade no Invent.

## Justificativa

Os templates padrao de build/deploy nao atendem de forma direta ao caso de uso de automacao batch de observabilidade, que requer apenas execucao controlada de script.

## Requisitos Especificos

- Execucao de script Python com virtualenv
- Instalacao dinamica de dependencias
- Uso de segredos via Variable Group
- Suporte a proxy corporativo
- Reuso via template com parametros

## Plano de Remediacao

Caso o framework disponibilize template oficial para jobs Python operacionais de observabilidade, este template pode ser migrado para o padrao oficial.

## Riscos

- Dependencia de agente Linux
- Dependencia de conectividade para pacote pip
- Dependencia de configuracao correta de proxy

## Conclusao

A implementacao atende ao escopo operacional atual e segue o modelo de reutilizacao via extends com parametros.
