# PROMPT PARA PADRONIZAÇÃO DE PIPELINES AZURE DEVOPS - FRAMEWORK CODEPLAY VIVO

!IMPORTANT!
Mantenha toda a funcionalidade original do pipeline, mas aplique a padronização completa de comentários e estrutura conforme o framework CodePlay da Vivo.
Mantenha as informações técnicas e lógicas intactas, apenas reformate e comente para aderir ao padrão.
Não remova informações e comentários existentes que sejam úteis, formate no padrão.

## OBJETIVO
Transformar pipelines Azure DevOps existentes para seguir o padrão de comentários e estrutura do framework CodePlay da Vivo.

## INSTRUÇÕES PARA O ASSISTENTE

### 1. ESTRUTURA DE CABEÇALHO OBRIGATÓRIA
```yaml
# ==================================================================
# Pipeline: [NOME_DESCRITIVO] - [FUNCIONALIDADE_PRINCIPAL]
# -----------------------------------------------------
# [Descrição detalhada em 2-3 linhas explicando:
#  - O que o pipeline faz
#  - Tecnologias/frameworks envolvidos  
#  - Contexto de uso e funcionalidades principais]
# ==================================================================
```

### 2. ORGANIZAÇÃO DE PARÂMETROS
- Agrupe parâmetros por categoria usando comentários de seção:
```yaml
parameters:
  # ==================================================================
  # [CATEGORIA_DESCRITIVA] - Ex: Parâmetros de Controle de Execução
  # ==================================================================
  - name: parametro1
    # ... configurações
  
  # ==================================================================
  # [OUTRA_CATEGORIA] - Ex: Configuração de Ambiente
  # ==================================================================
  - name: parametro2
    # ... configurações
```

### 3. COMENTÁRIOS EM SEÇÕES PRINCIPAIS
- Variables (se aplicável):
```yaml
# ==================================================================
# Variáveis Internas do Pipeline
# ==================================================================
```

- Stages:
```yaml
# ==================================================================
# Estágios do Pipeline
# ==================================================================
```

### 4. DOCUMENTAÇÃO DE STAGES E JOBS
- Para cada stage, adicione comentário descritivo:
```yaml
stages:
  # Stage [Numero]: [Nome] - [Descrição do que faz no contexto geral]
  - stage: NomeStage
```

- Para jobs de deployment:
```yaml
  - deployment: 'nomeDeployment'
    displayName: '[Descrição do deployment]'
```

### 5. COMENTÁRIOS EM STEPS/TASKS
- Agrupe steps relacionados com comentários explicativos:
```yaml
    steps:
    # [Descrição da categoria de ações - ex: Configuração inicial do ambiente]
    - task: TaskName@Version
      displayName: 'Action Name'
    
    # [Descrição do processamento principal]
    - task: AnotherTask@Version
      displayName: 'Processing Action'
    
    # [Descrição de ações condicionais ou opcionais]
    - task: ConditionalTask@Version
      condition: ${{ parameters.someCondition }}
```

### 6. PADRÕES ESPECÍFICOS IDENTIFICADOS

#### Para Pipelines de Build (CI):
- Configuração inicial e tags
- Checkout do repositório  
- Setup de ferramentas (Node.js, .NET, etc.)
- Autenticação com registries
- Instalação de dependências
- Execução de linter/testes/cobertura (se aplicável)
- Build/transpilação/compilação
- Versionamento e tags
- Publicação de artifacts

#### Para Pipelines de Deploy (CD):
- Preparação e validação
- Login em clusters/serviços
- Configuração de repositórios
- Geração de templates/manifestos
- Deploy propriamente dito
- Verificações pós-deploy
- Ações de fallback/rollback

### 7. CORREÇÕES TÉCNICAS A VERIFICAR
- Indentação correta (2 espaços por nível)
- Sintaxe YAML válida
- Parâmetros com tipos corretos
- Condições bem formadas
- Referencias a variáveis consistentes

## PROMPT COMPLETO PARA PADRONIZAÇÃO DE PIPELINES AZURE DEVOPS

**TAREFA**: Analise o pipeline Azure DevOps fornecido e aplique a padronização completa de comentários e estrutura do framework CodePlay da Vivo.

### INSTRUÇÕES OBRIGATÓRIAS:

#### 1. ADICIONE CABEÇALHO DESCRITIVO PADRÃO:
```yaml
# ==================================================================
# Pipeline: [NOME_DESCRITIVO] - [FUNCIONALIDADE_PRINCIPAL]
# -----------------------------------------------------
# [Descrição detalhada em 2-3 linhas explicando:
#  - O que o pipeline faz
#  - Tecnologias/frameworks envolvidos  
#  - Contexto de uso e funcionalidades principais]
# ==================================================================
```

#### 2. ORGANIZE PARÂMETROS EM CATEGORIAS:
```yaml
parameters:
  # ==================================================================
  # [CATEGORIA_DESCRITIVA] - Ex: Parâmetros de Controle de Execução
  # ==================================================================
  - name: parametro1
    default: valor
    displayName: 'Descrição'

  # ==================================================================
  # [OUTRA_CATEGORIA] - Ex: Configuração de Ambiente/Empacotamento
  # ==================================================================
  - name: parametro2
    type: string
    default: 'valor'
```

#### 3. ADICIONE SEÇÕES DE VARIÁVEIS (se aplicável):
```yaml
# ==================================================================
# Variáveis Internas do Pipeline
# ==================================================================
variables:
  VARIAVEL_1: $[ expressao ]
  VARIAVEL_2: 'valor'
```

#### 4. DOCUMENTE ESTÁGIOS DO PIPELINE:
```yaml
# ==================================================================
# Estágios do Pipeline
# ==================================================================
stages:
  # Stage [Número]: [Nome] - [Descrição do que faz no contexto geral]
  - stage: NomeStage
    displayName: 'Descrição do Stage'
    pool: poolName
    jobs:
    
    - job: nomeJob
      displayName: 'Descrição do Job'
      steps:
```

#### 5. COMENTE GRUPOS DE STEPS/TASKS:
```yaml
    steps:
    # [Descrição da categoria de ações - ex: Configuração inicial do ambiente]
    - task: TaskName@Version
      displayName: 'Action Name'
    
    # [Descrição do processamento principal - ex: Build e transpilação]
    - task: AnotherTask@Version
      displayName: 'Processing Action'
    
    # [Descrição de ações condicionais - ex: Executa testes se habilitado]
    - task: ConditionalTask@Version
      condition: ${{ parameters.someCondition }}
      continueOnError: true
      displayName: 'Conditional Action'
```

### PADRÕES ESPECÍFICOS POR TIPO DE PIPELINE:

#### Para Pipelines de BUILD (CI):
Comente estas fases típicas:
- **Configuração inicial**: Tags, checkout, setup de ferramentas
- **Autenticação**: Registry NPM, Docker, etc.
- **Processamento**: Instalação dependências, linter, build, testes
- **Versionamento**: Git tags, commits automáticos
- **Publicação**: Artifacts, packages, containers

#### Para Pipelines de DEPLOY (CD):
Comente estas fases típicas:
- **Preparação**: Validação, templates, diffs
- **Autenticação**: Login em clusters, serviços
- **Configuração**: Repositórios Helm, registries
- **Deploy**: Aplicação de manifests, helm upgrade
- **Verificação**: Health checks, logs
- **Rollback**: Rollback automático em falhas

### CORREÇÕES TÉCNICAS OBRIGATÓRIAS:
- ✅ Corrija indentação (2 espaços por nível)
- ✅ Valide sintaxe YAML
- ✅ Corrija tipos de parâmetros
- ✅ Ajuste condições malformadas
- ✅ Consistência em referências de variáveis
- ✅ Preserve TODA funcionalidade existente

### MODELO DE EXEMPLO VISUAL:
```yaml
# ==================================================================
# Pipeline: Build VSIX Extension - Empacotamento de Extensões
# -----------------------------------------------------
# Pipeline para build, teste e empacotamento de extensões Azure DevOps
# incluindo suporte a linter, testes unitários e versionamento automático
# ==================================================================

parameters:
  # ==================================================================
  # Parâmetros para habilitar capacidades
  # ==================================================================
  - name: enableTests
    default: true
    displayName: 'Executar Testes'

  # ==================================================================
  # Configuração de Empacotamento
  # ==================================================================
  - name: packageFolder
    type: string
    default: 'dist'
    displayName: 'Pasta de empacotamento'

# ==================================================================
# Estágios do Pipeline
# ==================================================================
stages:
  # Stage Principal: Build, teste e empacotamento da extensão VSIX
  - stage: BuildAndTest
    displayName: 'Build & Tests'
    jobs:
    - job: build
      steps:
      # Configuração inicial do ambiente
      - task: NodeTool@0
        displayName: 'Setup Node.js'
      
      # Execução de build e testes
      - task: Npm@1
        condition: ${{ parameters.enableTests }}
        displayName: 'Run Tests'
```

**EXECUTE AGORA**: Aplique todos esses padrões ao pipeline fornecido, mantendo a funcionalidade intacta.
