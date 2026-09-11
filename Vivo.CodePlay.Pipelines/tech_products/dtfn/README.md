Pipelines DTFN — Referência Técnica

> Este documento cobre **o que cada pipeline faz** (stages, parâmetros, artefatos, pré-requisitos).

## Sumário

| Template (CodePlay)              | Wrapper no repo do produto      | Propósito                                                     |
|-----------------------------------|----------------------------------|----------------------------------------------------------------|
| `tech_products/dtfn/ci-pipeline.yaml`       | `app-dtfn-ci.yml`             | Exporta Jobs/Notebooks do workspace DEV como artefatos          |
| `tech_products/dtfn/cd-pipeline.yaml`       | `app-dtfn-cd.yml`             | Promove os artefatos da CI para QA e depois para PROD           |
| `tech_products/dtfn/rollback-pipeline.yaml` | `app-dtfn-rollback-qa.yml`    | Restaura Jobs/Notebooks de QA a partir do snapshot da CD        |
| `tech_products/dtfn/rollback-pipeline.yaml` | `app-dtfn-rollback-prod.yml`  | Restaura Jobs/Notebooks de PROD a partir do snapshot da CD      |

Os três templates compartilham a mesma stage `SecurityAnalysis` (Fortify SAST + SCA via `/security/*.yml@CodePlay`), reaproveitando a governança padrão do CodePlay. `rollback-pipeline.yaml` é ambiente-agnóstico — um único template atendido por dois wrappers (QA e PROD), no mesmo padrão que `cd-pipeline.yaml` já usa para tratar QA e PROD dentro de uma única pipeline.

---

## 1. CI — `ci-pipeline.yaml`

**Trigger:** `none` (disparo manual). **Wrapper:** `app-dtfn-ci.yml`.

### Parâmetros

| Nome | Tipo | Default | Descrição |
|---|---|---|---|
| `agentPoolCI` | string | `GeneralPurposeLinuxAgentsCI` | Pool de agentes para segurança e exportação |
| `fortifyExclusionRepository` | string | `FortifyExclusion` | Alias do repositório de exclusões do Fortify |
| `enableFortifyExclusions` | boolean | `true` | Usa exclusões do Fortify |
| `convisoCompany` | number | `430` | Conviso Company ID |
| `vivoFlow` | string | `DTFN_Preprod` | Fluxo Vivo para AppSec |
| `scriptsPath` | string | `scripts/ci-cd` | Diretório dos scripts de CI/CD no repositório do produto |

### Stages

**`SecurityAnalysis`**
- `AppSecConfigKeys` — busca flags de segurança (`get_appconfig_keys_framework.yml@CodePlay`).
- `FortifyScan` — condicional a `USE_FORTIFY`; `run_fortify_scan.yml`.
- `PrepareSCAArtifact` — checkout + publica código-fonte como artefato `app`.
- `SCAScan` — condicional a `USE_DEPENDENCY_TRACK`; `run_sca_scan.yml@CodePlay`.

**`CI`** (`dependsOn: SecurityAnalysis`, `condition: succeeded()`)
- Job `ExportacaoJobseVivoeNotebooks`:
  1. `ci-validaconexao_dev.py` — valida conexão com o Databricks DEV.
  2. `ci-exportarjobs_dev_v1.py` — exporta e formata Jobs de DEV.
  3. Publica artefato `DatabricksJobs` (pasta `jobs/`).
  4. Publica artefato `DatabricksNotebooks` (pasta `databricks/`).

### Pré-requisitos / Variáveis

- **Não declara Variable Group.** `$(dev_token)` e `$(dev_url)` precisam estar configurados como *Variables* da própria pipeline no Azure DevOps (aba Variables), fora do YAML.
- Scripts usados: `ci-validaconexao_dev.py`, `ci-exportarjobs_dev_v1.py` (em `scripts/ci-cd/`).

---

## 2. CD — `cd-pipeline.yaml`

**Trigger:** `none`. **Wrapper:** `app-dtfn-cd.yml`. Consome os artefatos `DatabricksJobs`/`DatabricksNotebooks` publicados pela CI via `resources.pipelines` (alias `ciPipelineAlias`, fonte configurada no wrapper como `Pipeline CI - [Databricks Dev] V4.0`). Os notebooks de PROD são lidos do repositório `comp-dtfn-prod` via `resources.repositories` (alias `prodRepoAlias`), declarado no arquivo raiz do repositório do produto.

> **Pré-requisito:** o arquivo raiz do repositório do produto (o wrapper `app-dtfn-cd.yml`) precisa declarar o `resources.repositories` com o mesmo alias usado em `prodRepoAlias` (default `prodRepo`), por exemplo:
> ```yaml
> resources:
>   repositories:
>     - repository: prodRepo
>       type: git
>       name: comp-dtfn-prod
>       ref: refs/heads/DTFN_Prod
> ```
> Sem essa declaração (ou com um alias diferente), o step `checkout: ${{ parameters.prodRepoAlias }}` das stages `Backup_Prod` falha.

### Parâmetros

| Nome | Tipo | Default | Descrição |
|---|---|---|---|
| `agentPoolCI` / `agentPoolCD` | string | `GeneralPurposeLinuxAgentsCI` / `...CD` | Pools de análise/backup/plan e de deploy |
| `ciPipelineAlias` | string | `ciPipeline` | Alias do `resources.pipelines` no arquivo raiz |
| `prodRepoAlias` | string | `prodRepo` | Alias do `resources.repositories` do repositório de notebooks de PROD (`comp-dtfn-prod`), declarado no arquivo raiz |
| `runSecurityAnalysis` / `runBackupQa` / `runPlanQa` / `runQA` / `runBackupProd` / `runPlanProd` / `runProd` | boolean | `true` (todos) | Controle de fluxo — substituto do "Stages to run" nativo, indisponível com `extends` de template de outro repositório. Ver [Controle de Fluxo](#controle-de-fluxo) |
| `variableGroupQa` | string | `vg-dtfn-cd-qa` | Variable Group de QA (Backup_QA, Plan_QA e Deploy QA) |
| `variableGroupProdBackup` | string | `vg-dtfn-cd-prod-backup` | Variable Group do backup de PROD |
| `variableGroupProdPlan` | string | `vg-dtfn-cd-prod-plan` | Variable Group da stage de Plan em PROD (gate próprio) |
| `variableGroupProdApply` | string | `vg-dtfn-cd-prod-apply` | Variable Group do job de Apply em PROD (gate próprio) |
| `fortifyExclusionRepository` / `enableFortifyExclusions` / `convisoCompany` / `vivoFlow` | — | (mesmos defaults da CI) | Segurança |
| `qaBranch` | string | `DTFN_Qa` | Branch de notebooks em QA |
| `prodBranch` | string | `DTFN_Prod` | Branch de notebooks em PROD |
| `qaRepoId` | string | `2051188230664694` | Repo ID do Databricks Repos em QA |
| `prodRepoId` | string | `4073870711034147` | Repo ID do Databricks Repos em PROD |
| `keyVaultProdServiceConnection` / `keyVaultProdName` | string | `sc-adf-dtfn-brsouth-prod` / `kv-dtfn-brsouth-001-prod` | Key Vault de PROD |
| `keyVaultQaServiceConnection` / `keyVaultQaName` | string | `sc-adf-dtfn-brsouth-test` / `kv-dtfn-brsouth-001-e1` | Key Vault de QA |
| `scriptsPath` | string | `scripts/ci-cd` | Diretório dos scripts |
| `mappingsPath` | string | `config/job-mappings` | Diretório dos manifestos de mapeamento DEV→ambiente |

#### Controle de Fluxo

Cada stage sempre existe no YAML compilado (evita quebrar `dependsOn` de stages seguintes); desmarcar o parâmetro correspondente só faz a stage terminar como `Skipped` em vez de `Succeeded`. As stages seguintes já aceitam `Skipped` como suficiente para continuar, exceto onde a stage anterior escreve algo do qual a próxima depende de fato (ex.: `QA` exige `Backup_QA` = `Succeeded`, não apenas `Skipped`; `PROD` exige `Backup_Prod` = `Succeeded`).

**Matriz de condições por stage** (o que cada stage exige das suas dependências para não ser bloqueada):

| Stage | `dependsOn` | Resultado aceito das dependências |
|---|---|---|
| `Backup_QA` | `SecurityAnalysis` | `Succeeded`, `SucceededWithIssues` ou `Skipped` |
| `Plan_QA` | `Backup_QA` | `Succeeded`, `SucceededWithIssues` ou `Skipped` |
| `QA` | `Backup_QA`, `Plan_QA` | `Backup_QA` **precisa** ser `Succeeded`; `Plan_QA` aceita `Succeeded` ou `Skipped` |
| `Backup_Prod` | `QA` | `Succeeded` ou `Skipped` |
| `Plan_Prod` | `Backup_Prod` | `Succeeded`, `SucceededWithIssues` ou `Skipped` |
| `PROD` | `QA`, `Backup_Prod`, `Plan_Prod` | `QA` aceita `Succeeded`/`Skipped`; `Backup_Prod` **precisa** ser `Succeeded`; `Plan_Prod` aceita `Succeeded`/`Skipped` |

Ou seja: só é seguro pular uma stage de `Backup` se a stage de deploy correspondente também for pulada (`Backup_QA=false` sem `runQA=false` deixa `QA` bloqueada, pois exige `Backup_QA=Succeeded`; o mesmo vale para `Backup_Prod` e `PROD`).

**Exemplo prático:** rodar somente as duas stages de Plan (revisar o diff entre CI e QA/PROD) sem tocar em nenhum ambiente:

```yaml
runSecurityAnalysis: true
runBackupQa: true      # Plan_QA depende do backup ter rodado
runPlanQa: true
runQA: false            # pula o deploy em QA
runBackupProd: true     # Plan_Prod depende do backup ter rodado
runPlanProd: true
runProd: false           # pula o apply em PROD
```

Resultado: `SecurityAnalysis`, `Backup_QA`, `Plan_QA`, `Backup_Prod` e `Plan_Prod` executam normalmente (`Succeeded`); `QA` e `PROD` terminam como `Skipped`, sem nenhuma escrita nos ambientes.

### Stages (ordem de execução)

**`SecurityAnalysis`** (`condition: runSecurityAnalysis`) — igual à CI.

**`Backup_QA`** (`condition: runBackupQa` + `SecurityAnalysis` em `Succeeded`/`SucceededWithIssues`/`Skipped`; `variables: variableGroupQa`)
- Job `ExportacaoJobseVivoeNotebooks`: `backup_qa.py` → publica `DatabricksJobsQA`; checkout da branch `qaBranch` → publica `DatabricksNotebooksQA`.

**`Plan_QA`** (`dependsOn: Backup_QA`; `condition: runPlanQa` + `Backup_QA` em `Succeeded`/`SucceededWithIssues`/`Skipped`; somente leitura; `variables: variableGroupQa`)
- Job `PlanQA`:
  1. `download` de `DatabricksJobs`/`DatabricksNotebooks` (da CI).
  2. `cd-planambiente_sp_qa_v1.py` — visão geral de diferenças (jobs + notebooks) entre o artefato da CI e o estado real de QA.

**`QA`** (`dependsOn: [Backup_QA, Plan_QA]`; `condition: runQA` + `Backup_QA` em `Succeeded` + `Plan_QA` em `Succeeded`/`Skipped`; `variables: variableGroupQa`)
- Job `DeployQA`:
  1. Limpa artefatos residuais do agente (`Bash@3`, escopo restrito a `DatabricksJobs`/`DatabricksNotebooks`).
  2. `download` de `DatabricksJobs`/`DatabricksNotebooks` (da CI).
  3. Key Vault: `token-databricks` (Key Vault de QA).
  4. `test-implantajobs-temp_sp_qa_v2.py` — cria job `TEMP_` em QA, aguarda, deleta.
  5. `cd-importarjobs_sp_qa_v10_cluster.py --mode apply`.
  6. `cd-clonarepo_qa_v3.py` (env `SYSTEM_ACCESSTOKEN`, `TARGET_BRANCH=qaBranch`).
  7. Script inline: `PATCH /api/2.0/repos/{qaRepoId}` para apontar o Databricks Repos para a branch `qaBranch`.

**`Backup_Prod`** (`condition: runBackupProd` + `QA` em `Succeeded`/`Skipped`; `variables: variableGroupProdBackup`)
- Job `ExportacaoJobseVivoeNotebooks`: checkout `self` → `backup_prod.py` → publica `DatabricksJobsPROD`; checkout do `prodRepoAlias` (repositório `comp-dtfn-prod`) → publica `DatabricksNotebooksPROD`.

**`Plan_Prod`** (`dependsOn: Backup_Prod`; `condition: runPlanProd` + `Backup_Prod` em `Succeeded`/`SucceededWithIssues`/`Skipped`; somente leitura; `variables: variableGroupProdPlan`)
- Job `PlanProd`:
  1. `download` de `DatabricksJobs`/`DatabricksNotebooks` (da CI, não do backup).
  2. `cd-planambiente_sp_prod_v1.py` — visão geral de diferenças (jobs + notebooks) entre o artefato da CI e o estado real de PROD.

**`PROD`** (`dependsOn: [QA, Backup_Prod, Plan_Prod]`; `condition: runProd` + `QA` em `Succeeded`/`Skipped` + `Backup_Prod` em `Succeeded` + `Plan_Prod` em `Succeeded`/`Skipped` — garante que o snapshot e o plano de PROD sempre terminam **antes** de qualquer alteração em PROD)
- Job `ApplyProd` (`variables: variableGroupProdApply`, gate de aprovação próprio):
  1. `download` de `DatabricksJobs`/`DatabricksNotebooks`.
  2. Key Vault: `token-pat` (PROD).
  3. Teste de PAT (valida `len(token) > 10`).
  4. `test-implantajobs-temp_sp_prod_v4.py` — cria/deleta job `TEMP_` em PROD.
  5. Key Vault: `token-databricks-prod` (PROD).
  6. `cd-importarjobs_sp_prod_v9_cluster.py --mode apply`.
  7. `cd-clonarepo_prod_v3.py` (env `SYSTEM_ACCESSTOKEN`, `TARGET_BRANCH=prodBranch`).
  8. Script inline: `PATCH /api/2.0/repos/{prodRepoId}` para `prodBranch`.

> A stage de `Plan` (QA e PROD) roda em job separado, antes do deploy/apply correspondente — permite revisar o diff de jobs/notebooks entre o artefato da CI e o ambiente real (com gate próprio via `variableGroupProdPlan` em PROD) antes de qualquer escrita.

### Artefatos

| Artefato | Publicado por | Consumido por |
|---|---|---|
| `DatabricksJobs` / `DatabricksNotebooks` | CI | `PlanQA`, `DeployQA`, `PlanProd`, `ApplyProd` |
| `DatabricksJobsQA` / `DatabricksNotebooksQA` | `Backup_QA` | `app-dtfn-rollback-qa.yml` (`rollback-pipeline.yaml`) |
| `DatabricksJobsPROD` / `DatabricksNotebooksPROD` | `Backup_Prod` | `app-dtfn-rollback-prod.yml` (`rollback-pipeline.yaml`) |

### Pré-requisitos

- Manifestos `config/job-mappings/qa.json` e `config/job-mappings/prod.json` precisam existir e conter o campo `job_mappings` (mesmo que vazio).
- Approvals/Checks são configurados diretamente nos Variable Groups (`variableGroupProdPlan`, `variableGroupProdApply`) pela UI do Azure DevOps — não há task de approval explícita no YAML.

---

## 3. Rollback (QA/PROD) — `rollback-pipeline.yaml`

**Trigger:** `none`. **Wrappers:** `app-dtfn-rollback-qa.yml` e `app-dtfn-rollback-prod.yml`. Template ambiente-agnóstico — todo valor específico de ambiente (Key Vault, Variable Group, nomes de artefato e de scripts) vem de parâmetro, com defaults iguais aos de PROD (mantém compatibilidade com o wrapper de PROD já existente). Consome os artefatos publicados pela stage de Backup correspondente da CD (`Backup_QA` ou `Backup_Prod`), não pela antiga pipeline de backup standalone, descontinuada.

### Parâmetros

| Nome | Tipo | Default (= comportamento de PROD) | Descrição |
|---|---|---|---|
| `agentPoolCI` / `agentPoolCD` | string | `GeneralPurposeLinuxAgentsCI` / `...CD` | Pools de segurança e de rollback |
| `cdPipelineAlias` | string | `cdPipeline` | Alias do `resources.pipelines` (aponta para a CD) |
| `notebooksRepoAlias` | string | `''` (vazio) | Alias do `resources.repositories` do repositório de notebooks, **só quando diferente do self** (ex.: PROD usa `comp-dtfn-prod`). Vazio para QA — o `rollbackCopiaScript` de QA clona o próprio self |
| `fortifyExclusionRepository` / `enableFortifyExclusions` / `convisoCompany` / `vivoFlow` | — | (mesmos defaults) | Segurança |
| `variableGroupRollback` | string | `vg-dtfn-cd-prod-apply` | Variable Group do ambiente de rollback |
| `keyVaultServiceConnection` / `keyVaultName` | string | `sc-adf-dtfn-brsouth-prod` / `kv-dtfn-brsouth-001-prod` | Key Vault do ambiente de rollback |
| `cdArtifactJobsName` / `cdArtifactNotebooksName` | string | `DatabricksJobsPROD` / `DatabricksNotebooksPROD` | Artefatos publicados pelo Backup do ambiente na CD |
| `scriptsPath` | string | `scripts/ci-cd` | Diretório dos scripts |
| `rollbackImportScript` | string | `rollback-importarjobs_sp_prod_v5_cluster.py` | Script de importação/rollback de Jobs |
| `rollbackCopiaScript` | string | `rollback-copia_nbs_prod_v1.py` | Script de cópia de Notebooks para o repositório Git |
| `rollbackImplantaScript` | string | `rollback-implanta_nbs_prod_v1.py` | Script de implantação dos Notebooks no Databricks Repos |
| `clientSecretArgName` | string | `--client-secret-prod` | Nome do argumento de client secret esperado pelo script de importação |
| `clientSecretVar` | string | `AZURE_CLIENT_SECRET_PROD` | Variável de pipeline com o client secret do Service Principal do ambiente |
| `databricksTokenVarName` | string | `PROD_TOKEN` | Nome da env var de token do Databricks esperada pelo script de implantação de Notebooks |

### Stages

**`SecurityAnalysis`** — igual às demais.

**`Rollback`** (depende implicitamente de `SecurityAnalysis`; `variables: variableGroupRollback`)
- Job `RollbackJob`:
  1. Checkout condicional (`${{ if ne(parameters.notebooksRepoAlias, '') }}`): `self` + `notebooksRepoAlias`, em par — necessário só quando o repositório de notebooks é diferente do self (PROD); garante que o `System.AccessToken` recebe acesso ao repositório de notebooks neste job. Quando `notebooksRepoAlias` fica vazio (QA), nenhum checkout explícito é feito — o self continua sendo obtido implicitamente.
  2. `download` de `cdArtifactJobsName`/`cdArtifactNotebooksName` (da CD, stage de Backup do ambiente).
  3. Key Vault: `token-databricks` (autenticação git usa `System.AccessToken`, não Key Vault).
  4. `${rollbackImportScript} ${clientSecretArgName} $(${clientSecretVar}) --jobs-folder ...`.
  5. `${rollbackCopiaScript} --notebooks-folder ...` (env `SYSTEM_ACCESSTOKEN=$(System.AccessToken)`).
  6. `${rollbackImplantaScript}` (env `${databricksTokenVarName}=$(token-databricks)`, sem argumentos — URL e repo ID do ambiente fixos no script).

### Valores por wrapper

| Parâmetro | `app-dtfn-rollback-prod.yml` | `app-dtfn-rollback-qa.yml` |
|---|---|---|
| `notebooksRepoAlias` | alias do `resources.repositories` de `comp-dtfn-prod` (ex.: `prodRepo`) | `''` (vazio — clona o próprio self) |
| `variableGroupRollback` | `vg-dtfn-cd-prod-apply` | `vg-dtfn-cd-qa` |
| `keyVaultServiceConnection` / `keyVaultName` | `sc-adf-dtfn-brsouth-prod` / `kv-dtfn-brsouth-001-prod` | `sc-adf-dtfn-brsouth-test` / `kv-dtfn-brsouth-001-e1` |
| `cdArtifactJobsName` / `cdArtifactNotebooksName` | `DatabricksJobsPROD` / `DatabricksNotebooksPROD` | `DatabricksJobsQA` / `DatabricksNotebooksQA` |
| Scripts (`rollbackImportScript`/`CopiaScript`/`ImplantaScript`) | `..._prod_v5_cluster.py` / `..._prod_v1.py` / `..._prod_v1.py` | `..._qa_v1.py` / `..._qa_v1.py` / `..._qa_v1.py` |
| `clientSecretArgName` / `clientSecretVar` | `--client-secret-prod` / `AZURE_CLIENT_SECRET_PROD` | `--client-secret` / `AZURE_CLIENT_SECRET_QA` |
| `databricksTokenVarName` | `PROD_TOKEN` | `QA_TOKEN` |

### Observações importantes

- Os seis scripts de rollback (três por ambiente: `rollback-importarjobs_sp_{qa,prod}_v*.py`, `rollback-copia_nbs_{qa,prod}_v*.py`, `rollback-implanta_nbs_{qa,prod}_v*.py`) têm branch, caminho de workspace e Repo ID **fixos no código de cada script**, não recebidos por parâmetro — a pipeline só escolhe qual arquivo invocar; a lógica de ambiente continua vivendo no script, no mesmo padrão dos pares de scripts de deploy (`cd-importarjobs_sp_qa_v10_cluster.py` / `_prod_v9_cluster.py`).
- Os scripts `rollback-copia_nbs_{qa,prod}_v1.py` reescrevem a pasta `databricks/` inteira a partir do artefato de backup (remove e recopia) antes de dar push na branch do ambiente — é uma operação destrutiva por design, reservada a incidentes reais (ou a testes deliberados em QA).
- `cdArtifactJobsName`/`cdArtifactNotebooksName` de QA (`DatabricksJobsQA`/`DatabricksNotebooksQA`) já são publicados hoje pela stage `Backup_QA` da CD — nenhuma mudança na CD foi necessária para viabilizar o rollback de QA.

---

## Convenção de artefatos entre as pipelines

```
CI               →  DatabricksJobs, DatabricksNotebooks
CD / Backup_QA   →  DatabricksJobsQA, DatabricksNotebooksQA        (consumido pelo Rollback QA)
CD / Backup_Prod →  DatabricksJobsPROD, DatabricksNotebooksPROD    (consumido pelo Rollback PROD)
```