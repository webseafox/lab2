# Pipeline de Unlock do Terraform State

Este pipeline executa operacoes de consulta e desbloqueio (`lease break`) de arquivos de state do Terraform em Azure Storage.

Arquivo do pipeline: `unlock.yml`.

## Visao Geral

O objetivo e destravar um state que ficou com lease ativo (por exemplo, apos interrupcao de execucao Terraform).

Fluxo principal:

1. Recebe um JSON no parametro `jsonConfig`.
2. Le o campo `fullPath` (formato `container/blob`).
3. Separa `containerName` e `blobPath`.
4. Consulta o status do lease.
5. Executa a acao solicitada:
	 - `status`: apenas consulta.
	 - `unlock`: tenta quebrar o lease.
	 - `force-unlock`: atualmente segue o mesmo fluxo de `unlock`.

## Pre-requisitos

- Agent pool: `GeneralPurposeLinuxAgentsCD`
- Service Connection: `SharedResources`
- Storage Account fixo no pipeline: `sttfstatedevopsshared`
- Resource Group fixo no pipeline: `rg-devops-sharedservices`
- Permissao da Service Connection para ler e operar blobs no Storage Account alvo

## Parametros

| Nome | Tipo | Default | Valores | Descricao |
|---|---|---|---|---|
| `environment` | string | `dev` | `dev`, `test`, `prod` | Informativo para operacao; nao altera a conta de storage usada no script atual. |
| `environmentType` | string | `nonprod` | `nonprod`, `prod` | Informativo para selecao operacional. |
| `action` | string | `unlock` | `unlock`, `status`, `force-unlock` | Define a operacao a executar. |
| `workDir` | string | `foundation` | `foundation`, `storage`, `databricks` | Informativo para contexto de uso. |
| `repository_name` | string | `comp-tpl-modelo-azure-databricks` | `comp-tf-azure-databricks`, `comp-tpl-modelo-azure-databricks` | Informativo para identificacao do repositorio de origem. |
| `jsonConfig` | string | - | JSON livre | Deve conter `fullPath` com formato `container/blob`. |

## Formato Obrigatorio do jsonConfig

O pipeline espera um JSON com a chave `fullPath`:

```json
{
	"fullPath": "nonprod/foundation.tfstate"
}
```

Regra de parse:

- `containerName` = parte antes da primeira `/`
- `blobPath` = restante do caminho apos a primeira `/`

Exemplos validos:

- `nonprod/foundation.tfstate`
- `nonprod/projetos/time-a/databricks.tfstate`

Exemplos invalidos:

- `nonprod` (sem blob)
- `/foundation.tfstate` (container vazio)

## Como Executar

1. Abra o pipeline `unlock.yml` no Azure DevOps.
2. Clique em **Run pipeline**.
3. Preencha os parametros, principalmente `action` e `jsonConfig`.
4. Execute.

Exemplo pratico para consultar status:

- `action`: `status`
- `jsonConfig`:

```json
{"fullPath":"nonprod/foundation.tfstate"}
```

Exemplo pratico para desbloquear:

- `action`: `unlock`
- `jsonConfig`:

```json
{"fullPath":"nonprod/projetos/time-a/databricks.tfstate"}
```

## O que o Pipeline Valida

- `fullPath` informado e nao vazio
- Formato de path valido (`container/blob`)
- Existencia do blob de state
- Status de lease antes e depois da operacao

Se o state nao existir ou houver falta de permissao, o pipeline exibe diagnosticos adicionais de conectividade, storage account, containers e blobs.

## Troubleshooting

### Erro: `fullPath is required in values.json`

Causa: `jsonConfig` vazio ou sem campo `fullPath`.

Correcao: envie JSON valido com a chave `fullPath`.

### Erro: `Invalid path format. Expected: container/blob/path`

Causa: `fullPath` sem `/` separando container e blob.

Correcao: use o formato `container/blob`.

### Erro: `Terraform state file not found`

Causas comuns:

- caminho do blob incorreto
- container incorreto
- falta de permissao da Service Connection

Correcao:

1. Copie o caminho exatamente da mensagem de erro do Terraform.
2. Valide se o container e blob existem no Storage Account `sttfstatedevopsshared`.
3. Valide permissoes da Service Connection `SharedResources`.

## Observacoes

- Os parametros `environment`, `environmentType`, `workDir` e `repository_name` estao disponiveis para padronizacao operacional, mas o fluxo de unlock atual depende diretamente do `fullPath` recebido em `jsonConfig`.
- O valor `force-unlock` esta mapeado para o mesmo comportamento de `unlock` no script atual.
