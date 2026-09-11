# Documentação do Pipeline YML Editor

## Visão Geral

**Nome do Pipeline**: `pipeline_yml_editor.yml`  
**Localização**: `/tech_products/appv/common/scripts/yml-editor/`
**Propósito**: Editar programaticamente arquivos YAML em múltiplos repositórios usando manipulação estruturada de YAML.

Este pipeline permite operações de edição YAML seguras, validadas e automatizadas em múltiplos repositórios no Azure DevOps. Diferente de abordagens de substituição de string, ele usa `yq` (processador YAML) para garantir integridade estrutural e validação automática.

---

## O Que Este Pipeline Faz?

O pipeline YML Editor realiza modificações YAML estruturadas em múltiplos repositórios em uma única execução. Ele:

1. **Filtra repositórios** baseado em padrões de nomenclatura ou listas explícitas
2. **Clona cada repositório correspondente** para um workspace temporário
3. **Localiza arquivos YAML alvo** usando padrões glob
4. **Executa operações YAML** usando edição estruturada (via `yq`)
5. **Valida alterações** para garantir que a sintaxe YAML permanece válida
6. **Faz commit e push das alterações** (ou simula em modo dry-run)
7. **Gera relatórios detalhados** mostrando status de sucesso/falha/skip por repositório

Cada execução recebe um ID único (formato: `YML-EDIT-YYYYMMDD-R`) que pode ser usado para rastrear ou reverter alterações.

---

## Como Funciona?

### Detalhes da Execução de Operações

Cada operação é implementada como um script Bash especializado em `/operations/`:

- **`add-pipeline-parameter.sh`**: Adiciona parâmetros ao array `parameters:`, sincroniza automaticamente `extends.parameters`, e preserva espaçamento de linhas em branco
- **`set-value.sh`**: Define valores em caminhos YAML arbitrários (requer que o caminho exista)
- **`delete-path.sh`**: Deleta caminhos YAML (pula se o caminho não existir)

Todas as operações usam `yq` para edição estruturada e incluem etapas de validação pré/pós.

---

## Como Usar Este Pipeline

### Pré-requisitos

1. **Personal Access Token (PAT) do Azure DevOps** com permissões:
   - Code (Read)
   - Code (Write)

2. **Variável de tempo de fila** (definir ao executar o pipeline):
   - Nome da variável: `AZURE_DEVOPS_PAT`
   - Valor: Seu PAT
   - ☑ **Deve marcar "Keep this value secret"**

### Uso Passo a Passo

#### Passo 1: Começar com Dry-Run

Sempre teste alterações primeiro com `dryRun: true`:

1. Navegue até o pipeline no Azure DevOps
2. Clique em "Run pipeline"
3. Configure os parâmetros (veja [Referência de Parâmetros](#referência-de-parâmetros) abaixo)
4. Defina `dryRun: true`
5. Adicione a variável `AZURE_DEVOPS_PAT` (marcar como secreta)
6. Clique em "Run"

#### Passo 2: Revisar Resultados do Dry-Run

Verifique o resumo da execução para:

- ✅ Quantos repositórios corresponderam aos seus filtros
- ✅ Quais arquivos seriam modificados
- ✅ Se a validação YAML passou
- ✅ Qualquer aviso ou mensagem de skip

**Procure por**:

- `Total repositories processed: X`
- `Success: Y / Failed: Z / Skipped: W`
- Mensagens de validação por repositório

#### Passo 3: Aplicar Alterações

Quando os resultados do dry-run estiverem corretos:

1. Clique em "Run pipeline" novamente
2. **Defina `dryRun: false`**
3. Mantenha todos os outros parâmetros idênticos
4. Execute o pipeline

Alterações serão commitadas com formato:

```
[YML-EDIT-20260220-1] <detalhes> [CI SKIP]
```

#### Passo 4: Verificar ou Reverter

- **Verificar**: Verifique alguns repositórios para confirmar que as alterações foram aplicadas corretamente
- **Reverter** (se necessário): Use `pipeline_revert_from_repo.yml` com o ID de execução

---

## Referência de Parâmetros

### Parâmetros Obrigatórios

| Parâmetro         | Tipo   | Descrição                                        | Exemplo                                                |
| ----------------- | ------ | ------------------------------------------------ | ------------------------------------------------------ |
| `projectName`     | string | Nome do projeto Azure DevOps                     | `APPV - APP VIVO`                                      |
| `targetFilePath`  | string | Padrão de caminho de arquivo (suporta wildcards) | `/.azuredevops/pipelines/buildpack.yml`                |
| `operation`       | string | Tipo de operação YAML a executar                 | `add-pipeline-parameter`                               |
| `valueDefinition` | string | Valor/definição JSON para a operação             | Veja [Detalhes das Operações](#detalhes-das-operações) |

### Parâmetros de Filtro de Repositório

| Parâmetro              | Tipo   | Padrão | Descrição                                                               |
| ---------------------- | ------ | ------ | ----------------------------------------------------------------------- |
| `startsWith`           | string | `src`  | Nome do repositório deve começar com isto (use `*` para todos)          |
| `endsWith`             | string | `*`    | Nome do repositório deve terminar com isto (use `*` para todos)         |
| `specificRepositories` | array  | `[]`   | Lista explícita de nomes de repositórios (sobrepõe startsWith/endsWith) |

**Lógica de Filtros:**

- Filtros combinam com lógica **AND**
- Use `*` como wildcard para pular aquele filtro
- `specificRepositories` tem prioridade: se preenchido, apenas esses repos são processados
- **Aviso**: Definir todos os filtros como `*` com `specificRepositories` vazio irá processar **TODOS os repositórios**

**Exemplos:**

- `startsWith: "src"`, `endsWith: "*"` → Todos os repos começando com "src"
- `startsWith: "*"`, `endsWith: "-backend"` → Todos os repos terminando com "-backend"
- `startsWith: "src"`, `endsWith: "-api"` → Repos começando com "src" **E** terminando com "-api"
- `specificRepositories: ["repo1", "repo2"]`, `startsWith: "src"` → Apenas repo1 e repo2

### Parâmetros de Comportamento

| Parâmetro       | Tipo    | Padrão   | Descrição                                                                    |
| --------------- | ------- | -------- | ---------------------------------------------------------------------------- |
| `dryRun`        | boolean | `true`   | `true` = apenas simular (sem commits), `false` = aplicar alterações          |
| `branch`        | string  | `master` | Branch alvo para editar                                                      |
| `commitMessage` | string  | ` `      | Mensagem de commit customizada                                               |
| `skipCi`        | boolean | `true`   | Adicionar `[CI SKIP]` à mensagem de commit (previne disparo de pipelines CI) |

### Parâmetros Específicos de Operação

| Parâmetro        | Tipo   | Necessário Para            | Descrição                                                           |
| ---------------- | ------ | -------------------------- | ------------------------------------------------------------------- |
| `targetProperty` | string | `set-value`, `delete-path` | Caminho YAML em sintaxe yq (ex: `.spec.replicas`, `.variables.FOO`) |

**Nota**: `targetProperty` é **ignorado** para operação `add-pipeline-parameter` (sempre visa o array `.parameters`).

---

## Detalhes das Operações

### 1. `add-pipeline-parameter`

**Propósito**: Adicionar um novo parâmetro ao array `parameters:` em arquivos YAML de pipelines do Azure.

**O Que Faz**:

1. Valida definição do parâmetro (requer campos `name` e `type`)
2. Verifica se o parâmetro já existe (previne duplicatas)
3. Adiciona parâmetro usando `yq` ao array `.parameters`
4. Sincroniza automaticamente a seção `extends.parameters` (se bloco `extends` existir)
5. Preserva linhas em branco entre parâmetros
6. Valida sintaxe YAML após edição

**Formato de valueDefinition**:

Objeto JSON com os seguintes campos:

| Campo         | Obrigatório | Tipo   | Descrição                                   | Exemplo                                         |
| ------------- | ----------- | ------ | ------------------------------------------- | ----------------------------------------------- |
| `name`        | ✅ Sim      | string | Nome do parâmetro (minúsculas, sem espaços) | `"resourcesAndHpaValues"`                       |
| `type`        | ✅ Sim      | string | Tipo do parâmetro                           | `"string"`, `"boolean"`, `"object"`, `"number"` |
| `displayName` | ❌ Não      | string | Nome legível para humanos                   | `"Configuração de recursos"`                    |
| `default`     | ❌ Não      | any    | Valor padrão                                | `"value"`, `true`, `{"cpu": "1"}`               |
| `values`      | ❌ Não      | array  | Valores permitidos (para dropdowns)         | `["dev", "staging", "prod"]`                    |

**Exemplo de valueDefinition**:

```json
{
  "name": "resourcesAndHpaValues",
  "displayName": "Configuração de recursos e HPA",
  "type": "object",
  "default": {
    "resources": {
      "limits": { "cpu": "unchanged", "memory": "unchanged" },
      "requests": { "cpu": "unchanged", "memory": "unchanged" }
    },
    "hpa": { "minReplicas": "unchanged", "maxReplicas": "unchanged" }
  }
}
```

**Validação**:

- ❌ Falha se `name` ou `type` estiver faltando
- ❌ Falha se o parâmetro já existir no arquivo
- ❌ Falha se a sintaxe YAML estiver inválida após edição

---

### 2. `set-value`

**Propósito**: Definir um valor em qualquer caminho YAML (para edição genérica de YAML).

**O Que Faz**:

1. Valida que o caminho `targetProperty` existe no arquivo
2. Define valor no caminho especificado usando `yq`
3. Suporta valores escalares (string, número, boolean) ou valores complexos (objetos, arrays)
4. Valida sintaxe YAML após edição

**Parâmetros**:

- `targetProperty`: Caminho YAML em sintaxe yq (ex: `.spec.replicas`, `.variables.CONFIG`)
- `valueDefinition`: Escalar ou objeto JSON

**Exemplos**:

**Exemplo 1: Definir valor escalar**

```yml
operation: set-value
targetProperty: .spec.replicas
valueDefinition: 3
targetFilePath: deployment.yml
```

**Exemplo 2: Definir valor de objeto**

```yml
operation: set-value
targetProperty: .variables.CONFIG
valueDefinition: '{"key1": "value1", "key2": "value2"}'
targetFilePath: config.yml
```

**Exemplo 3: Definir valor string**

```yml
operation: set-value
targetProperty: .variables.ENVIRONMENT
valueDefinition: "production"
targetFilePath: azure-pipelines.yml
```

**Validação**:

- ❌ Pula se o caminho `targetProperty` não existir
- ❌ Falha se a sintaxe YAML estiver inválida após edição

---

### 3. `delete-path`

**Propósito**: Deletar um caminho YAML (para remover seções ou propriedades obsoletas).

**O Que Faz**:

1. Verifica se o caminho `targetProperty` existe
2. Deleta o caminho usando `yq`
3. Pula silenciosamente se o caminho não existir (sem erro)
4. Valida sintaxe YAML após edição

**Parâmetros**:

- `targetProperty`: Caminho YAML em sintaxe yq
- `valueDefinition`: **IGNORADO** (não usado para operações de deleção)

**Exemplo**:

```yml
operation: delete-path
targetProperty: .deprecated.oldSection
valueDefinition: ""
targetFilePath: config.yml
```

**Validação**:

- ✅ Pula (sem erro) se o caminho não existir
- ❌ Falha se a sintaxe YAML estiver inválida após edição

---

## Exemplos de Execução

### Exemplo 1: Adicionar Parâmetro de Configuração HPA

**Cenário**: Adicionar um novo parâmetro para configuração HPA (Horizontal Pod Autoscaler) a todos os pipelines CI em repositórios começando com "src".

**Parâmetros de Entrada**:

```yml
operation: add-pipeline-parameter
valueDefinition: '{"name": "resourcesAndHpaValues", "displayName": "Configuração de recursos e HPA", "type": "object", "default": {"resources": {"limits": {"cpu": "unchanged", "memory": "unchanged"}, "requests": {"cpu": "unchanged", "memory": "unchanged"}}, "hpa": {"minReplicas": "unchanged", "maxReplicas": "unchanged", "targetCPUUtilizationPercentage": "unchanged", "targetMemoryUtilizationPercentage": "unchanged"}}}'
targetFilePath: /.azuredevops/pipelines/buildpack.yml
projectName: APPV - APP VIVO
startsWith: src
endsWith: *
specificRepositories: []
dryRun: true
branch: master
commitMessage:
skipCi: true
```

**Resultado Esperado**:

- Parâmetro adicionado a todos os arquivos `/.azuredevops/pipelines/buildpack.yml` em repositórios começando com "src"
- `extends.parameters.resourcesAndHpaValues` automaticamente sincronizado
- Linhas em branco preservadas entre parâmetros
- Sem disparo de pipelines (devido a `[CI SKIP]`)

---

### Exemplo 2: Adicionar Feature Flag Booleana a Repositórios Específicos

**Cenário**: Adicionar uma feature flag para habilitar/desabilitar uma nova funcionalidade em serviços backend específicos.

**Parâmetros de Entrada**:

```yml
operation: add-pipeline-parameter
valueDefinition: '{"name": "enableNewFeature", "displayName": "Enable New Feature (Beta)", "type": "boolean", "default": false, "values": [true, false]}'
targetFilePath: /.azuredevops/pipelines/buildpack.yml
projectName: APPV - Microservicosmeuvivo
startsWith: *
endsWith: *
specificRepositories: ["src-backend-service1", "src-backend-service2", "src-backend-service3"]
dryRun: true
branch: master
skipCi: true
```

**Resultado Esperado**:

- Parâmetro adicionado apenas aos 3 repositórios especificados
- Apenas arquivos `/.azuredevops/pipelines/buildpack.yml` modificados (pipelines CD)
- Dropdown booleano com valores true/false

---

### Exemplo 3: Adicionar Seletor de Ambiente a Pipelines Frontend

**Cenário**: Adicionar um seletor de ambiente de deployment a todos os pipelines frontend.

**Parâmetros de Entrada**:

```yml
operation: add-pipeline-parameter
valueDefinition: '{"name": "deploymentEnvironment", "displayName": "Select Deployment Environment", "type": "string", "default": "dev", "values": ["dev", "staging", "production"]}'
targetFilePath: /.azuredevops/pipelines/buildpack.yml
projectName: FRBR - FRAMEWORK BRASIL
startsWith: *
endsWith: -frontend
specificRepositories: []
dryRun: true
branch: master
skipCi: true
```

**Resultado Esperado**:

- Parâmetro adicionado a todos os repositórios terminando com "-frontend"
- Seletor dropdown com opções dev/staging/production
- Valor padrão definido como "dev"

---

### Exemplo 4: Definir Contagem de Réplicas em Manifestos Kubernetes

**Cenário**: Atualizar contagem de réplicas para 3 em todos os arquivos de deployment.

**Parâmetros de Entrada**:

```yml
operation: set-value
targetProperty: .spec.replicas
valueDefinition: 3
targetFilePath: k8s/deployment.yml
projectName: APPV - APP VIVO
startsWith: src
endsWith: *
dryRun: true
branch: master
```

**Resultado Esperado**:

- `.spec.replicas` definido como `3` em todos os arquivos de deployment correspondentes
- Pula repositórios onde o caminho não existe
- Estrutura YAML preservada

---

### Exemplo 5: Deletar Seção Obsoleta

**Cenário**: Remover seção de configuração obsoleta de todos os arquivos de pipeline.

**Parâmetros de Entrada**:

```yml
operation: delete-path
targetProperty: .deprecated.oldConfig
valueDefinition:
targetFilePath: azure-pipelines.yml
projectName: APPV - APP VIVO
startsWith: *
endsWith: *
dryRun: true
branch: master
```

**Resultado Esperado**:

- Seção `.deprecated.oldConfig` removida de todos os arquivos
- Silenciosamente pula arquivos onde o caminho não existe
- Sem erros para caminhos faltantes

---

## Validação e Tratamento de Erros

### Validação Pré-Execução

O pipeline valida parâmetros antes de processar qualquer repositório:

| Validação                | Verificação                                        | Mensagem de Erro                                                 |
| ------------------------ | -------------------------------------------------- | ---------------------------------------------------------------- |
| Nome do projeto          | Obrigatório, não vazio                             | `Project name is required`                                       |
| Caminho do arquivo alvo  | Obrigatório, não vazio                             | `Target file path is required`                                   |
| Aviso de todos wildcards | Todos filtros `*` com `specificRepositories` vazio | `All filters are wildcards - this will process ALL repositories` |
| Específico de operação   | Depende da operação                                | Veja detalhes da operação                                        |

### Validação Específica de Operação

**`add-pipeline-parameter`**:

- ✅ `valueDefinition` deve ser JSON válido
- ✅ `valueDefinition` deve ser um objeto JSON (não escalar)
- ✅ Deve incluir campo `name`
- ✅ Deve incluir campo `type`
- ❌ Falha se o parâmetro já existir no arquivo

**`set-value`**:

- ❌ Pula se o caminho `targetProperty` não existir

**`delete-path`**:

- ✅ Pula silenciosamente se o caminho não existir (sem erro)

### Validação Pós-Edição

Após cada operação de edição:

1. **Validação de sintaxe YAML** usando `yq eval`
2. **Verificações específicas da operação**:
   - `add-pipeline-parameter`: Verifica que o parâmetro existe, sem duplicatas
   - `set-value`: Verifica que o valor foi definido no caminho alvo
   - `delete-path`: Verifica que o caminho não existe mais

Se a validação falhar:

- ❌ Erro registrado no resumo
- ❌ Repositório marcado como "failed"
- ❌ Sem commit (mesmo se `dryRun: false`)

---

## ID de Execução e Rastreamento

Cada execução do pipeline gera um ID de execução único:

**Formato**: `YML-EDIT-YYYYMMDD-R`

**Exemplo**: `YML-EDIT-20260220-1`

**Propósito**:

- Rastrear alterações em múltiplos repositórios
- Habilitar rollback em lote usando `pipeline_revert_from_repo.yml`
- Identificar commits deste pipeline

**Como Usar para Reverter**:

1. Copie o ID de execução do resumo do pipeline
2. Execute `pipeline_revert_from_repo.yml`
3. Forneça o ID de execução como entrada
4. Todos os commits daquela execução serão revertidos

---

## Vantagens Sobre `pipeline_replace_from_repo.yml`

| Funcionalidade              | pipeline_replace_from_repo.yml                    | pipeline_yml_editor.yml            |
| --------------------------- | ------------------------------------------------- | ---------------------------------- |
| **Abordagem de edição**     | Find-and-replace de string                        | Edição estruturada de YAML         |
| **Indentação**              | Contagem manual necessária, propensa a erros      | Automática, gerenciada pelo `yq`   |
| **Validação**               | Nenhuma (pode criar YAML inválido)                | Validação completa de sintaxe YAML |
| **Prevenção de duplicatas** | Não verificada                                    | Automaticamente prevenida          |
| **Caso de uso**             | Substituição simples de string, arquivos não-YAML | Modificações de estrutura YAML     |

**Quando Usar Qual**:

✅ **Use `pipeline_yml_editor.yml`** para:

- Adicionar/modificar parâmetros de pipeline
- Alterações estruturadas em YAML (modificar objetos aninhados, arrays)
- Quando indentação é importante
- Quando você precisa de validação
- Operações específicas de YAML

✅ **Use `pipeline_replace_from_repo.yml`** para:

- Substituição simples de string (ex: mudar URLs, números de versão)
- Arquivos não-YAML (Markdown, JSON, scripts)
- Edições parciais de linha (substituir parte de uma string)
- Quando você precisa de correspondência regex

---

## Segurança e Permissões

### Permissões de PAT Necessárias

Seu Personal Access Token do Azure DevOps deve ter:

- ✅ **Code (Read)**: Clonar repositórios
- ✅ **Code (Write)**: Fazer commit e push de alterações
- ❌ **NÃO necessário**: Build, Release, ou outras permissões

### Como Definir PAT como Variável de Tempo de Fila

1. Navegue até o pipeline no Azure DevOps
2. Clique em **"Run pipeline"**
3. Clique no botão **"Variables"**
4. Clique em **"+ Add variable"**
5. Digite:
   - **Name**: `AZURE_DEVOPS_PAT`
   - **Value**: Seu PAT (cole das configurações do Azure DevOps)
6. ☑ **Marque "Keep this value secret"** (crítico!)
7. Clique em **"OK"**
8. Clique em **"Run"**

### Melhorias Futuras

- ⏳ **`update-parameter`**: Modificar parâmetros existentes sem delete + add
- ⏳ **`add-parameter-at-position`**: Inserir parâmetro em posição específica no array
- ⏳ **`add-value-to-list`**: Adicionar item ao array `values` do parâmetro
- ⏳ **`remove-value-from-list`**: Remover item do array `values`
- ⏳ **`update-extends`**: Modificar seção extends independentemente

---

## Pipelines e Ferramentas Relacionadas

### Pipelines Relacionadas

- **`pipeline_revert_from_repo.yml`**: Reverter alterações feitas por este pipeline usando ID de execução
- **`pipeline_replace_from_repo.yml`**: Find-and-replace de string para edições não estruturadas (veja aviso acima)

### Ferramentas Externas

- **yq** (mikefarah/yq v4): Processador YAML para manipulação estruturada
  - Documentação: https://mikefarah.gitbook.io/yq/
  - Instalado automaticamente pelo pipeline se não presente

- **jq**: Processador JSON para listas de repositórios e parsing de parâmetros
  - Pré-instalado em agentes do Azure DevOps

- **Azure CLI**: Operações de repositório (listar, clonar, push)
  - Pré-instalado em agentes do Azure DevOps

### Recursos Adicionais

- [Azure Pipelines YAML Schema](https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema)
- [Documentação yq](https://mikefarah.gitbook.io/yq/)
- [AGENTS.md](/AGENTS.md) - Diretrizes de contribuição do repositório

---
