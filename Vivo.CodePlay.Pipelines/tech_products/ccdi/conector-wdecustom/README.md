# CCDI - Conector WDE Custom (ClickOnce)

> Templates de CI/CD para a aplicação **CCDI (Conector WDE Custom)** — aplicação .NET ClickOnce buildada via MSBuild e deployada em servidor HTTP via SSH.

---

## Visão Geral

O **CCDI** é uma aplicação desktop .NET distribuída via **ClickOnce**, publicada em um servidor HTTP Apache. O fluxo de CI/CD inclui build no Windows (MSBuild + NuGet), empacotamento ClickOnce via PowerShell, deploy dos arquivos para o servidor HTTP via SSH e validação da URL de publicação.

## Arquivos

| Arquivo  | Tipo   | Descrição                                                        |
|----------|--------|------------------------------------------------------------------|
| `ci.yml` | CI     | Build .NET ClickOnce + publicação opcional no Azure Artifacts    |
| `cd.yml` | CD HML | Deploy ClickOnce via SSH para servidor HTTP + validação de URL   |

## Pipeline Pai (PIPES PAIS)

| Pipeline Pai                        | Template            | Aplicação                |
|-------------------------------------|---------------------|--------------------------|
| `CCDI/azure-pipelines.yml`          | `ci.yml` + `cd.yml` | Conector WDE Custom      |

---

## CI (`ci.yml`)

| Propriedade       | Valor                                                          |
|-------------------|----------------------------------------------------------------|
| **Pool**          | `Azure Pipelines` (vmImage: `windows-latest`)                 |
| **Stages**        | `Build` → `Publish` (condicional)                              |
| **Build**         | NuGet Restore → MSBuild (`CCDI.sln`) → PowerShell ClickOnce   |
| **Artefato**      | Pacote ClickOnce publicado como artifact do pipeline           |
| **Versionamento** | Manual via parâmetro `packageVersion`                          |

### Parâmetros

| Parâmetro        | Tipo    | Default | Descrição                                         |
|------------------|---------|---------|---------------------------------------------------|
| `enablePublish`  | boolean | `false` | Habilita o stage de publicação no Azure Artifacts |
| `feedPackage`    | string  | `''`    | Nome do pacote no Azure Artifacts                 |
| `packageVersion` | string  | `''`    | Versão do pacote para publicação                  |

### Fluxo de Execução

1. **Build**:
   - Checkout do código-fonte
   - Install NuGet tooling
   - Restore pacotes NuGet (`CCDI/CCDI.sln`)
   - Build MSBuild (Release, Any CPU)
   - Executa script PowerShell `publish-clickonce-production.ps1` para gerar pacote ClickOnce
   - Publica artifact `clickonce` no pipeline

2. **Publish** (condicional em `enablePublish`):
   - Download do artifact ClickOnce
   - Publica como `UniversalPackages` no Azure Artifacts

### Pré-requisitos

- **Agente Windows**: Pool `Azure Pipelines` com `windows-latest`
- **Script PowerShell**: `CCDI/publish-clickonce-production.ps1` no repositório consumidor
- **Solution**: `CCDI/CCDI.sln` no repositório consumidor

---

## CD Homologação (`cd.yml`)

| Propriedade | Valor                                                                       |
|-------------|-----------------------------------------------------------------------------|
| **Pool**    | `GeneralPurposeLinuxAgentsCD`                                               |
| **Stages**  | `Deploy` → `Validate`                                                       |
| **Método**  | Download artifact ClickOnce → Copia via SSH → Validação HTTP da URL         |

### Fluxo de Execução

1. **Deploy**:
   - Download do artifact ClickOnce do pipeline
   - Copia todos os arquivos via SSH (`CopyFilesOverSSH@0`) para `$(webRootPath)/$(targetFolder)`
   - Limpa pasta destino antes do deploy (`cleanTargetFolder: true`)

2. **Validate**:
   - Checkout do código-fonte (para obter script de validação)
   - Executa `CCDI/validate-clickonce-url.ps1` contra `$(validationUrl)/$(targetFolder)`
   - Valida que a URL ClickOnce está acessível e funcional

### Variáveis Obrigatórias (definidas no pipeline pai)

| Variável               | Descrição                                         |
|------------------------|---------------------------------------------------|
| `targetFolder`         | Nome da pasta destino no servidor HTTP            |
| `clickOnceArtifactName`| Nome do artifact do pipeline                      |
| `webRootPath`          | Caminho raiz do servidor HTTP (htdocs)            |
| `sshEndpoint`          | Service Connection SSH para o servidor de deploy  |
| `validationUrl`        | URL base para validação do deploy (IP:porta)      |

---

## Variáveis do Pipeline Pai

| Variável               | Valor                              | Descrição                                    |
|------------------------|------------------------------------|----------------------------------------------|
| `targetFolder`         | `CCDI-Azure`                       | Pasta destino no servidor HTTP               |
| `clickOnceArtifactName`| `clickonce`                        | Nome do artifact ClickOnce                   |
| `webRootPath`          | `/gcti/apache-httpd/htdocs`        | Raiz do Apache HTTP                          |
| `serverHost`           | `brtlvlty1688sl`                   | Hostname do servidor                         |
| `serverIP`             | `10.129.176.116`                   | IP do servidor (para validação)              |
| `serverPort`           | `18080`                            | Porta HTTP do servidor                       |
| `serverBaseUrl`        | `http://$(serverHost):$(serverPort)` | URL base (hostname)                         |
| `validationUrl`        | `http://$(serverIP):$(serverPort)` | URL de validação (IP)                        |
| `sshEndpoint`          | `SSH_SYNCQA`                       | Service Connection SSH                       |
| `feedPackage`          | `ccenter.ccdi.conector-wdecustom`  | Nome do pacote no Azure Artifacts            |
| `packageVersion`       | *(vazio)*                          | Versão para publicação (definir manualmente) |

---

## Service Connections

| Tipo | Service Connection | Uso                                |
|------|--------------------|------------------------------------|
| SSH  | `SSH_SYNCQA`       | Deploy dos arquivos ClickOnce      |

---

## Diferenças em relação ao Middleware (CCIN/WAS)

| Aspecto       | Middleware (CCIN)                | CCDI ClickOnce                         |
|---------------|----------------------------------|----------------------------------------|
| Plataforma    | Java (Maven/Ant)                 | .NET (MSBuild/NuGet)                   |
| Agente Build  | Linux (`GeneralPurposeLinuxAgentsCI`) | Windows (`windows-latest`)         |
| Artefato      | WAR                              | Pacote ClickOnce                       |
| Deploy        | WebLogic (WLST/Deployer)        | Servidor HTTP Apache (SSH)             |
| Validação     | N/A                              | Validação de URL HTTP                  |
| Versionamento | Automático (`VERSION.md` + pom)  | Manual (parâmetro `packageVersion`)    |

---

*Last updated: Fevereiro 2026*
