# CI Templates - Notification e Changelog

Templates de Continuous Integration focados em **notificação de mudanças e integração com o sistema de changelog centralizado**.

## 🎯 Descrição

O diretório `ci` contém **1 template stage** que encapsula a lógica de:

- **`ci-changelog-notification-appv.yml`**: Notificação de changelog para Sentinels após publicação

Este template permite que mudanças de aplicação sejam **automaticamente registradas** no sistema centralizado de changelog, facilitando rastreabilidade e comunicação de releases.

## 🏗️ Matriz de Capacidades

| Capacidade | Suporte | Descrição |
|------------|---------|-----------|
| Notificação de Changelog | ✅ | Envio automático de changelog para Sentinels |
| Rastreabilidade de Releases | ✅ | Registro de versão e commits via changelog |
| Integração Centralizada | ✅ | Sincronização com sistema central Sentinels |
| Validação de Formato | ✅ | Validação JSON e resposta HTTP 202 |

**Legenda:**
- ✅ Suportado nativamente

---

## 📋 Template Detalhado

### 📢 `ci-changelog-notification-appv.yml`

**Tipo**: Stage completa de CI
**Propósito**: Localiza changelog gerado, recupera hash do commit e notifica sistema Sentinels via HTTP POST

**Quando Usar**:
- Após stage de publicação de artefatos
- Quando há arquivo `changelog.json` gerado no repositório
- Para registrar mudanças em repositório central de changelog
- Quando precisa comunicar releases automaticamente

**Responsabilidades**:
- 🔧 Checkout do código-fonte com histórico Git
- 📝 Localiza arquivo `changelog.json` na raiz do repositório
- 🎯 Recupera hash do último commit da branch
- 📤 Envia changelog em formato JSON para endpoint Sentinels via POST
- ✅ Valida resposta HTTP 202 (Accepted)
- ❌ Falha se arquivo não existe ou resposta não é 202

**Estágio Definido**:
- **Nome**: `ci_changelog_notification`
- **DisplayName**: `CI - Changelog Notification`
- **Pool**: `GeneralPurposeLinuxAgentsCI`
- **Dependência**: `ci_publish` (deve completar com sucesso antes)

**Condições**:
- ✅ Executa se stage anterior (`ci_publish`) completou com sucesso
- ✅ Executa em qualquer branch
- ✅ Executa em qualquer razão de build

**Fluxo Executado**:

#### 1. **Checkout Code**

Prepara workspace:
- Task: Decorator checkout (ID: `6d15af64-176c-496d-b583-fd2ae21d4df4@1`)
- Repository: Self
- Clean: true
- Persist Credentials: true (necessário para git operations)

#### 2. **Checkout Last Commit**

Recupera informações do último commit:

```bash
git config pull.rebase true
git fetch -f --depth 1 origin {branch}:{branch}
git checkout -f {branch}
lastCommitHash=$(git rev-parse --short=6 HEAD)
```

- Depth: 1 (apenas último commit, mais rápido)
- Short hash: 6 caracteres
- Output: `SHORT_HASH` variable
- Condição: `succeeded()` (executa se checkout bem-sucedido)

#### 3. **Validate Changelog.json**

Verifica existência do arquivo:

```bash
json="$(Build.SourcesDirectory)/changelog.json"
if [ -f "$json" ]; then
  echo "Changelog.json file found"
else
  echo "Changelog.json file NOT found"
  exit 1  # Falha
fi
```

- Localização: Raiz do repositório (`Build.SourcesDirectory`)
- Se ausente: Stage falha
- Continua: Se presente

#### 4. **Notify Sentinels**

Envia changelog via HTTP POST:

```bash
curl --write-out "HTTPSTATUS:%{http_code}" \
     --request POST \
     --url $(SENTINELS_ENDPOINT_URL) \
     --header 'Content-Type: application/json' \
     --data @changelog.json
```

**Validação de Resposta**:

- ✅ **HTTP 202 (Accepted)**: Success
  - Log: `Notification succeeded with status code 202`
- ❌ **HTTP != 202**: Falha
  - Log: Response body e headers para debug
  - Direciona para `[Lib Publish Failure]` job
  - Exit: 1 (stage falha)

**Requisitos**:

1. **Arquivo `changelog.json`**
   - Localização: Raiz do repositório
   - Formato: JSON válido
   - Exemplo:
     ```json
     {
       "version": "2.1.0",
       "application": "my-app",
       "timestamp": "2026-06-24T10:30:00Z",
       "changes": [
         {
           "type": "feat",
           "message": "Nova funcionalidade X",
           "author": "João Silva"
         },
         {
           "type": "fix",
           "message": "Corrigido bug Y",
           "author": "Maria Santos"
         }
       ]
     }
     ```

2. **Variável `SENTINELS_ENDPOINT_URL`**
   - Deve estar definida (tipicamente em `variables-global.yml`)
   - Exemplo: `https://pre-framework-brasil-ingress.telefonicabigdata.com/dev/ms/sentinels/azure/changelog`
   - Deve ser acessível pelo agent

3. **Conectividade de Rede**
   - Agent deve ter acesso à URL de Sentinels
   - HTTPS/TLS funcionando
   - Sem bloqueios de proxy ou firewall

4. **Branch Source Branch Necessária**
   - `Build.SourceBranchName` disponível
   - Git history acessível

**Variáveis de Saída**:

| Variável | Step | Tipo | Descrição |
|----------|------|------|-----------|
| `SHORT_HASH` | checkout_last_commit | string | Hash do último commit (6 chars) |

**Referência em Outros Steps**:

```yaml
- task: Bash@3
  displayName: "Use Short Hash"
  inputs:
    script: |
      echo "Last commit: $(SHORT_HASH)"
      echo "Changelog notified for: $(SHORT_HASH)"
```

**Inclusão no Pipeline**:

```yaml
stages:
- stage: ci_build
  displayName: "CI - Build"
  # ... build steps

- stage: ci_publish
  displayName: "CI - Publish"
  dependsOn:
    - ci_build
  # ... publish steps

- template: /tech_products/appv/global/templates/ci/ci-changelog-notification-appv.yml
  # Depende automaticamente de ci_publish
```

---

## 🏗️ Formato de Changelog.json

Recomendação de estrutura para o arquivo que será enviado para Sentinels:

```json
{
  "version": "2.1.0",
  "application": "minha-aplicacao",
  "release_date": "2026-06-24T10:30:00Z",
  "commit_hash": "a1b2c3d4e5f6",
  "environment": "production",
  
  "summary": "Release com novas funcionalidades e correções",
  
  "changes": [
    {
      "type": "feat",
      "scope": "auth",
      "message": "Adicionar suporte a OAuth 2.0",
      "author": "João Silva",
      "ticket": "JIRA-1234"
    },
    {
      "type": "fix",
      "scope": "database",
      "message": "Corrigir pool de conexões esgotado",
      "author": "Maria Santos",
      "ticket": "JIRA-5678"
    },
    {
      "type": "perf",
      "scope": "api",
      "message": "Otimizar consultas N+1",
      "author": "Pedro Costa",
      "ticket": "JIRA-9012"
    }
  ],
  
  "breaking_changes": [
    {
      "message": "Endpoint /v1/users descontinuado, usar /v2/users",
      "migration": "Veja guia de migração em docs/MIGRATION_v2.md"
    }
  ],
  
  "contributors": [
    "João Silva",
    "Maria Santos",
    "Pedro Costa"
  ]
}
```

**Boas Práticas**:

- ✅ Sempre incluir `version` (semântico)
- ✅ Incluir `application` (nome do projeto)
- ✅ Agrupar mudanças por `type` (feat, fix, perf, etc)
- ✅ Incluir `author` para rastreabilidade
- ✅ Documentar `breaking_changes` explicitamente
- ✅ Timestamp no formato ISO 8601
- ✅ Tickets JIRA ou referências para rastreamento

---

## 🚀 Quick Start - Exemplos

### Exemplo 1: Pipeline Completa com Changelog

```yaml
stages:
- stage: ci_build
  displayName: "CI - Build"
  pool:
    name: GeneralPurposeLinuxAgentsCI
  jobs:
  - job: build
    displayName: "Build Docker"
    steps:
    - task: Docker@2
      displayName: "Build and Push"
      # ... build steps

- stage: ci_publish
  displayName: "CI - Publish"
  dependsOn:
    - ci_build
  pool:
    name: GeneralPurposeLinuxAgentsCI
  jobs:
  - job: publish
    displayName: "Publish Artifacts"
    steps:
    - task: PublishBuildArtifacts@1
      displayName: "Publish"
      # ... publish steps

- template: /tech_products/appv/global/templates/ci/ci-changelog-notification-appv.yml
  # Notifica changelog automaticamente
```

### Exemplo 2: Com Geração Dinâmica de Changelog

```yaml
- stage: ci_publish
  displayName: "CI - Publish"
  jobs:
  - job: publish
    displayName: "Publish"
    steps:
    - checkout: self
      persistCredentials: true

    - task: Bash@3
      displayName: "Generate Changelog"
      inputs:
        script: |
          #!/bin/bash
          # Gera changelog a partir de commits
          cat > changelog.json << EOF
          {
            "version": "$(git describe --tags --always)",
            "application": "my-app",
            "commit_hash": "$(git rev-parse --short HEAD)",
            "changes": [
              {
                "type": "feat",
                "message": "New feature"
              }
            ]
          }
          EOF
          
          cat changelog.json

    - template: /tech_products/appv/global/templates/ci/ci-changelog-notification-appv.yml
      # Notifica changelog gerado
```

### Exemplo 3: Changelog Condicional

```yaml
- stage: ci_publish
  displayName: "CI - Publish"
  jobs:
  - job: publish
    displayName: "Publish"
    steps:
    - task: Bash@3
      displayName: "Generate Changelog if Release"
      condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/master'))
      inputs:
        script: |
          # Gera changelog apenas se master
          # ...
          echo "##vso[task.setvariable variable=SHOULD_NOTIFY]true"

    - template: /tech_products/appv/global/templates/ci/ci-changelog-notification-appv.yml
      condition: eq(variables['SHOULD_NOTIFY'], 'true')
```

---

## 🔐 Dependências e Credenciais

### Variáveis Necessárias

| Variável | Origem | Descrição | Exemplo |
|----------|--------|-----------|---------|
| `SENTINELS_ENDPOINT_URL` | variables-global.yml | URL do endpoint Sentinels | `https://pre-framework-brasil-ingress.telefonicabigdata.com/dev/ms/sentinels/azure/changelog` |
| `Build.SourceBranchName` | Azure DevOps | Branch atual | `main`, `develop`, `release/2.1.0` |
| `Build.SourcesDirectory` | Azure DevOps | Diretório de checkout | `/azpwork/1/s` |

### Permissões Necessárias

- ✅ Permissão de checkout do repositório
- ✅ Permissão de read em `changelog.json`
- ✅ Acesso de rede ao endpoint Sentinels
- ✅ Git credentials para `git operations`

### Segurança

- ✅ Endpoint URL não logado (está em variável)
- ✅ Credenciais não passadas no JSON (apenas URL pública)
- ✅ HTTPS obrigatório
- ✅ Sem secrets no changelog.json

---

## ❓ FAQ

### O arquivo changelog.json é obrigatório?

Sim! Se não existir, a stage falha. Você deve gerá-lo antes desta stage. Tipicamente é criado na stage de CI anterior.

### Posso gerar o changelog automaticamente a partir de commits?

Sim! Existem ferramentas como `conventional-commits` que fazem isso automaticamente. Basta gerar o arquivo JSON antes desta stage.

### O que fazer se Sentinels está fora do ar?

A stage falhará se o HTTP POST não retornar 202. Você pode:
1. Fazer retry da pipeline
2. Esperar Sentinels voltar
3. Notificar manualmente o time de DevOps

### Posso desabilitar a notificação?

Não incluindo esta stage na pipeline. Ela é opcional - somente adicione se precisa notificar.

### Qual é o timeout desta stage?

Não há timeout específico. O timeout padrão do job é usado. Geralmente completa em segundos (< 1 minuto).

## 🏗️ Estrutura do Pipeline

```
ci/
├── ci-changelog-notification-appv.yml    # Stage de notificação
└── README.md                              # Documentação (este arquivo)
```

**Fluxo**:
1. Checkout do código
2. Checkout último commit
3. Validação de changelog.json
4. POST HTTP para Sentinels
5. Validação HTTP 202

## 🔧 Dependências Externas

- **Sentinels Endpoint**: Servidor central de changelog (`$(SENTINELS_ENDPOINT_URL)`)
- **Git**: Para operações de fetch/checkout
- **Changelog.json**: Arquivo gerado em stage anterior (ci_publish)

## 💡 Comportamentos Customizados

### Validação Rigorosa de Resposta

Stage falha se HTTP 202 não for retornado. Isso força a geração prévia de changelog.

### Integração com Histórico Git

Extrai SHORT_HASH do último commit para rastreabilidade completa do changelog.

## 🔐 Variáveis de Ambiente

- `SENTINELS_ENDPOINT_URL` - URL do endpoint central Sentinels (deve estar em variáveis globais)
- `SHORT_HASH` - Hash de 6 caracteres do último commit (outputs do stage)
- `Build.SourcesDirectory` - Diretório raiz do código

### Decisão 1: Notificação Automática via HTTP POST

- **Data**: 2026-06-24
- **Motivador**: Necessidade de registrar releases em sistema centralizado sem manual intervention
- **Forum Envolvido**: Equipe DevOps AppV
- **Descrição**: Stage de CI que executa POST HTTP para Sentinels com changelog.json. Validação rigorosa: HTTP 202 (Accepted) requerido. Falha se ausente (força geração prévia). Permite rastreabilidade completa de releases.

---

## 🆘 Suporte

- [Abra um chamado para Dev Support](https://dvps.redecorp.azr/portal/codeplay/roteiro/#:~:text=Abra%20um%20chamado%20para%20Dev%20Support)
- [Canal DevEx - Azure DevOps](https://teams.microsoft.com/l/channel/19%3A8fbd00946cf044d7a844182ac71e6aa1%40thread.tacv2/Azure%20DevOps?groupId=038b4415-d6dd-42ce-92e5-31a8e2a13bf8&tenantId=9744600e-3e04-492e-baa1-25ec245c6f10)

---

**Última atualização**: 2026-06-24
