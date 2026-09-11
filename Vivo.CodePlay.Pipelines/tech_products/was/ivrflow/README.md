# WAS - IVR Flow (Fluxos URA)

> Templates de CI/CD para fluxos de URA — arquivos XML convertidos em JSON e deployados nos servidores de IVR do Contact Center.

---

## Visão Geral

O **IVR Flow** gerencia o ciclo de vida dos fluxos de URA (Unidade de Resposta Audível). Diferente dos módulos de middleware WAR, aqui o artefato são **arquivos JSON** gerados a partir de XMLs de configuração de fluxo. O módulo possui o pipeline mais complexo da vertical, com validação de fluxos, geração automática de pacotes de deploy/rollback via PR, e suporte a build de todos os fluxos.

## Arquivos

| Arquivo                 | Tipo    | Descrição                                                                             |
|--------------------------|---------|----------------------------------------------------------------------------------------|
| `ci-cd-hml.yml`          | CI/CD   | Template unificado (uso via `extends`) — Validate + Build + Deploy hml, ou Build & Deploy All quando disparo manual |
| `cd-prod.yml`            | CD PRD  | Deploy/rollback de fluxos JSON em produção                                            |
| `generate-packages.yml`  | PR      | Geração automática de pacotes deploy + rollback via PR                                |

> `ci.yml`, `cd.yml` e `builddeployall.yml` foram removidos — o conteúdo dos três foi unificado em `ci-cd-hml.yml`.

## Pipelines Pai (PIPES PAIS)

| Pipeline Pai                       | Template(s)             |
|------------------------------------|-------------------------|
| `WAS/IVRFLOW/build-deploy-hml.yml` | `ci-cd-hml.yml` (via `extends`) |
| `WAS/IVRFLOW/pr-genpack.yml`       | `generate-packages.yml` |
| `WAS/IVRFLOW/release-prod.yml`     | `cd-prod.yml`           |

---

## CI/CD Homologação (`ci-cd-hml.yml`)

Template unificado (uso via **`extends`**), que substitui os antigos `ci.yml` + `cd.yml` + `builddeployall.yml`. A escolha do fluxo é feita internamente com base em `Build.Reason`:

- `Build.Reason == 'Manual'` → roda o fluxo **Build & Deploy All**.
- Qualquer outro motivo (push, etc.) → roda o fluxo normal **CI (Validate + Build) + CD (Deploy hml)**.

### Uso no repositório consumidor

```yaml
resources:
  repositories:
    - repository: CodePlay
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: refs/heads/<branch>

extends:
  template: tech_products/was/ivrflow/ci-cd-hml.yml@CodePlay
```

### Fluxo Normal (push / disparo automático)

| Propriedade   | Valor                                                                   |
|---------------|---------------------------------------------------------------------------|
| **Pool**      | `GeneralPurposeLinuxAgentsCI` (CI) / `GeneralPurposeLinuxAgentsCD` (CD) |
| **Stages**    | `Validate` → `Build` → `security_scan` → `Deploy`                      |
| **Validação** | `flow-validator.jar` (baixado do Artifacts)                             |
| **Build**     | `flow-generator.jar` — converte XMLs alterados em JSONs                |
| **Deploy**    | Download artifact JSON → `CopyFilesOverSSH@0`                          |

1. **Validate**:
   - Checkout + download `flow-validator.jar`
   - Identifica arquivos alterados no commit (`git diff-tree`)
   - Download via `sshpass` do servidor de URA: lista de áudios, ScriptPoint, transaction-config, XSD
   - Executa validação dos fluxos
2. **Build**:
   - Download `flow-generator.jar`
   - Gera JSONs a partir dos XMLs alterados
   - Publica JSONs como artifact
3. **security_scan**: Fortify + SCA sobre o artifact `json` (jobs `AppSecConfigKeys`, `run_fortify`, `RunSCA`)
4. **Deploy**:
   - Download artifact `json`
   - Copia JSONs para `/opt/web/applications/ccenter/ura_movel/fluxos/$(SCP_DEST)`
   - Registra deploy no Event Hub

### Fluxo Manual — Build & Deploy All (`Build.Reason == 'Manual'`)

Builda e deploya **TODOS** os fluxos do repositório (não apenas os alterados no commit).

| Propriedade   | Valor                                            |
|---------------|-----------------------------------------------------|
| **Stages**    | `Build_Deploy_All` → `security_scan` → `Deploy`  |
| **Aprovação** | `ManualValidation@0` com timeout de 30 minutos   |

1. Aguarda aprovação manual ("Deseja realizar o build e deploy de TODOS os fluxos?")
2. Build: gera JSONs de **todos** os XMLs do repositório
3. security_scan: Fortify + SCA sobre o artifact `json`
4. Deploy: copia **todos** os JSONs para o servidor, substituindo o diretório inteiro (`cleanTargetFolder: true`)

### Variáveis Obrigatórias (Library)

| Variável                | Descrição                                  |
|-------------------------|--------------------------------------------|
| `SCP_DEST`              | Diretório destino no servidor remoto       |
| `ESTEIRA`               | Identificador da esteira/branch            |
| `IP`                    | IP do servidor de URA                      |
| `AUD_DIR`               | Diretório de áudios remoto                 |
| `SCRIPT_POINT_FILE_DIR` | Caminho do ScriptPoint JSON remoto         |
| `TRANSACTION_FILE_DIR`  | Caminho do `transaction-config.xml` remoto |
| `TRANSACTION_XSD`       | Caminho do XSD remoto                      |
| `FILES_DIR`             | Diretório de trabalho local                |
| `SSH_QA_USER`           | Usuário SSH do servidor de URA             |
| `SSH_QA_PASS`           | Senha SSH (secreta)                        |
| `SERVICE_CONNECTION`    | Service Connection SSH do ambiente         |

### Secure Files

- `md5-controller.properties`

---

## CD Produção (`cd-prod.yml`)

| Propriedade  | Valor                                                                    |
|--------------|--------------------------------------------------------------------------|
| **Pool**     | `GeneralPurposeLinuxAgentsCD`                                            |
| **Stages**   | `Deploy` (com `environment: deploy-producao`)                            |
| **Método**   | Download pacote do Artifacts → Copia JSONs via SSH                       |
| **Rollback** | Suporta flag `isRollback` — baixa pacote `<FEED_PACKAGE>.<chg>-rollback` |

### Parâmetros

| Parâmetro     | Tipo    | Default    | Descrição                                       |
|---------------|---------|------------|-------------------------------------------------|
| `chg`         | string  | —          | Número da CHG (Change Request)                  |
| `isRollback`  | boolean | `false`    | Se `true`, baixa e deploya o pacote de rollback |
| `environment` | string  | `producao` | Ambiente de destino                             |

### Fluxo de Execução

1. Debug: exibe configuração do deploy
2. Download pacote do Artifacts:
   - Deploy: `$(FEED_PACKAGE).$(chg)`
   - Rollback: `$(FEED_PACKAGE).$(chg)-rollback`
3. Copia JSONs para `$(PROD_DIR)` via SSH

### Variáveis Obrigatórias

| Variável       | Descrição                          |
|----------------|------------------------------------|
| `SSH`          | Service Connection SSH de produção |
| `PROD_DIR`     | Diretório de fluxos em produção    |
| `FEED_PACKAGE` | Nome base do pacote no Artifacts   |

---

## Geração de Pacotes (`generate-packages.yml`)

Pipeline executado automaticamente em **Pull Requests** (target = `master`). Gera dois pacotes no Azure Artifacts:

| Propriedade | Valor                                                                                            |
|-------------|----------------------------------------------------------------------------------------------------|
| **Pool**    | `GeneralPurposeLinuxAgentsCI`                                                                    |
| **Stages**  | `DiffAnalysis` → `GenerateDeployPackage` → `security_scan` → `GenerateRollbackPackage`          |
| **Trigger** | Pull Request para `master`                                                                       |

### Fluxo de 6 Passos + Security Scan

| Step | Descrição                                                  | Método                                                            |
|------|--------------------------------------------------------------|---------------------------------------------------------------------|
| 1    | Análise do diff entre branches (somente `.xml`)            | `git diff`                                                        |
| 2    | Lista arquivos XML alterados → converte nomes para `.json` | Script                                                            |
| 3    | Download dos JSONs da **esteira** (HML)                    | SCP via `sshpass`                                                 |
| 4    | Publica pacote de **deploy**                               | `UniversalPackages` como `$(FEED_PACKAGE).$(CHG_NUMBER)`          |
| —    | **Security Scan** (Fortify + SCA) sobre o pacote de deploy | Templates `/security/*.yml` (mesmos do `ci-cd-hml.yml`)            |
| 5    | Download dos JSONs de **produção**                         | SCP via `sshpass`                                                 |
| 6    | Publica pacote de **rollback**                             | `UniversalPackages` como `$(FEED_PACKAGE).$(CHG_NUMBER)-rollback` |

> O stage `security_scan` depende de `GenerateDeployPackage` e bloqueia `GenerateRollbackPackage` — segue o mesmo padrão (jobs `AppSecConfigKeys`, `run_fortify` e `RunSCA`) usado em `ci-cd-hml.yml`.

### Variáveis Obrigatórias

| Variável                                  | Descrição                        |
|-------------------------------------------|----------------------------------|
| `CHG_NUMBER`                              | Número da CHG                    |
| `ESTEIRA`                                 | Identificador da esteira         |
| `FEED_PACKAGE`                            | Nome base do pacote              |
| `FILES_DIR`                               | Diretório de trabalho local      |
| `SSH_QA_USER` / `SSH_QA_PASS`             | Credenciais SSH da esteira       |
| `IP_ESTEIRA`                              | IP do servidor da esteira        |
| `HML_DIR`                                 | Diretório dos fluxos na esteira  |
| `SSH_SYNCPROD_USER` / `SSH_SYNCPROD_PASS` | Credenciais SSH de produção      |
| `IP_SYNCPROD`                             | IP do servidor de produção       |
| `PROD_DIR`                                | Diretório dos fluxos em produção |

---

*Last updated: Agosto 2026*
