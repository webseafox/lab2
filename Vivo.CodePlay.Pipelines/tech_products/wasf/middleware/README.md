# WASF - Middleware (Administration / Ferramentas)

> Template de CD Produção para a aplicação **ccenter-administration-integration** — middleware Java WAR deployado no WebLogic em 3 sites Ferramentas (BRN/CIC/NDC).

---

## Visão Geral

O **WASF Middleware** é um middleware Java WAR que **reutiliza os pipelines CI e CD de homologação do [CCIN](../../ccin/pipelines/middleware/README.md)**, pois o fluxo de build Maven + deploy via SSH é idêntico. O único pipeline próprio é o **CD de Produção**, necessário porque o deploy endereça sites **Ferramentas** (BRN/CIC/NDC) ao invés de Roteamento (BRN/CIC/NDC) do CCIN.

### Particularidade: HotDeploy no CIC

O site **Ferramentas CIC** utiliza uma estratégia de deploy diferente dos demais:
- **BRN e NDC**: `UndeployApp.py` → `CleanDeployApp.py` (deploy limpo com restart)
- **CIC**: `UndeployAppRetired.py` → `HotDeployApp.py` → `UndeployAppRetired.py` (deploy a quente sem restart)

Isso é intencional e necessário devido a restrições operacionais no cluster CIC.

## Arquivos

| Arquivo       | Tipo   | Descrição                                                        |
|---------------|--------|------------------------------------------------------------------|
| `cd_prod.yml` | CD PRD | Deploy em produção multi-site Ferramentas (BRN/CIC/NDC) via WLST |

> **CI e CD HML**: Utiliza os templates `ci.yml` e `cd.yml` do [CCIN Middleware](../../ccin/pipelines/middleware/README.md).

## Pipelines Pai (PIPES PAIS)

| Pipeline Pai                          | Template(s)                     |
|---------------------------------------|---------------------------------|
| `WASF/MIDDLEWARE/azure-pipelines.yml` | CCIN `ci.yml` + CCIN `cd.yml`   |
| `WASF/MIDDLEWARE/release-prod.yml`    | `cd_prod.yml` (deste diretório) |

---

## CD Produção (`cd_prod.yml`)

| Propriedade | Valor                                         |
|-------------|-----------------------------------------------|
| **Pool**    | `GeneralPurposeLinuxAgentsCD`                 |
| **Stages**  | `Deploy` (com `environment: deploy-producao`) |
| **Método**  | Download Artifacts + WLST scripts             |
| **Sites**   | 3 — Ferramentas BRN, CIC, NDC                 |

### Parâmetros

| Parâmetro              | Tipo    | Default    | Descrição                     |
|------------------------|---------|------------|-------------------------------|
| `packageVersion`       | string  | —          | Versão do pacote para deploy  |
| `environment`          | string  | `producao` | Ambiente de destino           |
| `deployFerramentasBRN` | boolean | `false`    | Deploy Ferramentas Barueri    |
| `deployFerramentasCIC` | boolean | `false`    | Deploy Ferramentas Cícero     |
| `deployFerramentasNDC` | boolean | `false`    | Deploy Ferramentas Niterói/DC |

### Fluxo de Execução

```
preDeploy:
  1. Debug variáveis
  2. Testa conexão SSH para os 3 sites (Ferramentas BRN/CIC/NDC)
  3. Checkout CodePlay (scripts WLST de tech_products/ccin/pipelines/weblogic-scripts)
  4. Copia scripts WLST para servidores selecionados
  5. Permissões nos scripts (chmod 775)

deploy:
  1. Checkout self (para VERSION.md)
  2. Download pacote do Artifacts
  3. Para BRN e NDC (CleanDeploy):
     a. Copia WAR via SSH
     b. UndeployApp.py
     c. CleanDeployApp.py
     d. ValidateDeployment.py
  4. Para CIC (HotDeploy):
     a. Copia WAR via SSH
     b. UndeployAppRetired.py (limpa versões em estado "retired")
     c. HotDeployApp.py (deploy a quente)
     d. UndeployAppRetired.py (limpa versão anterior)
     e. ValidateDeployment.py
  5. Atualiza VERSION.md (marca como deployada)
  6. Commit + push + sincroniza branches

on:success → Mensagem de sucesso
on:failure → Mensagem de erro
```

### Service Connections SSH

| Site            | Service Connection                |
|-----------------|-----------------------------------|
| Ferramentas BRN | `SSH_WLS_WAS_FERRAMENTAS_BRN_PRD` |
| Ferramentas CIC | `SSH_WLS_WAS_FERRAMENTAS_CIC_PRD` |
| Ferramentas NDC | `SSH_WLS_WAS_FERRAMENTAS_NDC_PRD` |

### Variáveis Obrigatórias (Library `cred-prod`)

| Variável                                    | Descrição                                                             |
|---------------------------------------------|-----------------------------------------------------------------------|
| `FEED_PACKAGE`                              | Nome do pacote no Azure Artifacts                                     |
| `APP`                                       | Nome da aplicação WebLogic (ex: `ccenter-administration-integration`) |
| `WLST_SCRIPT`                               | Caminho do executável WLST no servidor                                |
| `WEBLOGIC_USER`                             | Usuário WebLogic                                                      |
| `WEBLOGIC_PASS`                             | Senha WebLogic (secreta)                                              |
| `SCRIPTS_TARGETFOLDER`                      | Pasta destino dos scripts WLST                                        |
| `ARTIFACT_TARGETFOLDER`                     | Pasta destino do WAR                                                  |
| `WEBLOGIC_ADMIN_SERVER_URL_FERRAMENTAS_BRN` | URL AdminServer Ferramentas BRN                                       |
| `WEBLOGIC_ADMIN_SERVER_URL_FERRAMENTAS_CIC` | URL AdminServer Ferramentas CIC                                       |
| `WEBLOGIC_ADMIN_SERVER_URL_FERRAMENTAS_NDC` | URL AdminServer Ferramentas NDC                                       |

### Scripts WLST utilizados

Scripts compartilhados em `tech_products/ccin/pipelines/weblogic-scripts/`, copiados durante o `preDeploy`:

| Script                  | Usado em | Função                                       |
|-------------------------|----------|----------------------------------------------|
| `CleanDeployApp.py`     | BRN, NDC | Deploy limpo (remove antigo + deploy novo)   |
| `HotDeployApp.py`       | CIC      | Deploy a quente (sem restart)                |
| `UndeployApp.py`        | BRN, NDC | Remove a aplicação do cluster                |
| `UndeployAppRetired.py` | CIC      | Remove aplicações em estado "retired"        |
| `ValidateDeployment.py` | Todos    | Valida se o deploy foi realizado com sucesso |

---

## Variable Groups

| Variable Group                | Usada em               |
|-------------------------------|------------------------|
| `azdo-team-project-variables` | CI + CD HML (via CCIN) |
| `cred-prod`                   | CD Produção            |

---

*Last updated: Fevereiro 2026*
