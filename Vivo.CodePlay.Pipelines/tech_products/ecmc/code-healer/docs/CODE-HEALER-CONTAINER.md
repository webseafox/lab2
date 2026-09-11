# Como utilizar o Code Healer Container

Pipeline Azure DevOps para corrigir vulnerabilidades `HIGH` e `CRITICAL` em uma imagem Docker hospedada no ACR ou no Nexus. A pipeline baixa a imagem, executa o agente de correção, publica a imagem corrigida no ACR e abre PRs nos repositórios que utilizam a imagem original.

## Obrigatório

- Criar o arquivo `.azuredevops/variables/private.yml`.
- Criar ou utilizar um grupo de variáveis com as credenciais e configurações do Code Healer.
- Garantir que o agente privado possua Docker, Python, `uv`, `jq`, `curl` e Azure CLI.
- Garantir acesso ao repositório `Vivo.Core.Pipelines.Scripts` pelo endpoint `CorePipelines`.

### Arquivo `private.yml`

Exemplo mínimo:

```yaml
variables:
  - group: code-healer
  - name: global_poollImage
    value: "default"
```

![Exemplo de Variable Group](../resources/library-example.png)

**Importante: todas as variáveis listadas nesta seção devem ser cadastradas em um Variable Group (Library) do Azure DevOps. O grupo utilizado pela pipeline é o code-healer, conforme exemplo ilustrado na imagem acima.**

O grupo de variáveis deve fornecer os valores usados pela pipeline:

| Variável                                      | Uso                                                     |
| --------------------------------------------- | ------------------------------------------------------- |
| `COPILOT_API_KEY`                             | Chave usada pelo agente (`fix` e `create-pr`).          |
| `ARCANE_TEAMS_URL`                            | URL do webhook de notificações.                         |
| `TEAMS_CHAT_CONTAINER_ID`                     | ID do chat; mapeada para `CHAT_ID_TEAMS`.               |
| `DOCKER_ACR_REGISTRY_SERVICE_CONNECTION_NAME` | Service connection usada no push (`Docker@2`).          |
| `DOCKER_ACR_REGISTRY`                         | Host do ACR de destino.                                 |
| `DOCKER_NEXUS_REGISTRY`                       | Host do Nexus de origem, quando aplicável.              |
| `DOCKER-REGISTRY-ACR-USERNAME`                | Usuário do ACR.                                         |
| `DOCKER-REGISTRY-ACR-PASSWORD`                | Senha do ACR.                                           |
| `NEXUS-DEPS-USR`                              | Usuário do Nexus.                                       |
| `NEXUS-DEPS-PSW`                              | Senha do Nexus.                                         |
| `UV_VERSION`                                  | Versão do `uv` usada na instalação.                     |
| `TRIVY_VERSION`                               | Versão do Trivy instalada na pipeline.                  |
| `PROXY_AGENT_HTTP`                            | Proxy HTTP do agente privado.                           |
| `PROXY_AGENT_HTTPS`                           | Proxy HTTPS do agente privado.                          |
| `PROXY_AGENT_NO_PROXY`                        | Exceções de proxy (`no_proxy`).                         |
| `AZURE_DOCKERFILE_NAMES`                      | Dockerfiles alvo no `create-pr` (opcional).             |
| `COMMIT_MESSAGE_PATTERN`                      | Padrão de commit no `create-pr` (opcional).             |
| `PR_TITLE_PATTERN`                            | Padrão de título de PR no `create-pr` (opcional).       |
| `MODEL_NAME`                                  | Modelo usado pelo agente (opcional; default no código). |
| `LOG_LEVEL`                                   | Nível de log (opcional; default no código).             |
| `MAX_ATTEMPTS`                                | Tentativas máximas de correção (opcional; default 3).   |

O `config.py` valida no agente: `COPILOT_API_KEY`, `ARCANE_TEAMS_URL`, `CHAT_ID_TEAMS`, `AZURE_PAT` e `AZURE_PROJECT`.

## Uso do template

No arquivo de pipeline do novo projeto, referencie o `entrypoint.yml`:

```yaml
trigger: none

parameters:
  - name: image
    type: string
    default: ""
    displayName: "Imagem Docker a ser corrigida"

resources:
  repositories:
    - repository: CodePlayPipelines
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: refs/heads/master
      endpoint: CorePipelines

extends:
  template: /tech_products/ecmc/code-healer/entrypoint.yml@CodePlayPipelines
  parameters:
    correctionStrategy:
      codeHealer: "CONTAINER"
    image: ${{ parameters.image }}
```

O parâmetro `image` deve conter a referência completa da imagem, incluindo host, repositório e tag:

```text
lojaonline-dkr.nexus.telefonica.com.br/node:26.1.0-vivo-alpine
```

Se `image` estiver vazio, o stage do Code Healer Container não será executado.

## Configurações opcionais do agente

Estas variáveis são lidas pelo `config.py` e podem ser sobrescritas no grupo de variáveis:

| Variável                 | Default                                 | Uso                                                     |
| ------------------------ | --------------------------------------- | ------------------------------------------------------- |
| `MAX_ATTEMPTS`           | `3`                                     | Número máximo de tentativas de correção.                |
| `MODEL_NAME`             | `gpt-5.4-mini`                          | Modelo usado pela Copilot API.                          |
| `AZURE_DOCKERFILE_NAMES` | `builder.Dockerfile,runtime.Dockerfile` | Dockerfiles atualizados nos PRs, separados por vírgula. |
| `COMMIT_MESSAGE_PATTERN` | padrão do projeto                       | Padrão da mensagem de commit.                           |
| `PR_TITLE_PATTERN`       | padrão do projeto                       | Padrão do título do PR.                                 |
| `LOG_LEVEL`              | `DEBUG`                                 | Nível de log.                                           |
| `PIPELINE_URL`           | vazio                                   | URL da execução exibida nas notificações.               |

## Fluxo de execução

1. A pessoa informa a imagem pelo parâmetro `image`.
2. A pipeline carrega as credenciais, identifica o ACR ou Nexus, valida a imagem e executa `docker pull`.
3. O agente executa `fix`, faz o scan Trivy, gera o Dockerfile, realiza o build local e grava `fix.json`.
4. Se `fix.json` tiver `status=success`, a pipeline calcula a nova tag, faz `docker tag` e publica a imagem corrigida no ACR.
5. Após o push, o agente executa `create-pr` com `fix.json` e a referência da nova imagem.
6. Os PRs são abertos no Azure DevOps e o resultado é enviado ao Teams.

O login, o pull e o push são responsabilidades da pipeline. O agente não recebe nem armazena credenciais de registry.

## Verificação

- [ ] O arquivo `.azuredevops/variables/private.yml` está presente.
- [ ] O grupo `code-healer` está vinculado à pipeline.
- [ ] `TEAMS_CHAT_CONTAINER_ID` está definido.
- [ ] As credenciais do ACR e Nexus estão disponíveis no Key Vault.
- [ ] `DOCKER_REGISTRY_SERVICE_CONNECTION` possui permissão de pull e push no ACR.
- [ ] O pool privado possui Docker, `uv`, `jq`, `curl`, Python e Azure CLI.
- [ ] O repositório `Vivo.Core.Pipelines.Scripts` está acessível pelo endpoint `CorePipelines`.
- [ ] Uma execução com `image` preenchida gera `fix.json` e publica a imagem corrigida.
- [ ] O `create-pr` recebe uma referência ACR não vazia após o push.

## Saída

O agente gera `fix.json` com, entre outros, os campos:

```text
status
image_name
local_image_tag
dockerfile_content
cves_fixed[]
cves_remaining[]
partial_fix
attempts_used
error_message
```

`local_image_tag` é a tag local usada pela pipeline para publicar a imagem corrigida. A referência final do ACR é calculada pela pipeline e enviada ao `create-pr`.
