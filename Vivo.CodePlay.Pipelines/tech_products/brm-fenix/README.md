# BRM Fenix - CodePlay Framework

> **Versão:** 1.1.0 | **Status:** Production | **Última Atualização:** 2 de Janeiro de 2026

## 🎯 Visão Executiva

### O que é?

O **BRM Fenix** é um framework de automação CI/CD para provisionamento, deploy e gerenciamento de aplicações Oracle BRM (Billing and Revenue Management) em ambientes Cloud. O sistema oferece pipelines automatizados para build, deploy, segurança, monitoramento e gerenciamento de infraestrutura (IaC) em Oracle Cloud Infrastructure (OCI) com Kubernetes.

O framework implementa padrões CodePlay, garantindo consistência, rastreabilidade e self-service para equipes de desenvolvimento e DevOps, eliminando processos manuais e reduzindo tempo de deploy de horas para minutos.

### Principais Capacidades

- ✅ **CI/CD Automatizado** - Pipelines completos para build, test, security scan e deploy de aplicações Java BRM
- ✅ **Infraestrutura como Código (IaC)** - Gerenciamento automatizado de clusters OKE (Oracle Kubernetes Engine) via OCI CLI
- ✅ **Monitoramento Proativo** - Observabilidade contínua de pods, nodes e aplicações com alertas no Microsoft Teams
- ✅ **Segurança Integrada** - Análise de código (Fortify, SonarQube), scan de containers (Docker) e validação de dependências
- ✅ **Multi-ambiente** - Suporte para 10+ ambientes (dev, qa, bugfix, preprod, prodlike) com isolamento e validação
- ✅ **Orquestração Complexa** - Validação de estado, rollback automático e self-healing

### Métricas Chave

| Métrica | Valor | Descrição |
|---------|-------|-----------|
| Ambientes Gerenciados | 10+ | POC, DEV01-03, QA01-02, Bugfix, TPM, PreProd, ProdLike |
| Aplicações BRM | 15+ | BillingCare, ECE, PDC, CM, BRM Apps, etc. |
| Tempo de Deploy | <15 min | Deploy automatizado end-to-end |
| Disponibilidade | 99.5% | Uptime médio dos ambientes monitorados |
| Nodes Kubernetes | 50+ | Instâncias OCI gerenciadas via IaC |

---

## 🏗️ Arquitetura (Visão Técnica)

### Stack Tecnológico

```
Cloud:         Oracle Cloud Infrastructure (OCI)
Kubernetes:    OKE (Oracle Kubernetes Engine) + Helm Charts
CI/CD:         Azure DevOps Pipelines
Build:         Maven 3.x + Java 8/11
Containers:    Docker + Azure Container Registry (ACR)
IaC:           OCI CLI + Bash Scripts
Monitoring:    Kubernetes API + Microsoft Teams Webhooks
Security:      Fortify SCA, SonarQube, Docker Scan
Orchestration: SSH (Bastion Host), kubectl, oci-cli
```

### Diagrama de Arquitetura

```
                          ┌──────────────────────────┐
                          │     Azure DevOps         │
                          │                          │
                          │  ┌──────────────────┐    │
                          │  │Pipeline Trigger  │    │
                          │  └────────┬─────────┘    │
                          │           │              │
                          │           ↓              │
                          │  ┌──────────────────┐    │
                          │  │CodePlay Framework│    │
                          │  └────────┬─────────┘    │
                          │           │              │
                          │           ↓              │
                          │  ┌──────────────────┐    │
                          │  │  BRM Fenix       │    │
                          │  │  Provisioner     │    │
                          │  └────────┬─────────┘    │
                          └───────────┼──────────────┘
                                      │
                 ┌────────────────────┼────────────────────┐
                 │                    │                    │
                 ↓                    ↓                    ↓
    ┌────────────────────┐  ┌────────────────┐  ┌────────────────┐
    │ API Default        │  │ IaC (Infra)    │  │ Monitoring     │
    │ CI/CD Provisioner  │  │ START/STOP     │  │ Health Checks  │
    └──────────┬─────────┘  └───────┬────────┘  └───────┬────────┘
               │                    │                    │
               │                    │                    │
    ┌──────────┴─────────┐          │                    │
    │                    │          │                    │
    ↓                    ↓          ↓                    ↓
┌─────────┐      ┌──────────────┐  │         ┌──────────────────┐
│  ACR    │      │  Fortify SCA │  │         │Microsoft Teams   │
│ Docker  │      │  SonarQube   │  │         │  Notifications   │
└─────────┘      └──────────────┘  │         └──────────────────┘
                                   │
                                   ↓
                    ┌──────────────────────────────┐
                    │  Oracle Cloud Infrastructure │
                    │                              │
                    │  ┌────────────────────┐      │
                    │  │   OKE Cluster      │      │
                    │  └─────────┬──────────┘      │
                    │            │                 │
                    │  ┌─────────┼──────────┐      │
                    │  │         │          │      │
                    │  ↓         ↓          ↓      │
                    │ ┌────┐ ┌──────┐ ┌────────┐  │
                    │ │Pods│ │ Jobs │ │Services│  │
                    │ └────┘ └──────┘ └────┬───┘  │
                    │                      │      │
                    │                      ↓      │
                    │            ┌──────────────┐ │
                    │            │Load Balancer │ │
                    │            └──────────────┘ │
                    └──────────────────────────────┘
```

### Componentes Principais

| Componente | Tecnologia | Responsabilidade |
|------------|------------|------------------|
| **Entrypoint** | YAML Pipeline Template | Roteamento para provisioners específicos |
| **API Default Provisioner** | Multi-stage Pipeline | CI/CD completo para aplicações Java BRM |
| **IaC Provisioner** | OCI CLI + Bash | START/STOP de nodes Kubernetes no OKE |
| **Monitoring Provisioner** | kubectl + Teams API | Health check de pods/nodes + alertas |
| **Oracle Base Image** | Docker + ACR | Atualização de imagens Oracle base |
| **Task Groups** | Reusable Templates | Componentes reutilizáveis (checkout, ssh, oci, helm) |
| **Tasks** | Atomic Operations | Operações atômicas (build, deploy, validate) |

---

## 📂 Estrutura do Projeto

```
brm-fenix/
├── provisioners/                    # Provisioners principais (CI/CD, IaC, Monitoring)
│   ├── entrypoint.yml              # Entrypoint principal - roteamento de provisioners
│   ├── api_default/                # Provisioner de CI/CD para aplicações BRM
│   │   ├── provisioner_entry.yml   # Entrypoint do provisioner API
│   │   ├── provisioner_entry_pr.yml # Versão para Pull Requests
│   │   ├── ci/                     # Stages de Continuous Integration
│   │   │   └── stages/
│   │   │       ├── build_test.yml
│   │   │       ├── bundle.yml
│   │   │       ├── code_security_analysis.yml
│   │   │       ├── static_code_analysis.yml
│   │   │       ├── trigger_cd.yml
│   │   │       └── update_assets.yml
│   │   ├── cd/                     # Stages de Continuous Deployment
│   │   │   └── stages/
│   │   │       └── deploy.yml      # Deploy, Smoke Test e Validate Version
│   │   ├── common_stages/          # Stages compartilhados CI/CD
│   │   │   ├── files.yml
│   │   │   ├── finish.yml
│   │   │   └── preparation.yml
│   │   └── variables/              # Variáveis específicas do provisioner
│   │       ├── load.yml
│   │       └── variables.yml
│   ├── iac/                        # Provisioner de Infraestrutura como Código
│   │   ├── provisioner_entry.yml
│   │   ├── stages/
│   │   │   ├── pipeline_initialization.yml
│   │   │   ├── run.yml             # Execução START/STOP de nodes
│   │   │   └── finish.yml
│   │   └── variables/
│   ├── monitoring/                 # Provisioner de Monitoramento
│   │   ├── provisioner_entry.yml
│   │   └── stages/
│   │       └── run.yml             # Health check de pods/nodes
│   └── oracle_base_image/          # Provisioner para atualização de imagens Oracle
│       ├── provisioner_entry.yml
│       └── stages/
│           ├── download.yml
│           ├── process.yml
│           ├── security_analysis.yml
│           └── finish.yml
├── task_groups/                    # Componentes reutilizáveis (Templates)
│   ├── checkout/
│   │   └── checkout.yml
│   ├── helm/
│   │   ├── helm_deployment.yml
│   │   └── helm_update_version.yml
│   ├── oci/
│   │   ├── collect_data_cluster.yml # Coleta dados do cluster OKE
│   │   ├── configure_oci_cli.yml    # Configuração do OCI CLI
│   │   └── download_oci_secure_files.yml
│   ├── observability/
│   │   └── history_files.yml       # Gerenciamento de histórico de erros
│   └── ssh/
│       └── file_transfer.yml       # Transferência de arquivos via SSH
├── tasks/                          # Operações atômicas
│   ├── bash/
│   │   ├── check_errors.yml
│   │   ├── create_logs_file.yml
│   │   ├── replace_variables.yml
│   │   └── verify_brm_apps_version.yml
│   ├── docker/
│   │   ├── build.yml
│   │   ├── create_tar.yml
│   │   ├── login.yml
│   │   ├── logout.yml
│   │   ├── publish.yml
│   │   ├── validate_docker_image_create.yml
│   │   └── validate_docker_image_publish.yml
│   ├── helm/
│   │   ├── helm_install.yml
│   │   ├── helm_uninstall.yml
│   │   └── update_app_version_helm.yml
│   ├── observability/
│   │   ├── create_dashboard_file.yml
│   │   ├── create_history_file.yml
│   │   └── process_data.yml
│   ├── oci/
│   │   ├── configure_oci_cli.yml
│   │   ├── get_cluster.yml
│   │   ├── get_node_pool.yml
│   │   ├── get_nodes.yml
│   │   ├── remove_oci_cli_configuration.yml
│   │   └── validate_oci_cli.yml
│   ├── ssh/
│   │   └── deploy.yml              # Deploy via SSH
│   └── teams/
│       └── send_message_monitoring.yml
├── global/                         # Variáveis globais
│   └── variables/
│       ├── load.yml
│       └── variables.yml
└── resources/                      # Exemplos de pipelines (samples)
    ├── api_default/
    │   └── samples/
    │       ├── azure-pipeline_ci.yml
    │       └── azure-pipeline_cd.yml
    ├── iac/
    │   └── azure-pipeline.yml
    ├── monitoring/
    │   └── azure-pipeline.yml
    └── oracle_base_image/
        └── azure-pipeline.yml
```

---

## 🚀 Quick Start (Desenvolvedores)

### Pré-requisitos

- **Azure DevOps Account** com permissões no projeto
- **Service Connections** configuradas:
  - `BRM_BASTION_<ENV>` (SSH para cada ambiente)
  - `DOCKER_ACR_REGISTRY_SERVICE_CONNECTION_NAME` (Azure Container Registry)
  - `CodePlay` (Git repository connection)
- **Variable Groups** no Azure DevOps:
  - `BRM_TOGGLE_FEATURES` (feature toggles)
  - `BRM_PDC_MODE`, `BRM_ECE_MODE`, `BRM_BIP_MODE` (configurações específicas)
- **Secure Files** no Azure DevOps:
  - `oci_config_brm_fenix` (configuração OCI CLI)
  - `oci_api_key_brm_fenix.pem` (chave privada OCI)

### Configuração de Pipeline CI/CD (API Default)

**1. Criar arquivo de pipeline no repositório da aplicação:**

```yaml
# azure-pipeline.yml
trigger:
  branches:
    include:
      - master
      - develop

resources:
  repositories:
    - repository: CodePlay
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: refs/tags/brm/latest
      endpoint: CodePlay

extends:
  template: tech_products/brm-fenix/provisioners/entrypoint.yml@CodePlay
  parameters:
    config:
      modelName: api_default              # Tipo de provisioner
      technology: java                    # Tecnologia da aplicação
      applicationParameters:
        applicationName: brm-apps         # Nome da aplicação BRM
        helmCharts: brm-apps-helm-chart   # Nome do Helm Chart
        helmChartVersionKey: brm_apps     # Chave de versão no Helm
        containerImageName: brm_apps_tlf  # Nome da imagem Docker
        container: BRM_APPS               # Variável de ambiente
    flow:
      flow: CI                            # CI ou CD
      triggerCD: true                     # Trigger automático do CD
      cd_params:
        forceDeployment: false            # Forçar deploy mesmo sem mudanças
```

**2. Executar pipeline manualmente ou via commit:**

```bash
git add azure-pipeline.yml
git commit -m "feat: add BRM Fenix CI/CD pipeline"
git push origin develop
```

**3. Acompanhar execução no Azure DevOps:**

- Acessar **Pipelines** → Selecionar pipeline → Ver execução
- Stages executados: Preparation → Files → Build/Test → Security → Bundle → Deploy

---

### Configuração de Pipeline de Infraestrutura (IaC)

**Exemplo: START de 2 nodes no ambiente POC**

```yaml
# azure-pipeline-iac-start.yml
trigger: none  # Execução manual

resources:
  repositories:
    - repository: CodePlay
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: refs/tags/brm/latest_iac
      endpoint: CodePlay

extends:
  template: tech_products/brm-fenix/provisioners/entrypoint.yml@CodePlay
  parameters:
    config:
      modelName: iac
    iacParameters:
      action: START              # START ou STOP
      environment: poc           # Nome do ambiente
      numberAffectedNodes: 2     # Quantidade de nodes (ou "ALL")
```

**Executar via Azure DevOps:**

1. **Pipelines** → **Run pipeline**
2. Selecionar branch `master`
3. Confirmar parâmetros
4. Aguardar execução (validação → start nodes → wait pods/jobs → validação final)

---

### Configuração de Pipeline de Monitoramento

**Exemplo: Monitoramento contínuo de 10 ambientes**

```yaml
# azure-pipeline-monitoring.yml
schedules:
  - cron: "*/30 * * * *"          # A cada 30 minutos
    displayName: Monitoring Schedule
    branches:
      include:
        - master

trigger: none

resources:
  repositories:
    - repository: CodePlayPipelines
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: refs/tags/brm/latest_monitoring
      endpoint: CodePlay

extends:
  template: tech_products/brm-fenix/provisioners/entrypoint.yml@CodePlayPipelines
  parameters:
    config:
      modelName: monitoring
    monitoringParameters:
      environmentsMonitoring: poc,dev01,dev02,dev03,qa01,qa02,bugfix01,tpm,preprod,prodlike
      environmentsObservability: poc,qa01,qa02,preprod,prodlike  # Ambientes com histórico
```

**Alertas no Microsoft Teams:**

- ✅ Pods em estado `Running` ou `Completed`
- ❌ Pods com erro (`CrashLoopBackOff`, `ImagePullBackOff`, etc.)
- ✅ Nodes em estado `Ready`
- ❌ Nodes com problemas (`NotReady`, `Unknown`)

---

## 📊 Dependências Principais

### Runtime (Pipeline Execution)

| Package/Tool | Versão | Propósito |
|--------------|--------|-----------|
| **Azure Pipelines Agent** | Latest | Execução de pipelines |
| **OCI CLI** | 3.71.0 | Gerenciamento de recursos OCI |
| **kubectl** | 1.28+ | Gerenciamento de Kubernetes |
| **Helm** | 3.x | Deploy de aplicações Kubernetes |
| **Docker** | 20.x+ | Build e push de imagens |
| **Maven** | 3.6+ | Build de aplicações Java |
| **Java** | 8/11 | Runtime para aplicações BRM |
| **Bash** | 4.x+ | Scripts de automação |
| **jq** | 1.6+ | Parsing de JSON |
| **SSH** | OpenSSH 7.x+ | Conexão com Bastion Host |

### Integrações Externas

| Serviço | Tipo | Documentação |
|---------|------|--------------|
| **Oracle Cloud Infrastructure (OCI)** | Cloud Provider | https://docs.oracle.com/en-us/iaas/ |
| **Azure Container Registry (ACR)** | Container Registry | https://learn.microsoft.com/azure/container-registry/ |
| **Fortify SCA** | Security Analysis | https://www.microfocus.com/fortify |
| **SonarQube** | Code Quality | https://docs.sonarqube.org/ |
| **Microsoft Teams** | Notifications | https://learn.microsoft.com/microsoftteams/webhooks |
| **Azure DevOps** | CI/CD Platform | https://learn.microsoft.com/azure/devops/ |

---

## 🔐 Segurança

### Autenticação OCI

- **Método:** API Key Authentication (RSA Private Key)
- **Storage:** Azure DevOps Secure Files
- **Permissões:** Read/Write em Compartments específicos (DEV/TEST)
- **Rotação:** Manual via OCI Console

### Secrets Management

| Secret | Storage | Descrição |
|--------|---------|-----------|
| `oci_api_key_brm_fenix.pem` | Secure Files | Chave privada para OCI CLI |
| `oci_config_brm_fenix` | Secure Files | Configuração OCI (user, tenancy, region) |
| `TEAMS_WEBHOOK_MONITORING` | Variable Group | Webhook para alertas do Teams |
| SSH Keys (Bastion) | Service Connections | Acesso SSH aos ambientes BRM |

### Análise de Segurança (CI/CD)

1. **Static Code Analysis (SonarQube)**
   - Quality Gates
   - Code Coverage (mínimo 70%)
   - Code Smells, Bugs, Vulnerabilities

2. **Security Code Analysis (Fortify SCA)**
   - Scan de vulnerabilidades
   - Critical/High findings bloqueiam pipeline
   - Whitelist via `FortifyExclusion` repository

3. **Container Security Scan**
   - Scan de imagens Docker
   - Verificação de vulnerabilidades CVE
   - Validação de dependências

---

## 📡 Provisioners e Modelos

### 1️⃣ API Default (CI/CD)

**Propósito:** Pipeline completo de CI/CD para aplicações Java BRM

**Aplicações Suportadas:**
- `billing-care` (BillingCare Core)
- `billingcare-extension` (BillingCare Extension)
- `brm-apps` (BRM Apps)
- `config-jobs` (Configuration Jobs)
- `connection-manager` (Connection Manager)
- `elastic-charging-engine` (ECE)
- `pricing-design-center` (PDC)
- `bi-publisher-reports` (BIP)
- E mais...

**Fluxos Disponíveis:**

#### **CI Flow (Continuous Integration)**

```
Prepare → Files → Build/Test → Code Analysis → Security → Bundle → Trigger CD

┌──────────┐    ┌──────────┐    ┌───────────┐    ┌─────────────┐
│ Prepare  │───→│  Files   │───→│Build/Test │───→│Code Analysis│
│ Versions │    │ Source+  │    │  Maven    │    │  SonarQube  │
└──────────┘    │ Shared   │    └───────────┘    └──────┬──────┘
                └──────────┘                            │
                                                        ↓
┌──────────┐    ┌──────────┐    ┌───────────┐    ┌─────────────┐
│Trigger CD│←───│  Bundle  │←───│  Security   │←───│   SCA Scan  │
│ Pipeline │    │ Artifacts│    │Fortify Scan │    │   (Docker)  │
└──────────┘    └──────────┘    └─────────────┘    └─────────────┘
```

**Stages:**
1. **Preparation** - Define versões, imagens Docker
2. **Files** - Checkout do source + shared files em um único artefato
3. **Build & Test** - Compila código, executa testes
4. **Static Code Analysis** - SonarQube scan
5. **Security Analysis** - Fortify SCA scan
6. **Bundle** - Build de imagem Docker e publicação no ACR
7. **Trigger CD** - Dispara pipeline de deploy

#### **CD Flow (Continuous Deployment)**

```
Prepare → Deploy → Smoke Test → Validate Version → Update Assets

┌──────────┐    ┌────────────┐    ┌───────────┐    ┌──────────────┐
│ Prepare  │───→│   Deploy   │───→│Smoke Test │───→│Validate      │
│ Versions │    │ Kubernetes │    │  Health   │    │   Version    │
└──────────┘    └────────────┘    └─────┬─────┘    └──────┬───────┘
                                        │                  │
                                        └────────┬─────────┘
                                                 ↓
                                         ┌──────────────┐
                                         │ Update Assets│
                                         │  (Release Tag│
                                         │   on master_15)│
                                         └──────────────┘
```

**Stages:**
1. **Preparation** - Validação de versão, estado do cluster
2. **Deploy** - Deploy via Helm no Kubernetes (inclui Smoke Test e Validate Version)
3. **Update Assets** - Cria tag de release no repositório (apenas `master_15`)

**Parâmetros:**

```yaml
config:
  modelName: api_default
  technology: java
  stageSecurityOnly: false  # true = executa apenas security stages
  applicationParameters:
    applicationName: brm-apps
    helmCharts: brm-apps-helm-chart
    helmChartVersionKey: brm_apps
    containerImageName: brm_apps_tlf
    buildArgs: ""  # Argumentos extras para Docker build
    container: BRM_APPS
    helmReleaseNames: brm-apps
flow:
  flow: CI  # ou CD
  triggerCD: true
  cd_params:
    forceDeployment: false
```

---

### 2️⃣ IaC (Infrastructure as Code)

**Propósito:** Gerenciamento de infraestrutura OKE (Oracle Kubernetes Engine)

**Operações Suportadas:**
- **START** - Iniciar nodes do cluster
- **STOP** - Parar nodes do cluster

**Workflow START:**

```
Pipeline    OCI CLI    OKE Cluster    Nodes    Pods/Jobs
   │            │            │          │           │
   │──Config────>│            │          │           │
   │            │            │          │           │
   │──Validate─>│            │          │           │
   │            │            │          │           │
   │            │──Get Data─>│          │           │
   │            │            │          │           │
   │──Action────>│            │          │           │
   │  START     │            │          │           │
   │            │            │          │           │
   │            │──Start─────────────>│           │
   │            │            │          │           │
   │            │            │<────Join─│           │
   │            │            │  Cluster │           │
   │            │            │          │           │
   │──kubectl───────────────>│          │           │
   │  get pods  │            │          │           │
   │            │            │          │           │
   │──kubectl───────────────>│          │           │
   │  get jobs  │            │          │           │
   │            │            │          │           │
   │            │            │          │──Running──>│
   │            │            │          │ Completed │
   │            │            │          │           │
   │<─────────────────────────────────────All OK────│
   │            │            │          │           │
   │──Validate─>│            │          │           │
   │  Final     │            │          │           │
   │  State     │            │          │           │
   │            │            │          │           │
   │──✅────────│            │          │           │
   │  Success   │            │          │           │
```

**Parâmetros:**

```yaml
config:
  modelName: iac
iacParameters:
  action: START  # ou STOP
  environment: poc  # poc, dev01, qa01, etc.
  numberAffectedNodes: 2  # Número de nodes ou "ALL"
```

**Validações:**
- Cluster deve estar em estado `ACTIVE`
- Nodes devem estar em estado correto (`STOPPED` para START, `RUNNING` para STOP)
- Validação idempotente (permite re-execução)
- Timeout de 30 minutos para pods
- Timeout de 20 minutos para jobs

**Ambientes Suportados:**

| Ambiente | Compartment OCI | Descrição |
|----------|----------------|-----------|
| `poc` | DEV | Proof of Concept |
| `dev01`, `dev02`, `dev03` | DEV | Desenvolvimento |
| `qa01`, `qa02` | TEST | Quality Assurance |
| `bugfix01` | TEST | Correção de bugs |
| `tpm`, `preprod`, `prodlike` | TEST | Pré-produção |

---

### 3️⃣ Monitoring (Observabilidade)

**Propósito:** Monitoramento contínuo de saúde de pods e nodes Kubernetes

**Funcionalidades:**
- ✅ Health check de pods (Running, Completed, Failed)
- ✅ Health check de nodes (Ready, NotReady)
- ✅ Alertas no Microsoft Teams
- ✅ Histórico de erros (Dashboard Markdown)
- ✅ Limpeza automática de erros antigos (30 dias)

**Workflow:**

```
      ┌──────────────────────┐
      │ Scheduled Trigger    │
      │  (Every 30 minutes)  │
      └──────────┬───────────┘
                 │
                 ↓
      ┌──────────────────────┐
      │ For Each Environment │
      └──────────┬───────────┘
                 │
                 ↓
      ┌──────────────────────┐
      │   SSH to Bastion     │
      └──────────┬───────────┘
                 │
        ┌────────┴─────────┐
        │                  │
        ↓                  ↓
┌───────────────┐   ┌────────────────┐
│ kubectl get   │   │ kubectl get    │
│    pods       │   │    nodes       │
└───────┬───────┘   └────────┬───────┘
        │                    │
        ↓                    ↓
┌───────────────┐   ┌────────────────┐
│ Analyze Pods  │   │ Analyze Nodes  │
│    Status     │   │    Status      │
└───────┬───────┘   └────────┬───────┘
        │                    │
        ↓                    ↓
   ┌─────────┐          ┌─────────┐
   │Problems?│          │Problems?│
   └────┬────┘          └────┬────┘
        │                    │
    ┌───┴───┐            ┌───┴───┐
    │       │            │       │
    ↓       ↓            ↓       ↓
  ┌───┐   ┌───┐        ┌───┐   ┌───┐
  │Yes│   │No │        │Yes│   │No │
  └─┬─┘   └─┬─┘        └─┬─┘   └─┬─┘
    │       │            │       │
    └───┬───┘            └───┬───┘
        │                    │
        └──────────┬─────────┘
                   │
        ┌──────────┴─────────┐
        │                    │
        ↓                    ↓
┌──────────────┐     ┌──────────────┐
│ 🔴 Alert     │     │ 🟢 Status OK │
│   Teams      │     │   Teams      │
└──────┬───────┘     └──────┬───────┘
       │                    │
       └──────────┬─────────┘
                  │
                  ↓
       ┌──────────────────┐
       │ Save to Dashboard│
       └─────────┬────────┘
                 │
                 ↓
       ┌──────────────────┐
       │ Clean Old Errors │
       │   (30 days old)  │
       └──────────────────┘
```

**Parâmetros:**

```yaml
config:
  modelName: monitoring
monitoringParameters:
  environmentsMonitoring: poc,dev01,dev02,dev03,qa01,qa02,bugfix01,tpm,preprod,prodlike
  environmentsObservability: poc,qa01,qa02,preprod,prodlike  # Ambientes com dashboard
```

**Exemplo de Alerta (Teams):**

```
🚨 BRM Monitoring - POC Environment

📊 Pods Status:
  🟢 billingcare-0: Running
  🔴 elastic-charging-engine-0: CrashLoopBackOff
  🟢 config-jobs-abc123: Completed

📊 Nodes Status:
  🟢 oke-node-1: Ready
  🟢 oke-node-2: Ready
  🔴 oke-node-3: NotReady

⚠️ Action Required: Check pod logs and node status
```

---

### 4️⃣ Oracle Base Image

**Propósito:** Atualização de imagens base Oracle (Oracle Linux, Java, WebLogic)

**Workflow:**
1. **Download** - Download da imagem Oracle oficial
2. **Process** - Tag e preparação da imagem
3. **Security Analysis** - Scan de vulnerabilidades
4. **Push** - Push para Azure Container Registry

**Parâmetros:**

```yaml
config:
  modelName: oracle_base_image
oracleBaseImageUpdate:
  oracleImageLink: https://container-registry.oracle.com/...
  pathACR: fnix/oracle-base
  customTag: 12.2.1.4-jdk8-ol8
```

---

##  Troubleshooting

### Problemas Comuns

#### 1. Erro de Conexão com OCI

**Sintoma:**
```
Error: ServiceError: 401-NotAuthenticated
The required information to complete authentication was not provided.
```

**Solução:**
```bash
# Verificar se Secure Files estão configurados
# Azure DevOps → Pipelines → Library → Secure files
# Deve conter:
#   - oci_config_brm_fenix
#   - oci_api_key_brm_fenix.pem

# Validar conteúdo do config:
[DEFAULT]
user=ocid1.user.oc1..aaaaaaaakc2oer...
fingerprint=b2:3c:51:b8:d1:57:e4:04...
tenancy=ocid1.tenancy.oc1..aaaaaaaaa63icmpj...
region=sa-saopaulo-1
key_file=/path/to/oci_api_key_brm_fenix.pem
```

---

#### 2. Pods não iniciam após START de nodes

**Sintoma:**
```
❌ Timeout reached while waiting for Pods to be Running or Completed.
Pods still not ready:
  elastic-charging-engine-0   Pending
```

**Diagnóstico:**
```bash
# SSH no Bastion Host
ssh brm-bastion-poc

# Verificar eventos do pod
kubectl describe pod elastic-charging-engine-0

# Verificar logs
kubectl logs elastic-charging-engine-0 --tail=100

# Verificar recursos do node
kubectl top nodes
kubectl describe node oke-node-1
```

**Soluções Comuns:**
- **ImagePullBackOff**: Verificar acesso ao registry, credenciais do `imagePullSecret`
- **CrashLoopBackOff**: Verificar logs da aplicação, variáveis de ambiente, healthcheck
- **Pending**: Verificar recursos disponíveis (CPU/Memory), node affinity

---

#### 3. Job `pdc-idp-loader-job` sempre em erro

**Sintoma:**
```
Job pdc-idp-loader-job failed to complete
```

**Solução:**
Este job é excluído da validação porque é esperado que falhe em alguns cenários. O pipeline já possui filtro:

```yaml
# Em wait_jobs e wait_pods
grep -v '^pdc-idp-loader-job'
```

Se outro job estiver falhando, verificar:
```bash
kubectl get job pdc-idp-loader-job -o yaml
kubectl logs job/pdc-idp-loader-job
```

---

#### 4. SonarQube Quality Gate Failed

**Sintoma:**
```
❌ SonarQube Quality Gate Failed
Coverage: 65% (threshold: 70%)
```

**Solução:**
```bash
# Aumentar cobertura de testes
mvn clean test jacoco:report

# Verificar relatório local
open target/site/jacoco/index.html

# Ou ajustar threshold (não recomendado)
# sonar-project.properties:
sonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
```

---

#### 6. Fortify Scan bloqueia pipeline

**Sintoma:**
```
❌ Fortify SCA found 3 Critical vulnerabilities
```

**Solução:**
```bash
# Opção 1: Corrigir vulnerabilidades
# Atualizar dependências vulneráveis no pom.xml

# Opção 2: Whitelist (apenas se false positive)
# Adicionar ao repositório FortifyExclusion:
# fortify-exclusions.xml
<FortifyExclusions>
  <Exclusion>
    <RuleID>12345</RuleID>
    <Reason>False positive - validação já existe</Reason>
  </Exclusion>
</FortifyExclusions>
```

---

## 📈 Métricas e Monitoramento

### Ferramentas

- **Logs:** Azure DevOps Pipeline Logs
- **Kubernetes:** kubectl logs, kubectl describe
- **Monitoring:** Custom Teams Webhooks
- **Observability:** Markdown Dashboard (Git-based)

### Dashboards

**Exemplo de Dashboard (poc-dashboard.md):**

```markdown
# BRM Monitoring Dashboard - POC Environment

**Última Atualização:** 2025-12-30 10:30:00

## 📊 Status Atual

### Pods
- 🟢 **billingcare-0**: Running
- 🟢 **elastic-charging-engine-0**: Running
- 🟢 **config-jobs-abc123**: Completed

### Nodes
- 🟢 **oke-node-1**: Ready (CPU: 45%, Memory: 60%)
- 🟢 **oke-node-2**: Ready (CPU: 38%, Memory: 55%)

## 🟡ℹ️ Histórico de Erros

### 2025-12-29 15:30
- **Pod:** elastic-charging-engine-0
- **Status:** CrashLoopBackOff
- **Resolução:** Reiniciado manualmente

### 2025-12-28 09:15
- **Node:** oke-node-3
- **Status:** NotReady
- **Resolução:** Node removido e recriado
```

---

## 📚 Documentação Adicional

- 📖 [Guia de Contribuição](./CONTRIBUTING.md)
- 🏗️ [Arquitetura Detalhada](./docs/ARCHITECTURE.md)
- 📡 [Referência de Tasks](./docs/TASKS.md)
- 🗃️ [Database Schema BRM](./docs/DATABASE.md) *(Oracle BRM documentation)*
- 🚀 [Deploy Guide Completo](./docs/DEPLOY.md)
- 🔐 [Security Guidelines](./docs/SECURITY.md)

### Links Externos

- [Oracle BRM Documentation](https://docs.oracle.com/en/industries/communications/brm/)
- [Oracle Cloud Infrastructure CLI](https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/)
- [Azure DevOps Pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)

---

## 👥 Equipe e Contato

| Papel | Responsabilidade | Contato |
|-------|------------------|---------|
| **Tech Lead BRM** | Arquitetura e estratégia técnica | brm-tech-lead@vivo.com |
| **DevOps Team** | Pipelines e infraestrutura | devops-brm@vivo.com |
| **Platform Team** | OCI, Kubernetes, networking | platform-team@vivo.com |
| **Security Team** | Fortify, SonarQube, compliance | security@vivo.com |

---

## 📄 Licença

© 2025 Vivo - Telefónica Brasil  
Proprietary - Internal Use Only

---

## 🔄 Changelog

### [1.0.0] - 2025-12-30

#### ✨ Features Implementadas
- ✅ Pipeline CI/CD completo para 15+ aplicações BRM
- ✅ Provisioner IaC para START/STOP de nodes OKE
- ✅ Sistema de monitoramento com alertas Teams
- ✅ Atualização automatizada de Oracle Base Images
- ✅ Integração com Fortify SCA e SonarQube
- ✅ Observability dashboard com histórico de erros
- ✅ Suporte para 10+ ambientes (dev, qa, preprod, prodlike)

#### 🐛 Fixes
- ✅ Validação idempotente de nodes (aceita re-execução START/STOP)
- ✅ Exclusão de `pdc-idp-loader-job` das validações de wait
- ✅ Limpeza automática de histórico de erros (30 dias)
- ✅ Logs padronizados com emojis e agrupamento
- ✅ Configuração correta de `oci_version` no config OCI CLI

#### 🔧 Improvements
- ✅ Timeout configurável para pods (30 min) e jobs (20 min)
- ✅ Validação de estado final do cluster com fallback
- ✅ Mensagens de erro descritivas com contexto
- ✅ Supressão de warnings Python deprecation

---

**Última Atualização:** 2 de Janeiro de 2026  
**Versão da Documentação:** 1.1.0  
**Autor:** CodePlay Framework Team
