# CD Templates - Deploy e Configuração

Templates de Continuous Deployment que encapsulam lógica reutilizável para deploy via ArgoCD, configuração de recursos e sincronização GitOps.

## 🎯 Descrição

O diretório `cd` contém **3 templates modulares** focados em operações de **deploy, sincronização GitOps e configuração de recursos**:

- **`cd-deploy-only-argo.yml`**: Stage completa de deploy via ArgoCD com rollback detection e approval para produção
- **`cd-argocd-scripts-appv.yml`**: Operações GitOps (checkout, generate manifests, commit com retry, sync ArgoCD)
- **`app-resources-hpa-config-cd.yml`**: Validação e merge dinâmico de recursos (CPU/memória) e HPA

Todos os templates seguem o padrão **template-based** do Azure DevOps, permitindo **composição limpa** em estágios de CD.

## 🏗️ Matriz de Capacidades

| Capacidade | Suporte | Descrição |
|------------|---------|-----------|
| Deploy Automatizado | ✅ | Deploy via ArgoCD configurável |
| Rollback Automático | ✅ | Detecção e rollback com aprovação em prod |
| Configuração de Recursos | ✅ | Validação e merge de CPU/memória/HPA |
| GitOps Sync | ✅ | Sincronização automática com repositório |
| Segurança em Produção | ✅ | Aprovação manual obrigatória para rollback |
| Health Checks | ⚠️ | Verificação básica de commit |

**Legenda:**
- ✅ Suportado nativamente
- ⚠️ Suportado com limitações

---

## 📋 Templates Detalhados

### 🚀 `cd-deploy-only-argo.yml`

**Tipo**: Stage completa de CD
**Propósito**: Deploy e rollback via ArgoCD com validação, aprovação manual para prod e sincronização automática

**Quando Usar**:
- Deploy de aplicações em ambientes Kubernetes via ArgoCD
- Quando precisa detectar rollback e pedir aprovação em produção
- Deploy-only (sem executar build antes)
- Deploy com build automático (CI depende desta stage)

**Responsabilidades**:
- 🔐 Setup de credenciais Helm/Docker (depende de `environment_init`)
- 🏗️ Dependency management (CI, CD checklist, environment init)
- ⚠️ Detecção inteligente de rollback
- 👥 Aprovação manual obrigatória para rollback em produção
- 🗺️ Remapeamento de environment names (`esteira01` → `esteira1`)
- 📊 Checkout de manifests GitOps
- 🐳 Deploy via ArgoCD com helm/kubectl
- 🔄 Sincronização ArgoCD
- ✅ Verificação de saúde pós-deploy
- ⏹️ Rollback capabilities

**Estágio Definido**:
- **Nome**: `cd_deploy`
- **DisplayName**: `CD - Deploy | Rollback (Argo)`
- **Pool**: `GeneralPurposeLinuxAgentsCD`

**Dependências do Stage**:

Executadas em paralelo (speedup):
- Obrigatória: `environment_init` (setup de credenciais)
- Condicional (se não deployOnly):
  - `ci_build` - Build stage da CI
  - `ci_package` (se `nativeBuild: false`)
  - `ci_package_native` (se `nativeBuild: true`)
- Condicional (se não ms/tools namespaces): `cd_environment_checklist`

#### Parâmetros de Entrada

| Parâmetro | Tipo | Default | Descrição | Dependências |
|-----------|------|---------|-----------|--------------|
| `setEnvironment` | string | - | Nome do ambiente-alvo (dev, staging, prod, prod-front, prod-bff, esteira01, esteira02, etc). Usado para localizar credenciais e repositórios corretos | environment_init stage |
| `setVersion` | string | `" "` (espaço) | Versão específica para deploy. Deixar vazio (`""` ou `" "`) para auto-detectar versão do CI. Usado no tag de imagem Docker e release notes | ci_build stage (quando não especificado) |
| `deployOnly` | boolean | - | `true` = pula execução da CI e usa apenas artifacts anterior. `false` = executa CI completo antes de deploy | ci_build, ci_package stages |
| `nativeBuild` | boolean | false | `true` = usa stage ci_package_native (GraalVM compilation). `false` = usa ci_package (normal JVM). Afeta qual imagem Docker será utilizada | ci_package ou ci_package_native stages |
| `forceSync` | boolean | false | `true` = força sincronização ArgoCD mesmo sem alterações detectadas. Útil para replicar estado desejado | argo-cd cluster |
| `setProduction` | boolean | false | `true` = ativa validações reforçadas para produção (aprovação manual, verificações adicionais). Recomendado para prod-* environments | security validations |
| `resourcesAndHpaValues` | object | - | Configuração de recursos K8s e AutoScaling (CPU limits/requests, memória, HPA min/max replicas, target CPU/memory utilization). Estrutura: `{ resources: { limits: { cpu, memory }, requests: { cpu, memory } }, hpa: { minReplicas, maxReplicas, targetCPUUtilizationPercentage, targetMemoryUtilizationPercentage } }` | Kubernetes cluster, HPA controller |

**Jobs Definidos**:

#### Job 1: `waitForValidation` (pool: server)

Implementa aprovação manual para rollback em produção.

- ⏳ **Timeout Máximo**: 3 dias
- 👥 **Aprovação Timeout**: 1 dia (máximo tempo espera)
- 🎯 **Condição**: Somente se `IS_ROLLBACK=true` E ambiente contém `prod`
- 📧 **Notificadores**: Múltiplos stakeholders (times DevOps, arquitetura, suporte)
- ⏹️ **Ação Timeout**: `reject` (aborta deploy)
- ⏭️ **Skip**: Se não é rollback ou não é produção

Conteúdo da notificação:
- Tipo de mudança (rollback detectado)
- Ambiente-alvo
- Versão em cluster vs versão novo
- Link para HTML report com detalhes

#### Job 2: `deploy` (deployment)

Executa deploy propriamente dito.

- 🎯 **Depende de**: `waitForValidation`
- 📋 **Environment**: 
  - Produção: `DEPLOY_ENVIRONMENT_PROD`
  - Não-prod: `DEPLOY_ENVIRONMENT_LIB`
- 🎭 **Strategy**: `runOnce` (sem retry automático)
- 🚫 **Bloqueia Reruns**: Rejeita tentativa de rerun (força nova execução)

**Verificações**:

1. **Verify Version**
   - ✅ Versão não pode ser vazia
   - 🔍 Valida fonte (CI auto ou parâmetro manual)
   - ❌ Falha se vazio

2. **Block Reruns**
   - ⛔ `System.JobAttempt != 1` falha
   - Força nova execução ao invés de retry

3. **Remap Environment**
   - Transforma `esteira01` → `esteira1`
   - Output: `REMAPPED_ENVIRONMENT`

4. **GitOps Checkout Condicional**
   - **Se produção** (`prod*`, `darklaunch*`):
     - Checkout: `infra.infra-devops-aks-prod@master`
   - **Se não-prod**:
     - Checkout: `infra.infra-devops-aks-preprod@master`

**Fluxo de Rollback**:

```
Deploy com setVersion='1.0.0'
    ↓
Cluster tem '1.1.0' (versão > deploy)
    ↓ ROLLBACK DETECTADO
Ambiente contém 'prod'?
    ├─→ Sim: Job waitForValidation
    │    ├─ Notifica 5+ stakeholders
    │    ├─ Aguarda 1 dia máximo
    │    └─ Precisa aprovação unânime
    │       ├→ Aprovado: Deploy/Rollback continua
    │       └→ Rejected/Timeout: ABORTA
    └─→ Não (dev/staging): Auto continua
    ↓
Deploy/Rollback Executa
```

**Variáveis Automáticas Disponíveis**:

| Variável | Origem | Descrição |
|----------|--------|-----------|
| `setVersion` | CI ou parâmetro | Versão a deploiar |
| `NEXUS_DEFAULT_USR/PSW` | environment_init | Credenciais repositório |
| `IS_ROLLBACK` | cd_environment_checklist | true se detectado rollback |
| `PROD_VERSION` | cd_environment_checklist | Versão atualmente em cluster |

**Inclusão no Pipeline**:

```yaml
stages:
- template: /tech_products/appv/global/initialize/deploy-environment_prod.yml

- template: /tech_products/appv/global/templates/cd/cd-deploy-only-argo.yml
  parameters:
    setEnvironment: 'prod'
    setVersion: ''          # Auto-detect da CI
    deployOnly: false       # Executa build antes
    setProduction: true     # Validações reforçadas prod
    resourcesAndHpaValues:
      resources:
        limits:
          cpu: '2'
          memory: '2Gi'
        requests:
          cpu: '1'
          memory: '1Gi'
      hpa:
        minReplicas: 3
        maxReplicas: 15
        targetCPUUtilizationPercentage: 75
        targetMemoryUtilizationPercentage: 85
```

---

### 🔄 `cd-argocd-scripts-appv.yml`

**Tipo**: Template de steps (não é uma stage)
**Propósito**: Sincroniza repositório GitOps com manifests do cluster, com retry automático e verificação

**Quando Usar**:
- Dentro de um deployment job
- Após checkout de manifests do GitOps
- Quando precisa sincronizar aplicações ArgoCD com repositório de GitOps
- Para manter GitOps repository sempre atualizado com estado real do cluster

**Responsabilidades**:
- 🔐 Checkout do repositório GitOps (prod ou preprod conforme environment)
- 🔑 Download seguro de kubeconfig
- 🏷️ Remapeamento de environment names (namespace remapping)
- 📄 Geração de manifests do cluster via `helm get manifest`
- 💾 Commit e push para GitOps repo com retry automático (3 tentativas)
- 🔀 Detecção e recusa de merge conflicts
- ✅ Verificação de commit no repositório remoto

#### Parâmetros de Entrada

| Parâmetro | Tipo | Descrição | Dependências |
|-----------|------|-----------|--------------|
| `environment` | string | Ambiente-alvo de deployment (dev, staging, prod, darklaunch, etc). Determina qual repositório GitOps será utilizado (prod ou preprod). Usado em remap de namespaces e seleção de kubeconfig. | infra.infra-devops-aks-prod ou infra.infra-devops-aks-preprod, kubeconf-{environment}.yml |
| `applicationName` | string | Nome da aplicação a ser sincronizada no ArgoCD. Usado em caminhos GitOps, edição de ArgoCD Application e busca de manifests no cluster. Deve corresponder ao ApplicationName criado no ArgoCD. | ArgoCD Application resource, GitOps repository structure |

**Lógica de Checkout Infraestrutura**:

Seleciona repositório baseado em `environment`:

```
if environment contém 'prod' ou 'darklaunch':
  checkout: infra.infra-devops-aks-prod@master
else:
  checkout: infra.infra-devops-aks-preprod@master
```

**Steps Executados** (sequencial):

#### 1. **Checkout Infraestrutura**
- Seleciona repo (prod ou preprod)
- Persiste credenciais para push futuro
- Branch: `master`

#### 2. **Download Kube Config**
- Task: `AzureKeyVault` + `DownloadSecureFile`
- Arquivo: `kubeconf-{environment}.yml`
- Segurança: Não aparece em logs (secure file)

#### 3. **Remap Environment**
- Transforma `esteira01` → `esteira1` (namespace mapping específico)
- Bash script
- Output: `REMAPPED_ENVIRONMENT` variable

#### 4. **Edit ArgoCD Application**
- Executa: `scripts/edit_argo_application.sh`
- Ação: Desabilita AutoSync (`AUTO_SYNC: false`)
- Env vars passadas:
  - `ARGO_USERNAME`: Credencial
  - `ARGO_PASSWORD`: Credencial
  - `ENVIRONMENT`: Environment remapeado
  - `ARGO_URL`: URL do servidor ArgoCD
  - `APPLICATION_NAME`: Nome da app
  - `AUTO_SYNC`: Sempre `false`

#### 5. **Generate Manifests**
- Comando: `helm get manifest {app} -n {environment}`
- Output: `src/{environment}/apps/{app}/manifests.yaml`
- Prepara para commit no GitOps repo

#### 6. **GitOps Commit com Retry**

Estratégia robusta com retry automático:

- **Max Attempts**: 3
- **Retry Delay**: 5 segundos entre tentativas
- **Git Flow**:
  1. `git add .`
  2. Se sem mudanças: Pula commit, retorna sucesso
  3. `git commit -m "..."`
  4. Loop retry:
     - `git pull --rebase origin master`
     - Detecta merge conflicts (rejeita se houver)
     - `git push origin HEAD:master`
     - Se sucesso: Break
     - Se falha: Wait e retry

- **Outputs**:
  - `COMMIT_PUSHED`: `true` se push bem-sucedido
  - `LAST_COMMIT_HASH`: Hash do commit propagado
  - `NO_CHANGES`: `true` se sem mudanças

#### 7. **Verify Commit Status**

Valida que commit foi realmente propagado:

- Compara hash local vs remoto (`git ls-remote`)
- Skipa se `NO_CHANGES=true`
- Output: `COMMIT_VERIFIED`

**Variáveis de Saída** (referenciáveis por outros steps):

| Step | Variável | Descrição |
|------|----------|-----------|
| `remap_env` | `REMAPPED_ENVIRONMENT` | Environment remapeado |
| `gitops_commit` | `COMMIT_PUSHED` | true = push bem-sucedido |
| `gitops_commit` | `LAST_COMMIT_HASH` | Hash do commit |
| `gitops_commit` | `NO_CHANGES` | true = sem mudanças detectadas |
| `verify_commit` | `COMMIT_VERIFIED` | true = commit verificado remoto |

**Inclusão no Pipeline**:

```yaml
jobs:
- deployment: deploy
  steps:
  - template: /tech_products/appv/global/templates/cd/cd-argocd-scripts-appv.yml
    parameters:
      environment: 'staging'
      applicationName: 'my-app'
  
  - task: Bash@3
    displayName: "Log GitOps Status"
    inputs:
      script: |
        echo "Commit hash: $(gitops_commit.LAST_COMMIT_HASH)"
        echo "Verified: $(verify_commit.COMMIT_VERIFIED)"
```

**Tratamento de Erros**:

| Erro | Causa | Resolução |
|------|-------|-----------|
| **Merge Conflict Detectado** | Múltiplas pipelines em paralelo | Reexecuta pipeline após manual fix |
| **Kubeconfig não encontrado** | Secret file não no Key Vault | Adicionar arquivo: `kubeconf-{env}.yml` |
| **Push falha 3x** | Rede ou acesso repositório | Verificar conectividade + permissões |
| **Commit não verificado** | Remoto fora de sync | Validar sincronização com `master` |

---

### 📐 `app-resources-hpa-config-cd.yml`

**Tipo**: Template de steps (não é uma stage)
**Propósito**: Valida, extrai e mescla (merge) configurações de recursos (CPU/memória) e HPA dinâmicamente

**Quando Usar**:
- Dentro de um deployment job
- Após checkout de manifests do GitOps
- Quando precisa validar ou atualizar configurações de recursos
- Implementar política "parâmetros override arquivo"

**Responsabilidades**:
- 📥 Pull manifests do repositório GitOps
- ✅ Valida parâmetros de recursos e HPA para formato correto
- 🔀 Merge inteligente de valores (prioridade: parâmetros > arquivo)
- 🏷️ Extração com `yq` de Deployment e HPA
- 🧮 Lógica: `unchanged` = mantém arquivo, senão usa parâmetro
- ✅ Validação final de todos os valores antes output

#### Parâmetros de Entrada

| Parâmetro | Tipo | Descrição | Dependências |
|-----------|------|-----------|--------------|
| `setEnvironment` | string | Ambiente-alvo utilizado em condições e validações de recursos. Deve ser do mesmo ambiente utilizado em cd-deploy-only-argo.yml para consistência. Usado para definir paths de manifestos e validações. | cd-deploy-only-argo.yml (coordenação), Kubernetes cluster com recursos suficientes |
| `resourcesAndHpaValues` | object | Objeto contendo configuração de recursos Kubernetes (CPU/memória) e HorizontalPodAutoscaler (min/max replicas, targets). Estrutura: { resources: { limits, requests }, hpa: { minReplicas, maxReplicas, targetCPUUtilizationPercentage, targetMemoryUtilizationPercentage } }. Valores podem ser "unchanged" para não aplicar override. | Kubernetes Metrics Server, HPA controller, yq CLI utility |

**Estrutura do Parâmetro `resourcesAndHpaValues`**:

```yaml
resourcesAndHpaValues:
  resources:
    requests:
      cpu: "500m"                # ou "unchanged"
      memory: "512Mi"            # ou "unchanged"
    limits:
      cpu: "1"                   # ou "unchanged"
      memory: "1Gi"              # ou "unchanged"
  hpa:
    minReplicas: 2               # ou "unchanged"
    maxReplicas: 10              # ou "unchanged"
    targetCPUUtilizationPercentage: 80         # ou "unchanged"
    targetMemoryUtilizationPercentage: 85      # ou "unchanged"
```

**Valores Válidos**:

- ✅ Números/strings: `"512Mi"`, `"1"`, `"500m"`, `80`
- ✅ Palavra-chave: `"unchanged"` (mantém valor do arquivo)
- ❌ Nunca: String vazia `""` (valida e falha)

**Steps Executados** (sequencial):

#### 1. **Pull Manifests from GitOps Repository**

Localiza arquivo de manifests no workspace GitOps:

- Path: `$(Pipeline.Workspace)/gitops/src/{environment}/apps/{app}/manifests.yaml`
- Exporta como variável: `MANIFESTS_FILE`
- Logs: Mostra conteúdo completo (debug)

#### 2. **Validate Params for Empty Strings**

Valida que nenhum parâmetro é string vazia:

```
Para cada parâmetro:
  if value == "":
    log error
    fail=true
if fail:
  exit 1
```

Garante que YAML foi parseado corretamente.

#### 3. **Extract and Merge Resource and HPA Values**

Lógica principal de merge:

1. Separa arquivo multi-document com `yq`:
   - Deployment → arquivo temp
   - HPA → arquivo temp

2. Extrai valores do arquivo (com defaults vazios):
   ```yaml
   FILE_CPU_REQ: .spec.template.spec.containers[0].resources.requests.cpu
   FILE_MEM_REQ: .spec.template.spec.containers[0].resources.requests.memory
   # ... etc
   ```

3. Merge logic por valor:
   ```
   Para cada item:
     FINAL = FILE_value
     if PARAM != "unchanged" AND PARAM não vazio:
       FINAL = PARAM
   ```

4. Exporta como output variables (isOutput=true):
   ```
   FINAL_CPU_REQ, FINAL_MEM_REQ, FINAL_CPU_LIM, FINAL_MEM_LIM
   FINAL_HPA_MIN, FINAL_HPA_MAX, FINAL_HPA_CPU_TARGET, FINAL_HPA_MEM_TARGET
   ```

5. Logs: Debug mostra comparação (param vs file vs final)

#### 4. **Validate Resource and HPA Values**

Valida formatos finais:

- **CPU**: Regex `^[0-9]+(\.[0-9]+)?(m)?$`
  - Válido: `500`, `500m`, `1`, `1.5`, `1.5m`
  - Inválido: `1Gi`, `mem`, vazios

- **Memory**: Regex similar
  - Válido: `512`, `512Mi`, `1Gi`
  - Inválido: `1m`, `1cpu`

- **HPA**: Números inteiros positivos
  - Válido: `1`, `5`, `100`
  - Inválido: `0`, `-1`, `1.5`

**Variáveis de Saída** (do step `merge_values`):

Referenciáveis como `$[ merge_values.FINAL_CPU_REQ ]`:

| Variável | Descrição |
|----------|-----------|
| `FINAL_CPU_REQ` | CPU solicitada (requests) |
| `FINAL_MEM_REQ` | Memória solicitada (requests) |
| `FINAL_CPU_LIM` | CPU limite (limits) |
| `FINAL_MEM_LIM` | Memória limite (limits) |
| `FINAL_HPA_MIN` | HPA mínimo de replicas |
| `FINAL_HPA_MAX` | HPA máximo de replicas |
| `FINAL_HPA_CPU_TARGET` | HPA target CPU utilization % |
| `FINAL_HPA_MEM_TARGET` | HPA target memória utilization % |

**Inclusão no Pipeline**:

```yaml
jobs:
- deployment: deploy
  steps:
  - template: /tech_products/appv/global/templates/cd/app-resources-hpa-config-cd.yml
    parameters:
      setEnvironment: 'staging'
      resourcesAndHpaValues:
        resources:
          limits:
            cpu: '2'
            memory: '2Gi'
          requests:
            cpu: '1'
            memory: '1Gi'
        hpa:
          minReplicas: 3
          maxReplicas: 15
          targetCPUUtilizationPercentage: 75
          targetMemoryUtilizationPercentage: 'unchanged'

  - task: Bash@3
    displayName: "Apply Merged Values with Helm"
    inputs:
      script: |
        helm upgrade my-app mychart \
          --set resources.requests.cpu=$[ merge_values.FINAL_CPU_REQ ] \
          --set resources.limits.memory=$[ merge_values.FINAL_MEM_LIM ] \
          --set autoscaling.minReplicas=$[ merge_values.FINAL_HPA_MIN ]
```

---

## 🚀 Quick Start - Exemplos Completos

### Exemplo 1: Deploy Completo com Rollback em Prod

```yaml
stages:
- template: /tech_products/appv/global/initialize/deploy-environment_prod.yml

- template: /tech_products/appv/global/templates/cd/cd-deploy-only-argo.yml
  parameters:
    setEnvironment: 'prod'
    setVersion: ''              # Auto-detect da CI
    deployOnly: false           # Executa build antes
    setProduction: true         # Habilita aprovação rollback
    resourcesAndHpaValues:
      resources:
        limits:
          cpu: '2'
          memory: '2Gi'
        requests:
          cpu: '1'
          memory: '1Gi'
      hpa:
        minReplicas: 3
        maxReplicas: 15
        targetCPUUtilizationPercentage: 75
        targetMemoryUtilizationPercentage: 85
```

### Exemplo 2: Deploy-Only (Sem Build)

```yaml
stages:
- template: /tech_products/appv/global/initialize/deploy-environment_prod.yml

- template: /tech_products/appv/global/templates/cd/cd-deploy-only-argo.yml
  parameters:
    setEnvironment: 'prod'
    setVersion: '2.1.0'         # Versão já existente
    deployOnly: true            # Pula CI completamente
    setProduction: true
```

### Exemplo 3: Atualizar Recursos em Dev (Sem HPA)

```yaml
stages:
- template: /tech_products/appv/global/initialize/deploy-environment.yml

- stage: deploy
  displayName: "Deploy to Dev"
  jobs:
  - deployment: deploy
    steps:
    - template: /tech_products/appv/global/templates/cd/app-resources-hpa-config-cd.yml
      parameters:
        setEnvironment: 'dev'
        resourcesAndHpaValues:
          resources:
            limits:
              cpu: '1'
              memory: 'unchanged'     # Mantém valor atual do arquivo
            requests:
              cpu: '250m'
              memory: 'unchanged'
          hpa:
            minReplicas: unchanged    # Mantém tudo
            maxReplicas: unchanged
            targetCPUUtilizationPercentage: unchanged
            targetMemoryUtilizationPercentage: unchanged

    - task: Bash@3
      displayName: "Apply com Helm"
      inputs:
        script: |
          helm upgrade my-app mychart \
            --set resources.requests.cpu=$[ merge_values.FINAL_CPU_REQ ]
```

### Exemplo 4: GitOps Sync Completo

```yaml
- stage: deploy
  displayName: "Sync GitOps"
  jobs:
  - deployment: deploy
    steps:
    - template: /tech_products/appv/global/templates/cd/cd-argocd-scripts-appv.yml
      parameters:
        environment: 'staging'
        applicationName: 'my-microservice'
    
    - task: Bash@3
      displayName: "Verify and Report"
      inputs:
        script: |
          echo "GitOps Status:"
          echo "  Commit: $(gitops_commit.LAST_COMMIT_HASH)"
          echo "  Pushed: $(gitops_commit.COMMIT_PUSHED)"
          echo "  Verified: $(verify_commit.COMMIT_VERIFIED)"
          
          if [ "$(verify_commit.COMMIT_VERIFIED)" != "true" ]; then
            echo "##vso[task.logissue type=warning]Commit não verificado no remoto"
          fi
```

## 📝 Decisões Tomadas

### Decisão 1: Retry Automático em GitOps Commit

- **Data**: 2026-06-24
- **Motivador**: Falhas intermitentes de push em repositório GitOps durante picos de concorrência
- **Forum Envolvido**: Equipe DevOps AppV
- **Descrição**: Implementação de retry automático com 3 tentativas e delay de 5 segundos. Detecta merge conflicts e rejeita se houver. Garante consistência entre cluster e repositório.

### Decisão 2: Aprovação Obrigatória em Rollback de Produção

- **Data**: 2026-06-24
- **Motivador**: Necessidade de controle rigoroso em produção para evitar downtime não autorizado
- **Forum Envolvido**: Arquitetura, Segurança, DevOps
- **Descrição**: Rollback automático detectado por comparação de versões. Em ambiente de produção, job waitForValidation aguarda aprovação manual de 5+ stakeholders. Timeout de 1 dia. Se rejeitado/timeout: deploy aborta.

---

## 🔐 Credenciais e Segurança

### Recuperadas Automaticamente

| Credencial | Template | Vault | Uso |
|-----------|----------|-------|-----|
| `HELM-REGISTRY-*` | `app-resources-hpa-config` | DevOpsSharedResources | Acesso Helm |
| `DOCKER-REGISTRY-*` | `app-resources-hpa-config` | DevOpsSharedResources | Acesso Docker |
| `kubeconf-{env}.yml` | `cd-argocd-scripts` | SecureFiles | Autenticação K8s |
| `ARGO_USERNAME/PASSWORD/URL` | `cd-argocd-scripts` | Pipeline Variables | ArgoCD API |

### Boas Práticas

- ✅ Secrets marcados como `isSecret: true`
- ✅ Kubeconfig não aparece em logs
- ✅ Credenciais apenas em jobs autorizados
- ✅ Variáveis privadas não exported

---

## 🆘 Suporte

- [Abra um chamado para Dev Support](https://dvps.redecorp.azr/portal/codeplay/roteiro/#:~:text=Abra%20um%20chamado%20para%20Dev%20Support)
- [Canal DevEx - Azure DevOps](https://teams.microsoft.com/l/channel/19%3A8fbd00946cf044d7a844182ac71e6aa1%40thread.tacv2/Azure%20DevOps?groupId=038b4415-d6dd-42ce-92e5-31a8e2a13bf8&tenantId=9744600e-3e04-492e-baa1-25ec245c6f10)

---

**Última atualização**: 2026-06-24
