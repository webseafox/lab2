# Deploy CD - WebLogic Universal (1 a N Ambientes)

> Template universal parametrizado de CD para deploy em WebLogic — suporta **1 a 6+ ambientes** dinâmicos para qualquer aplicação.

Exemplos de uso:
- 🟡 **CCIN**: plataforma-middleware-ccenterbusinessintegration (3 ambientes: BRN, CIC, NDC)
- 🔵 **ServiceAPI**: serviceapi-ura (6 ambientes: Móvel BRN/CIC/NDC + Fixa BRN/CIC/NDC)
- 🟢 **App simples**: Qualquer aplicação WebLogic (1, 2, 3, ou N ambientes)

---

## Visão Geral

**`deploy-weblogic.yml`** é um template universal que:

✅ **Suporta 1 a N ambientes** — Deploy em qualquer número de ambientes (1, 2, 3, 6, 10+)
✅ **Reutilizável** — Qualquer aplicação WebLogic pode usá-lo com apenas 2 parâmetros
✅ **WLST automation** — Undeploy + Clean Deploy + Validação
✅ **Rastreabilidade** — EventHub + VERSION.md
✅ **Simples** — Apenas Feed ID e Maven Package Name são parametrizados

## Parâmetros Obrigatórios

| Parâmetro | Descrição | Exemplo |
|-----------|-----------|---------|
| `artifactsFeedId` | UUID do Feed Azure Artifacts | `3d53bc62-8749-4931-ae46-a443b73bc87a` |
| `mavenPackageName` | GroupId:ArtifactId do pacote Maven | `br.com.vivo:ccenter-business-integration` |

**Nota:** Os scripts WLST estão localizados em caminho fixo: `/tech_products/ccin/pipelines/weblogic-scripts/`

## Como Obter os Parâmetros

### Feed ID (`artifactsFeedId`)

```bash
# Opção 1: Azure DevOps CLI
az artifacts universal list --feed <feed-name> --query "[0].id"

# Opção 2: Manualmente
# Vá em Azure DevOps > Artifacts > <Feed> > Connect to Feed
# Procure pelo UUID na URL ou no comando Maven
```

**URL Reference:**
```
https://pkgs.dev.azure.com/<org>/_packaging/<feed>/maven/v1/...
                                          ^^^^
                                      Feed Name (encontre o ID)
```

### Maven Package Name (`mavenPackageName`)

Do seu `pom.xml`:
```xml
<groupId>br.com.vivo</groupId>
<artifactId>ccenter-business-integration</artifactId>
```

Resultado: `br.com.vivo:ccenter-business-integration`

## Arquivos

| Arquivo | Tipo | Descrição |
|---|---|---|
| `deploy-weblogic.yml` | CD | Template universal de stages para deploy em N ambientes (jobs inline, sem template auxiliar) |
| `ci-maven-cd-weblogic-hml.yml` | CI/CD | Pipeline unificado para esteiras de homologação (legado) |
| `cd_prod.yml` | CD | Template legado hardcoded para produção BRN/CIC/NDC (depreciado) |
| `weblogic-scripts/*.py` | Scripts | Scripts WLST para undeploy e clean deploy |

## Como Usar

### 1. Pipeline Pai (em sua aplicação)

Arquivo: `.azuredevops/azure-pipeline-cd.yml`

**Exemplo 1 - App com 1 ambiente:**

```yaml
trigger: none

parameters:
  - name: packageVersion
    displayName: 'Versão do pacote'
    type: string

  - name: deployProduction
    displayName: 'Deploy em Produção'
    type: boolean
    default: false

resources:
  repositories:
    - repository: CodePlay
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: refs/heads/master
      endpoint: CodePlay

variables:
  - group: 'my-app-weblogic-vars'
  - name: APP
    value: my-app

extends:
  template: /tech_products/ccin/pipelines/middleware/deploy-weblogic.yml@CodePlay
  parameters:
    packageVersion: ${{ parameters.packageVersion }}
    environment: producao
    artifactsFeedId: '3d53bc62-8749-4931-ae46-a443b73bc87a'
    universalPackageName: 'my.org.my-app'
    environments:
      Production:
        sshEndpoint: 'SSH_WLS_MY_APP_PRD'
        wlstCluster: 'MY_APP_CLUSTER'
        adminServerUrl: 't3://admin-server:7001'
    deployFlags:
      Production: ${{ parameters.deployProduction }}
```

**Exemplo 2 - CCIN com 3 ambientes:**

```yaml
trigger: none

parameters:
  - name: packageVersion
    displayName: 'Versão do pacote para deploy'
    type: string

  - name: deployBRN
    displayName: 'Deploy no site BRN'
    type: boolean
    default: false

  - name: deployCIC
    displayName: 'Deploy no site CIC'
    type: boolean
    default: false

  - name: deployNDC
    displayName: 'Deploy no site NDC'
    type: boolean
    default: false

  - name: skipAtualizaVersionMd
    displayName: 'Pular atualização do VERSION.md'
    type: boolean
    default: false

resources:
  repositories:
    - repository: CodePlay
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      endpoint: CodePlay

variables:
  - group: 'ccin-weblogic-vars'  # APP, WEBLOGIC_*, SCRIPTS_TARGETFOLDER, ARTIFACT_TARGETFOLDER, etc

extends:
  template: /tech_products/ccin/pipelines/middleware/deploy-weblogic.yml@CodePlay
  parameters:
    packageVersion: ${{ parameters.packageVersion }}
    environment: producao
    skipAtualizaVersionMd: ${{ parameters.skipAtualizaVersionMd }}
    artifactsFeedId: '3d53bc62-8749-4931-ae46-a443b73bc87a'
    universalPackageName: 'ccenter.ccin.ccenter-business-integration'
    environments:
      BRN:
        sshEndpoint: 'SSH_WLS_WAS_ROTEAMENTO_BRN_PRD'
        wlstCluster: 'WLS_WAS_ROTEAMENTO_BRN_PRD_CLUSTER'
        adminServerUrl: '$(WEBLOGIC_ADMIN_SERVER_URL_BRN)'
      CIC:
        sshEndpoint: 'SSH_WLS_WAS_ROTEAMENTO_CIC_PRD'
        wlstCluster: 'WLS_WAS_ROTEAMENTO_CIC_PRD_CLUSTER'
        adminServerUrl: '$(WEBLOGIC_ADMIN_SERVER_URL_CIC)'
      NDC:
        sshEndpoint: 'SSH_WLS_WAS_ROTEAMENTO_NDC_PRD'
        wlstCluster: 'WLS_WAS_ROTEAMENTO_NDC_PRD_CLUSTER'
        adminServerUrl: '$(WEBLOGIC_ADMIN_SERVER_URL_NDC)'
    deployFlags:
      BRN: ${{ parameters.deployBRN }}
      CIC: ${{ parameters.deployCIC }}
      NDC: ${{ parameters.deployNDC }}
```

**ServiceAPI (6 ambientes):**

```yaml
# Similar, com 6 ambientes Móvel + Fixa
extends:
  template: /tech_products/ccin/pipelines/middleware/deploy-weblogic.yml@CodePlay
  parameters:
    packageVersion: ${{ parameters.packageVersion }}
    environments:
      MovelBRN:
        sshEndpoint: 'SSH_WLS_URA_MOVEL_BRN_PRD'
        wlstCluster: 'WLS_URA_MOVEL_BRN_CLUSTER'
      MovelCIC:
        sshEndpoint: 'SSH_WLS_URA_MOVEL_CIC_PRD'
        wlstCluster: 'WLS_URA_MOVEL_CIC_CLUSTER'
      # ... 4 mais
    deployFlags:
      MovelBRN: ${{ parameters.deployMovelBRN }}
      # ... etc
```

### 2. Variable Group

Criar grupo de variáveis (ex: `ccin-weblogic-vars`):

| Variável | Valor | Secret |
|----------|-------|--------|
| `APP` | Nome do WAR | ❌ |
| `FEED_PACKAGE` | Feed Azure Artifacts | ❌ |
| `WLST_SCRIPT` | Path do wrapper WLST | ❌ |
| `WEBLOGIC_USER` | Usuário admin | ✅ |
| `WEBLOGIC_PASS` | Senha admin | ✅ |
| `SCRIPTS_TARGETFOLDER` | Path scripts no servidor | ❌ |
| `ARTIFACT_TARGETFOLDER` | Path artefatos | ❌ |
| `WEBLOGIC_ADMIN_SERVER_URL_BRN` | URL admin BRN | ❌ |
| `WEBLOGIC_ADMIN_SERVER_URL_CIC` | URL admin CIC | ❌ |
| `WEBLOGIC_ADMIN_SERVER_URL_NDC` | URL admin NDC | ❌ |

### 3. Service Connections SSH

Configurar no Azure DevOps → Project Settings → Service Connections:

**CCIN:**
- `SSH_WLS_WAS_ROTEAMENTO_BRN_PRD`
- `SSH_WLS_WAS_ROTEAMENTO_CIC_PRD`
- `SSH_WLS_WAS_ROTEAMENTO_NDC_PRD`

**ServiceAPI:**
- `SSH_WLS_URA_MOVEL_BRN_PRD`, `SSH_WLS_URA_MOVEL_CIC_PRD`, `SSH_WLS_URA_MOVEL_NDC_PRD`
- `SSH_WLS_URA_FIXA_BRN_PRD`, `SSH_WLS_URA_FIXA_CIC_PRD`, `SSH_WLS_URA_FIXA_NDC_PRD`

### 4. Environments (Opcional - para approvals)

```
deploy-producao-brn
deploy-producao-cic
deploy-producao-ndc
deploy-producao-movelbrn
deploy-producao-movelcic
deploy-producao-movelndc
deploy-producao-fixabrn
deploy-producao-fixacic
deploy-producao-fixandc
```

## Fluxo de Execução

### 1️⃣ Pre-Deploy Validation

- ✓ Debug de parâmetros
- ✓ Checkout scripts WLST
- ✓ Transfer de scripts para cada servidor via SCP
- ✓ Permissões de execução (chmod 775)
- ✓ Validação de conectividade SSH

### 2️⃣ Deploy (um stage por ambiente)

Para cada ambiente habilitado, em paralelo:

1. **Download** do WAR de Azure Artifacts
2. **Transfer** via SCP para servidor
3. **UndeployApp.py** — Remove versão anterior
4. **CleanDeployApp.py** — Deploy limpo
5. **ValidateDeployment.py** — Validação

### 3️⃣ Final Audit

- **EventHub registration** — Auditoria de deployment
- **VERSION.md update** — Documentação automática no git

## Exemplos de Execução

**CCIN - Deploy em BRN apenas:**

1. Clique "Run pipeline"
2. `packageVersion`: 1.2.3
3. `deployBRN`: ✅ true
4. `deployCIC`: ❌ false
5. `deployNDC`: ❌ false
6. Clique "Run"

**ServiceAPI - Deploy paralelo em todos Móvel:**

1. `packageVersion`: 2.5.0
2. `deployMovelBRN`: ✅ true
3. `deployMovelCIC`: ✅ true
4. `deployMovelNDC`: ✅ true
5. `deployFixaBRN`: ❌ false
6. ... (resto false)

## Parâmetros do Template

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `packageVersion` | string | *(obrigatório)* Versão do WAR |
| `environment` | string | Ambiente: `producao` ou `dev` |
| `environments` | object | Mapa de ambientes (SSH endpoint + cluster) |
| `deployFlags` | object | Booleanos de cada ambiente |
| `skipAtualizaVersionMd` | boolean | Pular VERSION.md update |

## 🔐 Segurança

✅ **Secret Masking**: Variáveis `WEBLOGIC_PASS` marcadas como SECRET no variable group — Azure DevOps mascara nos logs

✅ **SSH Keys**: Credenciais armazenadas no Azure DevOps Service Connections, não em scripts

✅ **Credenciais via arquivo temporário**: Scripts WLST leem usuário/senha de arquivo temporário criado no servidor com permissão `600` e removido após uso. Não são passadas como argumentos CLI diretos.

✅ **Validação em Camadas**: Pre-deploy SSH check → Deploy WLST → Post-deploy validation

## 🐛 Troubleshooting

### ❌ "SSH Connection refused"
- Validar Service Connection
- Testar: `ssh-keyscan -t rsa <hostname>`

### ❌ "UndeployApp.py not found"
- Validar SCRIPTS_TARGETFOLDER
- Verificar CopyFilesOverSSH foi executado

### ❌ "Health check failed"
- Validar WAR foi deployado: `ls -l $(ARTIFACT_TARGETFOLDER)`
- Verificar logs: `/opt/web/logs/application.log`

## 📞 Suporte

Contate a comunidade DevOps:
- Canal DevEx - Teams (conforme [CONTRIBUTING.md](../../../CONTRIBUTING.md))

---

**Última atualização:** 2026-08-14
**Templates:** `deploy-weblogic.yml`
**Mantido por:** CCIN Middleware / CodePlay Framework Team
