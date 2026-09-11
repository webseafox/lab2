# Carta de Exceção — Pipeline Python Ingestion

## Contexto

Este pipeline foi criado para executar rotinas Python de ingestão de dados relacionadas ao VivoNow, incluindo:

- ingestão de eventos
- ingestão de incidentes
- integração com banco de dados e ServiceNow

## Justificativa

Os templates existentes do framework CodePlay não atendem a este cenário, pois:

- `Build Python Lib` é voltado para bibliotecas e empacotamento
- `Build Python Docker` exige containerização (não aplicável ao caso)
- não há template específico para execução de scripts Python agendados

Este pipeline é de natureza **operacional/batch**, não de build ou deploy.

## Requisitos Específicos

- execução via agendamento (cron)
- uso de virtualenv
- instalação dinâmica de dependências
- uso de secrets via variable group
- integração com proxies corporativos

## Plano de Remediação

Caso o framework passe a suportar pipelines para automações Python, este pipeline poderá ser migrado para um template oficial.

## Riscos

- dependência de execução via agente Linux
- dependência de proxy corporativo para instalação de pacotes
- possível variação de comportamento do ambiente Python

## Aprovação

Responsável técnico:  
Time AIOPS

## Conclusão

Esta implementação segue as melhores práticas possíveis dentro do escopo atual e atende à policy de proveniência via extends @CodePlay.