# WAS - Composer (URAs Composer)

> Templates de CI/CD para as aplicações **URAs Composer** — WARs buildados via Docker/Ant e deployados no WebLogic.

---

## Visão Geral

O **Composer** é o módulo responsável pelas aplicações de URAs Composer, que utilizam um processo de build diferente dos demais middlewares: em vez de Maven, o build é feito via **Docker** com **Ant** (`ExportWar`). O versionamento segue o mesmo padrão `0.0.v` via `VERSION.md`, mas a versão é controlada pelo `build.xml` (Ant) ao invés do `pom.xml` (Maven).

## Arquivos

| Arquivo  |  Tipo  | Descrição                                                |
|----------|--------|----------------------------------------------------------|
| `ci.yml` | CI     | Build WAR via Docker/Ant + publicação no Azure Artifacts |
| `cd.yml` | CD HML | Deploy WAR no WebLogic via SSH + `weblogic.Deployer`     |

## Pipeline Pai (PIPES PAIS)

| Pipeline Pai         | Template            |
|----------------------|---------------------|
| `azure-pipeline.yml` | `ci.yml` + `cd.yml` |

---

## CI (`ci.yml`)

| Propriedade       | Valor                                                              |
|-------------------|--------------------------------------------------------------------|
| **Pool**          | `GeneralPurposeLinuxAgentsCI`                                      |
| **Stages**        | `Build` → `Publish`                                                |
| **Build**         | Docker build (`.azuredevops/builder.Dockerfile`) + Ant `ExportWar` |
| **Artefato**      | WAR publicado via `UniversalPackages@0`                            |
| **Versionamento** | PowerShell: lê `VERSION.md` + `build.xml`, incrementa `0.0.v`      |

### Parâmetros

| Parâmetro       | Tipo    | Default | Descrição                                         |
|-----------------|---------|---------|---------------------------------------------------|
| `enablePublish` | boolean | `false` | Habilita o stage de publicação no Azure Artifacts |

### Fluxo de Execução

1. **Build**:
   - Download secure file (`settings_pipelines.xml`) + Key Vault
   - Checkout
   - Docker build com imagem customizada do builder
   - `docker run ... ant ExportWar` gera o WAR
   - Publish artifact WAR

2. **Publish** (condicional em `enablePublish`):
   - Checkout + Download artifact
   - Recupera versão do `VERSION.md` (maior `0.0.v`)
   - Recupera versão do `build.xml` (atributo `version`)
   - Valida que `build.xml` não tem versão manual maior
   - Atualiza `VERSION.md` com nova versão
   - Atualiza `build.xml` com nova versão
   - Publica `UniversalPackages`
   - Commit + push do `VERSION.md` e `build.xml`
   - Sincroniza `VERSION.md` em todas as branches remotas

### Pré-requisitos

- **Secure File**: `settings_pipelines.xml`
- **Key Vault**: `kv-azdevops-shared` — secrets `NEXUS-DEPS-USR`, `NEXUS-DEPS-PSW`
- **Dockerfile**: `.azuredevops/builder.Dockerfile` no repositório consumidor
- **Arquivo**: `build.xml` com `<property name="version" value="..." />`

---

## CD Homologação (`cd.yml`)

| Propriedade     | Valor                                                                      |
|-----------------|----------------------------------------------------------------------------|
| **Pool**        | `GeneralPurposeLinuxAgentsCD`                                              |
| **Stages**      | `Deploy`                                                                   |
| **Método**      | Download artifact → Rename WAR com sufixo → SSH copy → `weblogic.Deployer` |
| **Dependência** | `dependsOn: Publish`                                                       |

### Fluxo de Execução

1. Download artifact WAR do pipeline
2. Renomeia WAR adicionando `SUFIXO_PACKAGE` (ex: `IvrPrePago` → `IvrPrePagoSufixo`)
3. Copia WAR para o servidor via SSH
4. Executa `weblogic.Deployer` para redeploy

### Variáveis Obrigatórias (Library/Variable Group)

| Variável         | Descrição                                     |
|------------------|-----------------------------------------------|
| `SSH`            | Service Connection SSH                        |
| `IP`             | IP do AdminServer WebLogic                    |
| `APP`            | Nome da aplicação Composer                    |
| `SUFIXO_PACKAGE` | Sufixo adicionado ao nome do WAR para deploy  |
| `WEBLOGIC_USER`  | Usuário WebLogic                              |
| `WEBLOGIC_PASS`  | Senha WebLogic (secreta)                      |
| `CLUSTER`        | Cluster target                                |
| `JAVA_PATH_SSH`  | Caminho do Java no servidor remoto            |
| `WL_PATH_SSH`    | Caminho do `weblogic.jar` no servidor remoto  |

---

## Variable Groups

| Variable Group                | Usada em            |
|-------------------------------|---------------------|
| `azdo-team-project-variables` | CI + CD HML         |
| `docker-variables`            | CI (build Docker)   |
| `java-variables`              | CI (build Java/Ant) |

---

## Diferenças em relação ao Middleware (CCIN)

| Aspecto       | Middleware (CCIN)          | Composer                           |
|---------------|----------------------------|------------------------------------|
| Build         | Maven (`pom.xml`)          | Docker + Ant (`build.xml`)         |
| Versionamento | `pom.xml` + `VERSION.md`   | `build.xml` + `VERSION.md`         |
| Deploy HML    | `weblogic.Deployer` direto | `weblogic.Deployer` com sufixo     |
| Deploy PRD    | WLST scripts multi-site    | **Não possui CD Produção próprio** |

---

*Last updated: Fevereiro 2026*
