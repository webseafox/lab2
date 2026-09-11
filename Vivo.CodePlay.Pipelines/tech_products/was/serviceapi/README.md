# WAS - ServiceAPI (Middleware URA Móvel/Fixa)

> Template de CD Produção para a aplicação **service-api** — middleware Java WAR deployado no WebLogic em 6 sites (Móvel/Fixa × BRN/CIC/NDC).

---

## Visão Geral

O **ServiceAPI** é um middleware Java WAR que **reutiliza os pipelines CI e CD de homologação do [CCIN](../../ccin/pipelines/middleware/README.md)**, pois o fluxo de build Maven + deploy via SSH é idêntico. O único pipeline próprio é o **CD de Produção**, necessário porque o deploy endereça **6 sites diferentes** — combinação de URA Móvel e URA Fixa em 3 datacenters (BRN, CIC, NDC).

## Arquivos

| Arquivo       | Tipo   | Descrição                                        |
|---------------|--------|--------------------------------------------------|
| `cd_prod.yml` | CD PRD | Deploy em produção multi-site (6 sites) via WLST |

> **CI e CD HML**: Utiliza os templates `ci.yml` e `cd.yml` do [CCIN Middleware](../../ccin/pipelines/middleware/README.md).

## Pipelines Pai (PIPES PAIS)

| Pipeline Pai                         | Template(s)                     |
|--------------------------------------|---------------------------------|
| `WAS/SERVICEAPI/azure-pipelines.yml` | CCIN `ci.yml` + CCIN `cd.yml`   |
| `WAS/SERVICEAPI/release-prod.yml`    | `cd_prod.yml` (deste diretório) |

---

## CD Produção (`cd_prod.yml`)

| Propriedade | Valor                                                                 |
|-------------|-----------------------------------------------------------------------|
| **Pool**    | `GeneralPurposeLinuxAgentsCD`                                         |
| **Stages**  | `Deploy` (com `environment: deploy-producao`)                         |
| **Método**  | Download Artifacts + WLST scripts (Undeploy → CleanDeploy → Validate) |
| **Sites**   | 6 — URA Móvel BRN/CIC/NDC + URA Fixa BRN/CIC/NDC                      |

### Parâmetros

| Parâmetro        | Tipo    | Default    | Descrição                    |
|------------------|---------|------------|------------------------------|
| `packageVersion` | string  | —          | Versão do pacote para deploy |
| `environment`    | string  | `producao` | Ambiente de destino          |
| `deployMovelBRN` | boolean | `false`    | Deploy URA Móvel Barueri     |
| `deployMovelCIC` | boolean | `false`    | Deploy URA Móvel Cícero      |
| `deployMovelNDC` | boolean | `false`    | Deploy URA Móvel Niterói/DC  |
| `deployFixaBRN`  | boolean | `false`    | Deploy URA Fixa Barueri      |
| `deployFixaCIC`  | boolean | `false`    | Deploy URA Fixa Cícero       |
| `deployFixaNDC`  | boolean | `false`    | Deploy URA Fixa Niterói/DC   |

### Fluxo de Execução

```
preDeploy:
  1. Debug variáveis (12 variáveis de URLs, 6 flags de deploy)
  2. Testa conexão SSH para os 6 sites (Móvel + Fixa × BRN/CIC/NDC)
  3. Checkout CodePlay (scripts WLST de tech_products/ccin/pipelines/weblogic-scripts)
  4. Copia scripts WLST para servidores selecionados
  5. Permissões nos scripts (chmod 775)

deploy:
  1. Checkout self (para VERSION.md)
  2. Download pacote do Artifacts
  3. Para cada site selecionado (até 6):
     a. Copia WAR via SSH
     b. UndeployApp.py
     c. CleanDeployApp.py
     d. ValidateDeployment.py
  4. Atualiza VERSION.md (marca como deployada)
  5. Commit + push + sincroniza branches

on:success → Mensagem de sucesso
on:failure → Mensagem de erro
```

### Service Connections SSH (6 sites)

| Tipo  | Site | Service Connection              |
|-------|------|---------------------------------|
| Móvel | BRN  | `SSH_WLS_WAS_URA_MOVEL_BRN_PRD` |
| Móvel | CIC  | `SSH_WLS_WAS_URA_MOVEL_CIC_PRD` |
| Móvel | NDC  | `SSH_WLS_WAS_URA_MOVEL_NDC_PRD` |
| Fixa  | BRN  | `SSH_WLS_WAS_URA_FIXA_BRN_PRD`  |
| Fixa  | CIC  | `SSH_WLS_WAS_URA_FIXA_CIC_PRD`  |
| Fixa  | NDC  | `SSH_WLS_WAS_URA_FIXA_NDC_PRD`  |

### Variáveis Obrigatórias (Library `cred-prod`)

| Variável                              | Descrição                              |
|---------------------------------------|----------------------------------------|
| `FEED_PACKAGE`                        | Nome do pacote no Azure Artifacts      |
| `APP`                                 | Nome da aplicação WebLogic             |
| `WLST_SCRIPT`                         | Caminho do executável WLST no servidor |
| `WEBLOGIC_USER`                       | Usuário WebLogic                       |
| `WEBLOGIC_PASS`                       | Senha WebLogic (secreta)               |
| `SCRIPTS_TARGETFOLDER`                | Pasta destino dos scripts WLST         |
| `ARTIFACT_TARGETFOLDER`               | Pasta destino do WAR                   |
| `WEBLOGIC_ADMIN_SERVER_URL_MOVEL_BRN` | URL AdminServer URA Móvel BRN          |
| `WEBLOGIC_ADMIN_SERVER_URL_MOVEL_CIC` | URL AdminServer URA Móvel CIC          |
| `WEBLOGIC_ADMIN_SERVER_URL_MOVEL_NDC` | URL AdminServer URA Móvel NDC          |
| `WEBLOGIC_ADMIN_SERVER_URL_FIXA_BRN`  | URL AdminServer URA Fixa BRN           |
| `WEBLOGIC_ADMIN_SERVER_URL_FIXA_CIC`  | URL AdminServer URA Fixa CIC           |
| `WEBLOGIC_ADMIN_SERVER_URL_FIXA_NDC`  | URL AdminServer URA Fixa NDC           |

### Scripts WLST utilizados

Scripts compartilhados em `tech_products/ccin/pipelines/weblogic-scripts/`, copiados durante o `preDeploy`:

| Script                  | Função                                       |
|-------------------------|----------------------------------------------|
| `CleanDeployApp.py`     | Deploy limpo (remove antigo + deploy novo)   |
| `UndeployApp.py`        | Remove a aplicação do cluster                |
| `ValidateDeployment.py` | Valida se o deploy foi realizado com sucesso |

---

## Variable Groups

| Variable Group                | Usada em               |
|-------------------------------|------------------------|
| `azdo-team-project-variables` | CI + CD HML (via CCIN) |
| `cred-prod`                   | CD Produção            |

---

*Last updated: Fevereiro 2026*
