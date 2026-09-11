---
title: Run Python Invent Observabilidade Job
description: Pipeline para execução de rotinas Python de observabilidade e integração de dados do Inventário de Observabilidade
icon: 🧪
section: automation
tags:
  - pipeline
  - python
  - observabilidade
  - invent
  - automation
  - batch
---

# Run Python Invent Observabilidade Job

## Descrição

Este template executa scripts Python para rotinas operacionais de observabilidade do Inventário de Observabilidade, com suporte a virtualenv, instalação de dependências e injeção de variáveis sensíveis via Variable Group.

Foi desenhado para automação operacional (batch/agendada), sem responsabilidades de build de artefato ou deploy de aplicação.

---

## Casos de uso

- Ingestão e sincronização de dados de observabilidade
- Processamento batch de eventos e incidentes
- Rotinas Python com credenciais corporativas
- Execução agendada via pipeline consumidora

---

## Não utilizar para

- Build de bibliotecas Python
- Build de imagem Docker
- Deploy em Kubernetes
- Versionamento de banco de dados

---

## Estrutura

A pipeline executa as etapas abaixo:

1. Checkout do código
2. Cache de dependências pip
3. Criação de virtualenv e bootstrap de pip
4. Instalação de pacotes Python parametrizados
5. Execução do script alvo com argumentos opcionais

---

## Parâmetros da Template

| Parâmetro | Tipo | Default | Descrição |
|---|---|---|---|
| `agentPool` | string | `SREConfiabilidadeAgents` | Pool de agentes para execução do job |
| `demands` | object | `{}` | Requisitos de capacidade do agente |
| `variableGroup` | string | `''` | Variable Group com segredos e configurações |
| `pythonCommand` | string | `python` | Comando Python disponível no agente |
| `venvDir` | string | `.venv` | Diretório do virtualenv |
| `jobDisplayName` | string | `Executar script Python (Invent)` | Nome exibido para o job |
| `scriptPath` | string | obrigatório | Caminho relativo do script Python a executar |
| `scriptArgs` | object | `{}` | Argumentos extras passados ao script (lista direta ou objeto com `items`) |
| `pipPackages` | object | `{ items: [sqlalchemy, psycopg2-binary, pandas, requests] }` | Pacotes pip a instalar (aceita lista direta ou objeto com `items`) |
| `proxyVarName` | string | `''` | Nome da variável de ambiente com URL de proxy |
| `envVars` | object | `{}` | Variáveis de ambiente repassadas ao script |
| `enableDebugListing` | boolean | `false` | Habilita listagem de workspace para debug |

---

## Variáveis de Ambiente de Configuração

| Variável | Descrição | Exemplo |
|---|---|---|
| `TRUSTED_PIP_HOSTS` | Hosts confiáveis para instalação pip | `pypi.org files.pythonhosted.org` |
| `HTTP_PROXY` | Proxy HTTP corporativo | `http://proxy.corp:8080` |
| `HTTPS_PROXY` | Proxy HTTPS corporativo | `http://proxy.corp:8080` |

### Nota de Segurança

O uso de `TRUSTED_PIP_HOSTS` e proxies deve ser restrito a ambientes e variable groups aprovados.
Evite incluir hosts não confiáveis e prefira repositório de pacotes corporativo quando disponível.

---

## Dependências Externas

- Agente Linux com bash
- Python disponível no agente
- Conectividade para repositórios pip
- Acesso a endpoints externos consumidos pelo script
- Variable Group autorizado para a pipeline consumidora

---

## Decisões de Design

- Template orientado a execução de job operacional
- Dependências em virtualenv para isolamento
- Proxy opcional por variável de ambiente
- Retry com backoff em instalação de pacotes
- Parametrização para reuso em múltiplos scripts

---

## Exemplo de consumo

```yaml
resources:
  repositories:
    - repository: CodePlayTemplates
      type: git
      name: DevOps/Vivo.CodePlay.Pipelines
      ref: refs/heads/feature/aiops/migra-pipeline-vnow-ingestion

extends:
  template: /tech_products/aiops/invent-observabilidade/python-invent-job.yml@CodePlayTemplates
  parameters:
    variableGroup: vg-invent-observabilidade
    scriptPath: scripts/invent/sync-observabilidade.py
    scriptArgs:
      items:
        - --mode
        - full
        - --window-hours
        - '24'
    pipPackages:
      - requests
      - pandas
      - psycopg2-binary
    envVars:
      DB_USER: $(db_user)
      DB_PASSWORD: $(db_password)
      SERVICENOW_AUTH: $(auth_now)
      HTTP_PROXY: $(http_proxy)
      HTTPS_PROXY: $(https_proxy)
```
