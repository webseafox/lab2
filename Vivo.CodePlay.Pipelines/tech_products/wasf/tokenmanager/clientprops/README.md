# WASF - Token Manager / Client Props

> Templates de CI/CD para a configuração **client-props.json** do Token Manager — arquivo JSON de configuração de clients OAuth deployado nos servidores de URA.

---

## Visão Geral

O **Token Manager Client Props** gerencia o ciclo de vida do arquivo `client-props.json`, que contém as configurações de clients OAuth utilizados pela URA. O fluxo inclui validação de schema JSON, teste real de autenticação OAuth via SOCKS proxy (SSH tunnel), e deploy via cópia SSH seguido de restart do cache do Token Manager.

## Arquivos

| Arquivo        | Tipo   | Descrição                                                            |
|----------------|--------|----------------------------------------------------------------------|
| `ci.yml`       | CI     | Validação JSON Schema + teste OAuth real + publicação no Artifacts   |
| `cd.yml`       | CD HML | Deploy `client-props.json` em homologação + restart cache            |
| `cd_prod.yaml` | CD PRD | Deploy `client-props.json` em produção via Artifacts + restart cache |

## Pipelines Pai (PIPES PAIS)

> Os pipelines pai para Token Manager são definidos no projeto Azure DevOps do repositório consumidor, referenciando estes templates via `resources.repositories`.

---

## CI (`ci.yml`)

| Propriedade   | Valor                                          |
|---------------|------------------------------------------------|
| **Pool**      | `GeneralPurposeLinuxAgentsCI`                  |
| **Stages**    | `Validate` → `Publish`                         |
| **Validação** | JSON Schema + teste OAuth real via SOCKS proxy |

### Fluxo de Execução

1. **Validate**:
   - Download `json-validator.jar` + `python-token-tester` do Artifacts
   - Download secure files: `clientPropsSCHEMA.json`, `keys.zip`, chave SSH
   - Valida `client-props.json` contra schema JSON (`JSON-validator.jar`)
   - Configura SSH key + known_hosts
   - Extrai chaves privadas de `keys.zip`
   - Instala dependências Python (`requests[socks]`)
   - Cria SSH tunnel SOCKS proxy (porta 1080) para o servidor de URA
   - Executa `oauth_tester_fixed.py` — testa tokens de cada client em `$(ENVIRONMENT)`

2. **Publish** (condicional — apenas em PRs para `master`):
   - Gera versão timestamp no formato `yyyy.M.d.HHmm`
   - Publica `client-props.json` no Artifacts como `token-manager-client-props`

### Condição de Publish

```yaml
condition: and(eq(variables['Build.Reason'], 'PullRequest'), eq(variables['System.PullRequest.TargetBranch'], 'refs/heads/master'))
```

### Variáveis Obrigatórias

| Variável       | Descrição                                         |
|----------------|---------------------------------------------------|
| `IP`           | IP do servidor de URA (para SSH tunnel)           |
| `SSH_KEY_NAME` | Nome do Secure File com chave SSH                 |
| `ENVIRONMENT`  | Ambiente para teste OAuth (`dev` / `hml` / `prd`) |

### Secure Files

| Secure File              | Descrição                        |
|--------------------------|----------------------------------|
| `clientPropsSCHEMA.json` | JSON Schema para validação       |
| `keys.zip`               | Chaves privadas para teste OAuth |
| `$(SSH_KEY_NAME)`        | Chave SSH (nome dinâmico)        |

---

## CD Homologação (`cd.yml`)

| Propriedade     | Valor                                                    |
|-----------------|----------------------------------------------------------|
| **Pool**        | `GeneralPurposeLinuxAgentsCD`                            |
| **Stages**      | `Deploy`                                                 |
| **Método**      | Checkout + `CopyFilesOverSSH@0` + restart cache via cURL |
| **Dependência** | `succeeded('Validate')`                                  |

### Fluxo de Execução

1. Copia `client-props.json` para `/opt/web/applications/ccenter/ura_movel/config` via SSH
2. Restart do cache do Token Manager via cURL: `http://10.129.176.157:7101/oam-token-manager/restart-cache`

### Service Connection

- `SSH_MOVEL_DEV` — servidor de desenvolvimento/homologação

---

## CD Produção (`cd_prod.yaml`)

| Propriedade | Valor                                                            |
|-------------|------------------------------------------------------------------|
| **Pool**    | `GeneralPurposeLinuxAgentsCD`                                    |
| **Stages**  | `Deploy`                                                         |
| **Método**  | Download Artifacts → Copia JSON via SSH → restart cache via cURL |

### Parâmetros

| Parâmetro        | Tipo   | Default | Descrição                                |
|------------------|--------|---------|------------------------------------------|
| `packageVersion` | string | —       | Versão do pacote para deploy (timestamp) |

### Fluxo de Execução

1. Download pacote `token-manager-client-props` do Artifacts
2. Debug: lista conteúdo do workspace
3. Copia `client-props.json` para `/opt/web/applications/ccenter/ura_movel/config` via SSH
4. Restart do cache do Token Manager via cURL

### Variáveis Obrigatórias

| Variável   | Descrição                          |
|------------|------------------------------------|
| `SSH_PROD` | Service Connection SSH de produção |

---

## Observações

- O versionamento utiliza **timestamp** (`yyyy.M.d.HHmm`) ao invés do padrão `0.0.v` dos demais módulos
- O restart de cache é feito via chamada HTTP direta ao endpoint do Token Manager (`/oam-token-manager/restart-cache`)
- A validação OAuth é executada com um SSH tunnel SOCKS proxy, conectando diretamente ao servidor de URA para testar a autenticação de cada client configurado

---

*Last updated: Fevereiro 2026*
