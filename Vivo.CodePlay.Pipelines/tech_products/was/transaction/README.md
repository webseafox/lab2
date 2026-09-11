# WAS - Transaction (Configuração XML)

> Templates de CI/CD para a aplicação **Transaction Config** — arquivo XML de configuração de transações deployado nos servidores de URA.

---

## Visão Geral

O **Transaction** é um módulo de configuração (não é um WAR). O artefato é um **arquivo XML** (`transaction-config.xml`) que descreve as configurações de transações da URA. O fluxo inclui validação contra schema XSD, versionamento via `VERSION.md`, e deploy via cópia SSH do arquivo para os servidores.

## Arquivos

| Arquivo       | Tipo   | Descrição                                         |
|---------------|--------|---------------------------------------------------|
| `ci.yml`      | CI     | Validação XSD + publicação no Azure Artifacts     |
| `cd.yml`      | CD HML | Deploy XML config via SSH (dinâmico por branch)   |
| `cd-prod.yml` | CD PRD | Deploy XML config em produção via Artifacts + SSH |

## Pipelines Pai (PIPES PAIS)

> Os pipelines pai para Transaction são definidos no projeto Azure DevOps do repositório consumidor. Eles referenciam estes templates via `resources.repositories`.

---

## CI (`ci.yml`)

| Propriedade       | Valor                                                               |
|-------------------|---------------------------------------------------------------------|
| **Pool**          | `GeneralPurposeLinuxAgentsCI`                                       |
| **Stages**        | `Validate` → `Publish`                                              |
| **Validação**     | `transaction-config-validator.jar` + XSD (`transactionXSD8486.xsd`) |
| **Versionamento** | PowerShell: extrai maior `0.0.v` do `VERSION.md` e incrementa       |

### Fluxo de Execução

1. **Validate**:
   - Checkout + download `transaction-config-validator.jar` do Artifacts
   - Download secure file XSD
   - Executa validação: `java -jar validator.jar <arquivo> <xsd>`

2. **Publish** (condicional — apenas em PRs para `master` ou execução manual na `master`):
   - Checkout + fetch master
   - Gera nova versão `0.0.v` a partir do `VERSION.md`
   - Publica arquivo XML no Azure Artifacts (`UniversalPackages`)
   - Adiciona nova versão no topo da tabela do `VERSION.md`
   - Commit + push na `master`

### Condição de Publish

```yaml
condition: or(
  and(eq(variables['Build.Reason'], 'PullRequest'), eq(variables['System.PullRequest.TargetBranch'], 'refs/heads/master')),
  and(eq(variables['Build.SourceBranch'], 'refs/heads/master'), eq(variables['Build.Reason'], 'Manual'))
)
```

### Variáveis Obrigatórias

| Variável       | Descrição                                                               |
|----------------|-------------------------------------------------------------------------|
| `ARQUIVO`      | Nome do arquivo XML a validar e publicar (ex: `transaction-config.xml`) |
| `FEED_PACKAGE` | Nome do pacote no Azure Artifacts                                       |

### Secure Files

- `transactionXSD8486.xsd` — Schema XSD para validação

---

## CD Homologação (`cd.yml`)

| Propriedade     | Valor                                                 |
|-----------------|-------------------------------------------------------|
| **Pool**        | `GeneralPurposeLinuxAgentsCD`                         |
| **Stages**      | `Deploy`                                              |
| **Método**      | Checkout + `CopyFilesOverSSH@0` direto do repositório |
| **Dependência** | `succeeded('Validate')`                               |

### Fluxo de Execução

1. Checkout do repositório (para ter o XML)
2. Copia `$(ARQUIVO)` para `$(TRANSACTION_FILE_DIR)` no servidor

### Service Connection Dinâmica

A Service Connection é construída dinamicamente com base no nome da branch:
```
SSH_MOVEL_$(Build.SourceBranchName)
```
Exemplo: branch `QA3` → usa `SSH_MOVEL_QA3`

### Variáveis Obrigatórias

| Variável               | Descrição                     |
|------------------------|-------------------------------|
| `ARQUIVO`              | Nome do arquivo XML           |
| `TRANSACTION_FILE_DIR` | Diretório destino no servidor |

---

## CD Produção (`cd-prod.yml`)

| Propriedade | Valor                                                         |
|-------------|---------------------------------------------------------------|
| **Pool**    | `GeneralPurposeLinuxAgentsCD`                                 |
| **Stages**  | `Deploy` (com `environment: deploy-producao`)                 |
| **Método**  | Download Artifacts → Copia XML para servidor SYNC de produção |

### Parâmetros

| Parâmetro        | Tipo   | Default    | Descrição                    |
|------------------|--------|------------|------------------------------|
| `packageVersion` | string | —          | Versão do pacote para deploy |
| `environment`    | string | `producao` | Ambiente de destino          |

### Fluxo de Execução

1. Download pacote do Artifacts (`transaction-config`)
2. Debug: lista conteúdo do workspace
3. Copia XML para servidor SYNC de produção via SSH
4. Checkout self (para `VERSION.md`)
5. Atualiza `VERSION.md` — substitui `-` pela data de deploy
6. Commit + push na `master`

### Service Connection

- `SSH_SYNCPROD` — servidor de sincronização de produção (1154CO)

### Variáveis Obrigatórias

| Variável               | Descrição                                           |
|------------------------|-----------------------------------------------------|
| `FEED_PACKAGE`         | Nome do pacote no Azure Artifacts                   |
| `ARQUIVO`              | Nome do arquivo XML                                 |
| `TRANSACTION_FILE_DIR` | Diretório destino no servidor SYNC                  |
| `SSH_PROD`             | Service Connection SSH de produção (para `cd_prod`) |

---

## Variable Groups

| Variable Group                | Usada em    |
|-------------------------------|-------------|
| `azdo-team-project-variables` | CI + CD HML |
| `cred-prod`                   | CD Produção |

---

*Last updated: Fevereiro 2026*
