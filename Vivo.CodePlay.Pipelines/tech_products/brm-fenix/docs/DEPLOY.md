# Guia de Deploy - BRM Fenix

> **Procedimentos completos de deployment para todos os ambientes BRM Fenix**

## 📋 Índice

- [Ambientes](#ambientes)
- [Deploy Manual via Azure DevOps](#deploy-manual-via-azure-devops)
- [Deploy Automático (CI/CD)](#deploy-automático-cicd)
- [Deploy de Infraestrutura (IaC)](#deploy-de-infraestrutura-iac)
- [Rollback Procedures](#rollback-procedures)
- [Health Checks](#health-checks)
- [Troubleshooting Deploy](#troubleshooting-deploy)

---

## 🌍 Ambientes

### Matriz de Ambientes

| Ambiente | Código | Cluster OKE | Namespace | URL Base | Auto-Deploy | Aprovação |
|----------|--------|-------------|-----------|----------|-------------|-----------|
| **Desenvolvimento** | `DEV` | oke-brm-dev | `brm-dev` | https://brm-dev.vivo.com | ✅ | ❌ |
| **Homologação** | `HML` | oke-brm-hml | `brm-hml` | https://brm-hml.vivo.com | ✅ | ❌ |
| **Pré-Produção** | `PRE` | oke-brm-pre | `brm-pre` | https://brm-pre.vivo.com | ❌ | ✅ (DevOps) |
| **Produção** | `PRD` | oke-brm-prd | `brm-prd` | https://brm.vivo.com | ❌ | ✅ (C-Level) |

### Características por Ambiente

#### DEV
- **Propósito:** Desenvolvimento ativo, testes exploratórios
- **Estabilidade:** Baixa (pode quebrar frequentemente)
- **Deploy:** Automático a cada commit em `develop`
- **Dados:** Dados sintéticos / mock
- **Downtime Aceitável:** 24h
- **Nodes OKE:** 1-2 (pode ser STOPPED fora do horário comercial)

#### HML
- **Propósito:** Testes integrados, validação de QA
- **Estabilidade:** Média (testes podem falhar)
- **Deploy:** Automático a cada commit em `release/*`
- **Dados:** Cópia sanitizada de produção
- **Downtime Aceitável:** 8h
- **Nodes OKE:** 2-3 (sempre RUNNING)

#### PRE
- **Propósito:** Validação final antes de produção
- **Estabilidade:** Alta (espelho de produção)
- **Deploy:** Manual com aprovação DevOps
- **Dados:** Cópia completa de produção (sanitizada)
- **Downtime Aceitável:** 2h
- **Nodes OKE:** 3+ (sempre RUNNING)

#### PRD
- **Propósito:** Produção (clientes reais)
- **Estabilidade:** Máxima (SLA 99.9%)
- **Deploy:** Manual com aprovação C-Level
- **Dados:** Dados reais de produção
- **Downtime Aceitável:** 0 (zero-downtime deploy)
- **Nodes OKE:** 5+ (sempre RUNNING, multi-AZ)

---

## 🚀 Deploy Manual via Azure DevOps

### Passo 1: Acessar Pipeline

1. Acesse Azure DevOps: https://dev.azure.com/tlf-vivo
2. Navegue até projeto: **BRM Fenix**
3. Clique em **Pipelines** > **BRM Fenix - CD**

### Passo 2: Executar Pipeline

4. Clique em **Run pipeline**
5. Preencha os parâmetros:

```yaml
Environment: HML               # DEV, HML, PRE, PRD
Version: 1.2.3                 # Versão a deployar
DeploymentType: rolling        # rolling, blue-green, canary
SkipTests: false               # Pular smoke tests?
Force: false                   # Forçar deploy (ignora validações de estado)?
```

6. Clique em **Run**

### Passo 3: Aprovar (se necessário)

- **PRE:** Aprovação automática solicitada ao grupo `DevOps-Approvers`
- **PRD:** Aprovação manual requerida de `C-Level-Approvers`

**Fluxo de Aprovação:**

```
                    ┌─────────────────────┐
                    │ Pipeline Iniciado   │
                    └──────────┬──────────┘
                               │
                               ↓
                      ┌────────────────┐
                      │   Ambiente?    │
                      └────┬──────┬────┘
                           │      │
           ┌───────────────┴──┐   └─────────────────┐
           │                  │                     │
           ↓                  ↓                     ↓
    ┌───────────┐      ┌──────────────┐     ┌──────────────────┐
    │  DEV/HML  │      │     PRE      │     │       PRD        │
    └─────┬─────┘      └──────┬───────┘     └────────┬─────────┘
          │                   │                       │
          │                   ↓                       ↓
          │           ┌─────────────────┐    ┌─────────────────┐
          │           │ Aguardar        │    │ Aguardar        │
          │           │ Aprovação       │    │ Aprovação       │
          │           │ DevOps          │    │ C-Level         │
          │           └────────┬────────┘    └────────┬────────┘
          │                    │                      │
          │                    ↓                      ↓
          │              ┌──────────┐           ┌──────────┐
          │              │Aprovado? │           │Aprovado? │
          │              └────┬─────┘           └────┬─────┘
          │                   │                      │
          │          ┌────────┴────┐        ┌────────┴────┐
          │          │             │        │             │
          │          ↓             ↓        ↓             ↓
          │        ┌───┐       ┌───────┐ ┌───┐       ┌───────┐
          │        │Sim│       │  Não  │ │Sim│       │  Não  │
          │        └─┬─┘       └───┬───┘ └─┬─┘       └───┬───┘
          │          │             │       │             │
          └──────────┴─────────────┘       └─────────────┘
                     │                                   │
                     ↓                                   ↓
           ┌──────────────────┐                  ┌────────────┐
           │ Deploy Automático│                  │ Cancelado  │
           └────────┬─────────┘                  └────────────┘
                    │
                    ↓
           ┌─────────────────┐
           │ Deploy Completo │
           └─────────────────┘
```

### Passo 4: Monitorar Execução

7. Acompanhe os stages em tempo real:
   - **Preparation** (10-30s)
   - **Deploy** (1-3 min)
   - **Smoke Test** (30s-2 min)
   - **Validate Version** (10s)
   - **Update Assets** (10s, apenas `master_15`)

### Passo 5: Validar Deploy

8. Acesse URL do ambiente: `https://brm-{env}.vivo.com`
9. Verifique versão: `https://brm-{env}.vivo.com/version`
10. Confirme health: `https://brm-{env}.vivo.com/health`

---

## ⚙️ Deploy Automático (CI/CD)

### Trigger por Branch

| Branch | Ambiente | Quando | Tipo |
|--------|----------|--------|------|
| `develop` | DEV | Automático (push) | Rolling |
| `release/*` | HML | Automático (push) | Rolling |
| `hotfix/*` | HML → PRE | Semi-automático | Rolling |
| `main` | PRD | Manual | Blue-Green |

### Configuração do Trigger

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - develop          # Auto-deploy to DEV
      - release/*        # Auto-deploy to HML
  paths:
    exclude:
      - docs/            # Ignore documentation changes
      - README.md

pr:
  branches:
    include:
      - main
      - develop
  paths:
    exclude:
      - docs/
```

### Fluxo CI/CD Completo

```
Developer  Git/Azure  CI Pipeline      ACR       CD Pipeline    OKE         Teams
    │          │            │            │            │           │            │
    │──push────>│            │            │            │           │            │
    │          │            │            │            │           │            │
    │          │──Trigger──>│            │            │           │            │
    │          │            │            │            │           │            │
    │          │            │──Files─────│            │           │            │
    │          │            │ (Source+  │            │           │            │
    │          │            │  Shared)   │            │           │            │
    │          │            │            │            │           │            │
    │          │            │──Maven─────│            │           │            │
    │          │            │  Build+Test│            │           │            │
    │          │            │            │            │           │            │
    │          │            │──SonarQube─│            │           │            │
    │          │            │  Analysis  │            │           │            │
    │          │            │            │            │           │            │
    │          │            │──Fortify───│            │           │            │
    │          │            │  Security  │            │           │            │
    │          │            │  Scan      │            │           │            │
    │          │            │            │            │           │            │
    │          │            │──Docker────>│            │           │            │
    │          │            │  Build&Push│            │           │            │
    │          │            │            │            │           │            │
    │          │            │<───────Image SHA        │           │            │
    │          │            │            │            │           │            │
    │          │            │──Trigger CD─────────────>│           │            │
    │          │            │            │            │           │            │
    │          │            │            │            │──Helm─────│            │
    │          │            │            │            │  Update   │            │
    │          │            │            │            │           │            │
    │          │            │            │            │──kubectl──>│            │
    │          │            │            │            │  apply    │            │
    │          │            │            │            │           │            │
    │          │            │            │            │           │──Rolling   │
    │          │            │            │            │           │  Update    │
    │          │            │            │            │           │            │
    │          │            │            │            │<──Status──│            │
    │          │            │            │            │           │            │
    │          │            │            │            │──Smoke────│            │
    │          │            │            │            │  Tests    │            │
    │          │            │            │            │           │            │
    │          │            │            │            │──Validate─│            │
    │          │            │            │            │  Version  │            │
    │          │            │            │            │           │            │
    │          │            │            │            │──Success──────────────>│
    │          │            │            │            │           │            │
    │<─────────────────────────────────────────────Notification──────────────│
    │          │            │            │            │           │            │
```

### Variáveis de Ambiente (Variable Groups)

#### `brm-fenix-global`
```yaml
DOCKER_REGISTRY: 'acrvivofenix.azurecr.io'
ACR_SERVICE_CONNECTION: 'acr-brm-fenix'
HELM_CHART_REPO: 'https://github.com/vivo/brm-helm-charts'
SONARQUBE_URL: 'https://sonar.vivo.com'
FORTIFY_URL: 'https://fortify.vivo.com'
```

#### `brm-fenix-dev`
```yaml
OCI_COMPARTMENT_ID: 'ocid1.compartment.oc1..xxx'
OKE_CLUSTER_ID: 'ocid1.cluster.oc1..xxx'
OKE_NODE_POOL_ID: 'ocid1.nodepool.oc1..xxx'
BASTION_HOST: '10.0.1.5'
NAMESPACE: 'brm-dev'
ENV_NAME_UPPER: 'DEV'
```

#### `brm-fenix-hml`
```yaml
OCI_COMPARTMENT_ID: 'ocid1.compartment.oc1..yyy'
OKE_CLUSTER_ID: 'ocid1.cluster.oc1..yyy'
OKE_NODE_POOL_ID: 'ocid1.nodepool.oc1..yyy'
BASTION_HOST: '10.0.2.5'
NAMESPACE: 'brm-hml'
ENV_NAME_UPPER: 'HML'
```

---

## 🏗️ Deploy de Infraestrutura (IaC)

### START Nodes (Ligar Ambiente)

**Quando usar:**
- Segunda-feira de manhã (após shutdown de fim de semana)
- Início de sprint
- Após manutenção programada

**Como executar:**

1. Acesse Pipeline: **BRM Fenix - IaC**
2. Clique em **Run pipeline**
3. Parâmetros:

```yaml
action: START
environment: DEV
numberAffectedNodes: 2  # Quantos nodes iniciar
```

4. Aguarde execução (15-20 min):
   - Cluster validation
   - Node pool validation
   - Start compute instances
   - Wait Kubernetes ready
   - Wait pods running
   - Wait jobs complete

**Output Esperado:**

```bash
✅ Cluster State: ACTIVE
✅ Node Pool State: ACTIVE
✅ Nodes Started: 2/2
✅ Pods Running: 15/15
✅ Jobs Completed: 3/3
```

### STOP Nodes (Desligar Ambiente)

**Quando usar:**
- Sexta-feira à noite (economia de custos)
- Fim de sprint
- Manutenção programada
- Ambiente DEV fora do horário comercial

**Como executar:**

1. Acesse Pipeline: **BRM Fenix - IaC**
2. Clique em **Run pipeline**
3. Parâmetros:

```yaml
action: STOP
environment: DEV
numberAffectedNodes: 2  # Quantos nodes parar
```

**⚠️ IMPORTANTE:** Verifique que não há deploys em andamento!

```bash
# Verificar se há pods de deploy/jobs em execução no namespace brm15-apps
kubectl get pods -n brm15-apps | grep -E 'deploy|job'
```

**Output Esperado:**

```bash
✅ No active deployments
✅ Nodes Stopped: 2/2
✅ Cluster State: ACTIVE (nodes stopped)
```

### Economia de Custos

| Ambiente | Nodes | Horas/Mês (24x7) | Horas/Mês (Shutdown) | Economia |
|----------|-------|------------------|----------------------|----------|
| DEV | 2 | 1440h | 480h (apenas dias úteis) | **67%** |
| HML | 3 | 2160h | 2160h (sempre ligado) | 0% |
| PRE | 3 | 2160h | 2160h (sempre ligado) | 0% |
| PRD | 5 | 3600h | 3600h (sempre ligado) | 0% |

**Economia Mensal Estimada (DEV):**
- Custo Node: $0.50/hora
- Economia: 960h × 2 nodes × $0.50 = **$960/mês**

---

## ⏪ Rollback Procedures

### Rollback Rápido (Helm)

**Quando usar:**
- Bug crítico detectado após deploy
- Falha em smoke tests
- Erro de configuração

**Tempo de Execução:** 2-5 minutos

#### Via Azure DevOps Pipeline

1. Acesse Pipeline: **BRM Fenix - Rollback**
2. Parâmetros:

```yaml
environment: PRD
rollbackToVersion: 1.2.2  # Versão anterior estável
```

#### Via Helm CLI (Manual)

```bash
# 1. Conectar ao Bastion
ssh -i ~/.ssh/brm_bastion.pem opc@10.0.4.5

# 2. Configurar kubectl
export KUBECONFIG=/home/opc/.kube/config-brm-prd

# 3. Verificar histórico de releases
helm history brm-prd -n brm-prd

# Output:
# REVISION  UPDATED                   STATUS      CHART        APP VERSION  DESCRIPTION
# 1         Mon Jan  1 10:00:00 2025  superseded  brm-1.2.0    1.2.0        Install complete
# 2         Mon Jan  8 14:30:00 2025  superseded  brm-1.2.1    1.2.1        Upgrade complete
# 3         Mon Jan 15 16:45:00 2025  deployed    brm-1.2.2    1.2.2        Upgrade complete

# 4. Rollback para revisão anterior
helm rollback brm-prd 2 -n brm-prd

# 5. Aguardar rollout
kubectl rollout status deployment/brm-gateway -n brm-prd

# 6. Validar versão
curl https://brm.vivo.com/version
```

### Rollback de Database (Schema)

**Quando usar:**
- Migration quebrou schema
- Dados corrompidos após deploy

**Tempo de Execução:** 10-30 minutos

#### Pré-requisitos

- Backup de database disponível
- Acesso ao DBA team
- Janela de manutenção aprovada

#### Procedimento

```bash
# 1. Parar aplicação
kubectl scale deployment/brm-dm -n brm-prd --replicas=0

# 2. DBA executa restore
# (via Oracle RMAN ou Data Pump)

# 3. Validar schema
sqlplus brm/password@brm_prd <<EOF
SELECT version FROM schema_version;
EXIT;
EOF

# 4. Restaurar aplicação
kubectl scale deployment/brm-dm -n brm-prd --replicas=3

# 5. Smoke test
curl https://brm.vivo.com/health/database
```

### Rollback de Infraestrutura (IaC)

**Quando usar:**
- Node pool upgrade falhou
- Cluster ficou instável
- Mudança de rede quebrou conectividade

**Tempo de Execução:** 30-60 minutos

```bash
# 1. Identificar node pool anterior
oci ce node-pool list \
  --compartment-id $OCI_COMPARTMENT_ID \
  --cluster-id $OKE_CLUSTER_ID

# 2. Recriar node pool com configuração anterior
oci ce node-pool create \
  --cluster-id $OKE_CLUSTER_ID \
  --name brm-prd-nodepool-v1 \
  --node-shape VM.Standard.E4.Flex \
  --node-image-id ocid1.image.oc1..xxx \
  --size 5

# 3. Migrar workloads (drain old nodes)
kubectl drain node-old-1 --ignore-daemonsets --delete-emptydir-data

# 4. Deletar node pool antigo
oci ce node-pool delete --node-pool-id $OLD_NODE_POOL_ID
```

---

## 🏥 Health Checks

### Application Health Endpoints

| Endpoint | Descrição | Expected Response | Timeout |
|----------|-----------|-------------------|---------|
| `/health` | Health geral da aplicação | `200 OK` | 5s |
| `/health/liveness` | Aplicação está viva (pod não deve ser killado) | `200 OK` | 3s |
| `/health/readiness` | Aplicação pronta para tráfego | `200 OK` | 5s |
| `/health/database` | Conexão com database OK | `200 OK` | 10s |
| `/version` | Versão deployada | `{"version": "1.2.3"}` | 2s |
| `/metrics` | Métricas Prometheus | `200 OK` | 5s |

### Kubernetes Health Checks

```yaml
# deployment.yaml
spec:
  containers:
    - name: brm-gateway
      livenessProbe:
        httpGet:
          path: /health/liveness
          port: 8080
        initialDelaySeconds: 30
        periodSeconds: 10
        timeoutSeconds: 3
        failureThreshold: 3
      
      readinessProbe:
        httpGet:
          path: /health/readiness
          port: 8080
        initialDelaySeconds: 10
        periodSeconds: 5
        timeoutSeconds: 5
        failureThreshold: 3
```

### Smoke Tests Pós-Deploy

```bash
#!/bin/bash
# smoke-test.sh

set -e

BASE_URL="https://brm-${ENV}.vivo.com"

echo "🧪 Executando Smoke Tests..."

# 1. Health Check
echo "✅ Health Check"
curl -f -s "$BASE_URL/health" | jq -e '.status == "UP"'

# 2. Database Connectivity
echo "✅ Database Check"
curl -f -s "$BASE_URL/health/database" | jq -e '.status == "UP"'

# 3. Version Validation
echo "✅ Version Check"
DEPLOYED_VERSION=$(curl -s "$BASE_URL/version" | jq -r '.version')
if [ "$DEPLOYED_VERSION" != "$EXPECTED_VERSION" ]; then
  echo "❌ Version mismatch: expected $EXPECTED_VERSION, got $DEPLOYED_VERSION"
  exit 1
fi

# 4. API Endpoint Test
echo "✅ API Test"
curl -f -s -H "Authorization: Bearer $TEST_TOKEN" \
  "$BASE_URL/api/v1/customers/test" | jq -e '.status == "success"'

# 5. Load Balancer Check
echo "✅ Load Balancer Check"
for i in {1..5}; do
  curl -f -s "$BASE_URL/health" > /dev/null
done

echo "✅ Smoke Tests Passed!"
```

---

## 🔍 Troubleshooting Deploy

### Deploy Falha em "Docker Build & Push"

**Sintoma:**
```
❌ Error: failed to solve: failed to push: unexpected status: 401 Unauthorized
```

**Causa:** Service Connection do ACR expirado

**Solução:**

```bash
# 1. Verificar Service Connection
az devops service-endpoint list \
  --query "[?name=='acr-brm-fenix']"

# 2. Renovar credenciais (Azure Portal)
# Azure Portal > Container Registry > Access Keys > Regenerate

# 3. Atualizar Service Connection
# Azure DevOps > Project Settings > Service Connections > acr-brm-fenix > Edit
```

### Pods em CrashLoopBackOff Após Deploy

**Sintoma:**
```bash
kubectl get pods -n brm-prd

# Output:
# NAME                           READY   STATUS             RESTARTS
# brm-gateway-7d8f5c9b4d-xk2m8   0/1     CrashLoopBackOff   5
```

**Diagnóstico:**

```bash
# 1. Ver logs do pod
kubectl logs brm-gateway-7d8f5c9b4d-xk2m8 -n brm-prd

# 2. Descrever pod (eventos recentes)
kubectl describe pod brm-gateway-7d8f5c9b4d-xk2m8 -n brm-prd

# 3. Verificar variáveis de ambiente
kubectl exec brm-gateway-7d8f5c9b4d-xk2m8 -n brm-prd -- env | grep -i db
```

**Soluções Comuns:**

| Erro nos Logs | Causa Provável | Solução |
|---------------|----------------|---------|
| `Connection refused` | Database indisponível | Verificar connectivity, credentials |
| `OOMKilled` | Memória insuficiente | Aumentar `resources.limits.memory` |
| `ImagePullBackOff` | Imagem não existe no ACR | Verificar tag da imagem |
| `ConfigMap not found` | ConfigMap não foi criado | Aplicar configmap antes do deployment |

### Health Check Failing

**Sintoma:**
```
❌ Smoke Test Failed: /health returned 503
```

**Diagnóstico:**

```bash
# 1. Testar health check diretamente
curl -v https://brm-prd.vivo.com/health

# 2. Verificar se pod está Ready
kubectl get pods -n brm-prd -l app=brm-gateway

# 3. Testar health check DENTRO do pod
kubectl exec -it brm-gateway-xxx -n brm-prd -- \
  curl localhost:8080/health
```

**Causas Comuns:**

- Database connection pool esgotado
- Dependência externa (API) indisponível
- Health check endpoint com bug
- Timeout muito curto

---

## 📊 Métricas de Deploy

### SLOs (Service Level Objectives)

| Métrica | Target | Atual | Status |
|---------|--------|-------|--------|
| **Deployment Frequency** | 10/semana | 12/semana | ✅ |
| **Lead Time for Changes** | <2 horas | 1.5 horas | ✅ |
| **Change Failure Rate** | <5% | 3% | ✅ |
| **Mean Time to Recovery** | <30 min | 25 min | ✅ |

### Tempo Médio por Stage

| Stage | DEV | HML | PRE | PRD |
|-------|-----|-----|-----|-----|
| Preparation | 10s | 10s | 15s | 20s |
| Deploy | 1 min | 2 min | 3 min | 5 min |
| Smoke Tests | 30s | 1 min | 2 min | 3 min |
| Validate Version | 10s | 10s | 15s | 20s |
| **Total** | **2 min** | **4 min** | **6 min** | **9 min** |

---

## 📚 Referências

- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Kubernetes Deployment Strategies](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Azure DevOps Pipelines](https://learn.microsoft.com/azure/devops/pipelines/)
- [OCI OKE Operations](https://docs.oracle.com/iaas/Content/ContEng/home.htm)

---

**Última Atualização:** 2 de Janeiro de 2026  
**Versão:** 1.1.0  
**Mantido por:** BRM Fenix DevOps Team
