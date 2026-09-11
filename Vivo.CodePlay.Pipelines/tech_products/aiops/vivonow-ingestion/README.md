---
title: Run Python Ingestion Job
description: Pipeline para execução de rotinas Python agendadas de ingestão de dados (VivoNow / ServiceNow / Banco de Dados)
icon: 🐍
section: automation
tags:
  - pipeline
  - python
  - ingestion
  - automation
  - vivonow
  - servicenow
  - batch
---

# 🐍 Run Python Ingestion Job

## 🎯 Descrição

Este pipeline é responsável pela execução de **rotinas Python agendadas** voltadas para **ingestão de dados**, integração com banco de dados e consumo de APIs externas como **VivoNow / ServiceNow**.

Ele foi desenvolvido para cenários de **automação operacional**, onde não há necessidade de build de artefatos, deploy ou empacotamento, mas sim da execução segura e controlada de scripts Python.

---

## 🚀 Casos de uso

Este pipeline deve ser utilizado para:

- ✅ Ingestão de eventos (ex: VivoNow → banco)
- ✅ Sincronização de dados (ServiceNow ↔ DB)
- ✅ Processamento batch diário/agendado
- ✅ Automações operacionais de sustentação
- ✅ Scripts Python com uso de secrets corporativos

---

## ❌ Não utilizar para

Este pipeline **não deve ser usado** para:

- ❌ Construção de bibliotecas Python → use `Build Python Lib`
- ❌ Criação de imagens Docker → use `Build Python Docker`
- ❌ Deploy em Kubernetes
- ❌ Data Factory pipelines
- ❌ Versionamento de banco (Liquibase)

---

## 🏗️ Estrutura

A pipeline executa as seguintes etapas:

1. **Checkout do código**
2. **Preparação do ambiente Python**
   - Criação de `virtualenv`
   - Upgrade de `pip`, `setuptools` e `wheel`
3. **Instalação de dependências**
   - Via lista de pacotes (`pip`)
   - Suporte a proxy corporativo
4. **Execução do script Python**
   - Com variáveis de ambiente seguras
5. **Agendamento externo (opcional)**
  - Definido no pipeline consumidor (Schedule do Azure DevOps)

---

## ⚙️ Parâmetros da Template

| Parâmetro | Tipo | Default | Descrição |
|----------|------|---------|----------|
| `scriptPath` | string | *(obrigatório)* | Caminho do script Python a ser executado |
| `variableGroup` | string | `''` | Variable group com secrets (opcional, recomendado para credenciais) |
| `pipPackages` | object | `{}` | Lista de dependências Python (aceita lista direta ou objeto com `items`) |
| `pythonCommand` | string | `python` | Comando Python (`python` ou `python3`) |
| `venvDir` | string | `.venv` | Diretório onde criar o virtualenv |
| `proxyVarName` | string | `''` | Nome da variável de ambiente com URL do proxy |
| `envVars` | object | `{}` | Variáveis de ambiente do script |
| `enableDebugListing` | boolean | `false` | Habilita listagem de workspace para debug |
| `agentPool` | string | `SREConfiabilidadeAgents` | Pool de execução |
| `demands` | object | `{}` | Requisitos de capacidade do agente |

---

## 🔧 Variáveis de Ambiente de Configuração

Essas variáveis **podem ser definidas na Variable Group** para ajustar o comportamento da pipeline:

| Variável | Descrição | Exemplo |
|----------|----------|---------|
| `TRUSTED_PIP_HOSTS` | Hosts trusted para pip install | `pypi.org files.pythonhosted.org` |
| `HTTP_PROXY` | Proxy para requisições HTTP | `http://proxy.corp:8080` |
| `HTTPS_PROXY` | Proxy para requisições HTTPS | `http://proxy.corp:8080` |

### Nota de Segurança

O uso de `TRUSTED_PIP_HOSTS` e proxies deve ser restrito a variable groups aprovados.
Evite hosts não confiáveis e prefira mirror/repositório de pacotes corporativo quando disponível.

---

## 🔗 Dependências Externas

Para o pipeline funcionar corretamente, os seguintes requisitos externos devem estar disponíveis:

- **Agente Linux** com suporte a execução de shell script
- **Runtime Python** disponível no agente (compatível com o comando configurado em `pythonCommand`)
- **Acesso de rede** para instalação de pacotes via `pip` (com ou sem proxy corporativo)
- **Repositório de pacotes Python** (`pypi.org` e mirrors/trusted hosts configurados)
- **Credenciais e secrets** no Variable Group para banco de dados e APIs externas
- **Endpoints externos** acessíveis, quando aplicável (ex: VivoNow, ServiceNow, banco de dados)

---

## 🧩 Decisões de Design

- **Template focado em execução de job**: não implementa CI/CD completo por ser voltado a ingestão operacional.
- **Isolamento de dependências com virtualenv**: evita conflitos entre bibliotecas no agente.
- **Parametrização por template**: permite reutilização em diferentes scripts e cenários de ingestão.
- **Secrets fora do código**: credenciais são injetadas via Variable Group e `envVars`.
- **Suporte a proxy corporativo**: proxy é opcional e controlado por parâmetro/variáveis de ambiente.
- **Instalação resiliente de pacotes**: retry com backoff progressivo para reduzir falhas transitórias.

---

## ⏱️ Trigger e Agendamento

Este template **não define trigger** por design, para evitar execuções acidentais em pipelines consumidoras.

Recomendação para pipeline consumidora:

- Definir `trigger: none` e `pr: none` quando o uso for apenas operacional/agendado.
- Configurar `schedules` no pipeline consumidor conforme janela de execução necessária.

---

## 🧪 Exemplo — Pipeline de Eventos

```yaml
extends:
  template: tech_products/aiops/vivonow-ingestion/pipeline.yaml@CodePlay
  parameters:
    variableGroup: 'events-secrets'
    scriptPath: 'Event/event-db.py'
    pythonCommand: 'python'

    proxyVarName: 'proxy_url'

    pipPackages:
      - psycopg2-binary

    envVars:
      DB_USER: $(user_db)
      DB_PASSWORD: $(password_db)
      SERVICENOW_COOKIE: $(cookie_now)
      SERVICENOW_AUTH: $(auth_now)
      proxy_url: $(proxy_url)
```

---

## 🧪 Exemplo — Com Proxy Corporativo

```yaml
extends:
  template: tech_products/aiops/vivonow-ingestion/pipeline.yaml@CodePlay
  parameters:
    variableGroup: 'ingestion-secrets'
    scriptPath: 'scripts/sync-data.py'
    pythonCommand: 'python3'
    
    # Definir variável de proxy que será lida pelo script
    proxyVarName: 'HTTP_PROXY'

    pipPackages:
      - requests
      - sqlalchemy
      - pandas

    envVars:
      DB_HOST: $(db_host)
      DB_PORT: $(db_port)
      DB_USER: $(db_user)
      DB_PASSWORD: $(db_password)
      HTTP_PROXY: $(corp_proxy)
      HTTPS_PROXY: $(corp_proxy)
```

A pipeline automaticamente:
- Lê `HTTP_PROXY` da variable group
- Passa para o pip install
- Passa para o script Python executar