# 🚀 MLOps Databricks Batch CI/CD — CodePlay Compatible

Este repositório traz um pipeline CI/CD padrão para projetos batch de Machine Learning no Databricks, seguindo o padrão Vivo CodePlay.

A solução é usada pelos repos gerados a partir de:

* 🧩 [**Tech Product: Modelos de Machine Learning**](https://code.redecorp.br/platform-code/applications/create/template%3Adefault%2Fmlops-models)

O objetivo é **desacoplar a lógica de CI/CD** do código do projeto de ML, garantindo:

* padronização
* segurança
* reaproveitamento
* fácil manutenção

---

## 🗂️ Estrutura de Pastas

### 📁 `Vivo.CodePlay.Pipelines/tech_products/viml`

```
Vivo.CodePlay.Pipelines/tech_products/viml/
├── README.md
├── carta-excecao-devops.md
├── pipeline_mlops_ci_cd.yml
└── templates
    ├── cd
    │   ├── cd_databricks_deploy_job.yml
    │   └── cd_databricks_deploy.yml
    └── ci
        ├── ci_tests.yml
        └── ci_validate_config.yml
```

#### 📌 Explicação

* **README.md**
  Documentação.

* **carta-excecao-devops.md**
  Documento de governança / compliance DevOps (quando aplicável).

* **pipeline_mlops_ci_cd.yml**
  Pipeline principal que orquestra CI e CD.
  É o arquivo consumido pelo repositório cliente via `extends`.

* **templates/ci/**

  * `ci_validate_config.yml`
    Valida a existência e a estrutura dos arquivos de configuração do projeto consumidor.
  * `ci_tests.yml`
    Executa testes automatizados (`pytest`) usando `uv`.

* **templates/cd/**

  * `cd_databricks_deploy.yml`
    Pipeline de deploy no Databricks (jobs, sync de código, autenticação).
  * `cd_databricks_deploy_job.yml`
    Template reutilizável de deploy no Databricks, definido diretamente no pipeline,
    com menos dependência de scripts externos.

---

### 📁 `ml-project` (Repositório Consumidor)

```
ml-project/
├── .azuredevops
│   ├── README.md
│   └── pipeline.yml
└── config
    ├── config.yaml
    └── jobs-config.json
└── ...
    └── ...
```

#### 📌 Explicação

* **.azuredevops/pipeline.yml**
  Pipeline mínimo responsável por:

  * definir variáveis
  * selecionar ambiente
  * importar o Tech Product (`viml`)

* **config/config.yaml**
  Configurações funcionais do projeto de ML (MLflow, Feature Store, etc).

* **config/jobs-config.json**
  Define os parâmetros dos jobs no Databricks (train, evaluate, predict),
  que são consumidos diretamente pelo POST da API REST do Databricks.

---

## ▶️ Como Usar o Pipeline

O pipeline do projeto consumidor **não implementa lógica de CI/CD**.  
Ele apenas **define variáveis** e **importa o Tech Product**.

### 🔧 Variáveis obrigatórias no `pipeline.yml`

| Variável | Descrição |
|---------|----------|
| `environment` | Ambiente de execução do pipeline (`dev` ou `prod`). |
| `variableGroupName` | Grupo de variáveis do Azure DevOps usado para o ambiente (ex: `databricks-dev`, `databricks-prod`). |
| `runTests` | Define se os testes automatizados devem ser executados. |
| `runTrain` | Define se o job de **treinamento** será executado. |
| `runEvaluate` | Define se o job de **avaliação** será executado. |
| `runPredict` | Define se o job de **predição** será executado. |
| `repoName` | Nome do repositório do projeto consumidor. |
| `repoUrl` | URL do repositório no Azure DevOps. |
| `repoPathDatabricks` | Caminho do projeto no workspace do Databricks. |
| `pythonVersion` | Versão do Python usada no pipeline. |

---

## 📥 Exemplo de Importação do Tech Product

```yaml
variables:
- name: environment
  value: dev
- name: variableGroupName
  value: databricks-dev
- name: runTests
  value: true
- name: runTrain
  value: false
- name: runEvaluate
  value: false
- name: runPredict
  value: true
- name: repoName
  value: $(Build.Repository.Name)
- name: repoUrl
  value: https://dev.azure.com/.../_git/$(Build.Repository.Name)
- name: repoPathDatabricks
  value: /Workspace/Shared/$(Build.Repository.Name)
- name: pythonVersion
  value: "3.13"
```

---

## 🔄 Fluxo do Pipeline

```text
📦 Checkout
   ⬇️
🔍 Validate Config Files
   ⬇️
🧪 Run Tests (opcional)
   ⬇️
🔐 Auth Databricks
   ⬇️
🔁 Sync Repo to Databricks
   ⬇️
🚀 Deploy Jobs Databricks
```

---

## 🧠 Funcionalidades de Cada Etapa

### 🔍 Validate Config Files

* Verifica a existência de:

  * `config/config.yaml`
  * `config/jobs-config.json`
* Valida:

  * estrutura YAML
  * campos obrigatórios
* Falha cedo em caso de erro (fail fast)

---

### 🧪 Run Tests

* Instala dependências com `uv`
* Executa `pytest`
* Gera relatório de testes
* Pode ser desligado via parâmetro (`runTests: false`)

---

### 🔐 Auth Databricks

* Gera token via Service Principal
* Exporta variáveis de ambiente seguras

---

### 🔁 Sync Repo to Databricks

* Cria ou atualiza o repo no Databricks Workspace
* Mantém branch sincronizada

---

### 🚀 Deploy Jobs Databricks

* Lê `jobs-config.json`
* Cria ou atualiza jobs no Databricks
* Suporta múltiplos jobs (train, evaluate, predict)

---

## ⚙️ Configurações Obrigatórias do Projeto Consumidor

### 📄 `config/config.yaml`

**Obrigatório** — sem ele o pipeline falha.

Ex: 
```yaml
mlflow_uri: databricks
mlflow_model_name: my_model_name
feature_store_implementation: databricks
feature_table_or_service: my_feature_table
```

📌 Usado por:

* código de ML
* jobs Databricks
* validação de pipeline

---

### 📄 `config/jobs-config.json`

Define **todos os jobs do Databricks** de forma declarativa.

```json
{
  "train": {
    "name": "${REPO_NAME}_train",
    "existing_cluster_id": "0120-xxxx",
    "spark_python_task": {
      "python_file": "${REPO_PATH_DATABRICKS}/app/__main__.py",
      "parameters": [
        "train",
        "--config",
        "${REPO_PATH_DATABRICKS}/config/config.yaml"
      ]
    }
  }
}
```

📌 Características:

* suporta múltiplos jobs
* permite agendamento (`schedule`)
* reutiliza variáveis do pipeline
* Outras funcionalidades jobs: [Documentação REST API Databricks](https://docs.databricks.com/api/azure/workspace/jobs/create)