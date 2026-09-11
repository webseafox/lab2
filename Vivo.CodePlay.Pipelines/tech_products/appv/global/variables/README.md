# Shared Variables

Arquivo de variáveis compartilhadas reutilizável em múltiplos pipelines AppV.

## 🎯 Descrição

O arquivo `shared.yml` contém **variáveis comuns** que podem ser incluídas e referenciadas por pipelines que necessitam de configurações padronizadas do ecossistema AppV.

Este arquivo complementa as variáveis definidas em:
- `variables-global.yml` - Variáveis gerais do AppV
- `variables-java.yml` - Variáveis específicas Java
- `variables-docker.yml` - Configurações Docker
- `variables-argocd.yml` - Configurações ArgoCD dinâmicas

## 🚀 Quick Start (5 minutos)

Inclua o arquivo em seu pipeline:

```yaml
variables:
- template: /tech_products/appv/global/variables/shared.yml
```

Após incluir, todas as variáveis definidas em `shared.yml` estarão disponíveis para uso nos steps.

## 🏗️ Matriz de Capacidades

| Capacidade | Suporte | Descrição |
|------------|---------|-----------|
| Variáveis Compartilhadas | ✅ | Reutilização em múltiplos pipelines |
| Padrões de Nomenclatura | ✅ | Convenções consolidadas |
| Defaults Inteligentes | ✅ | Valores derivados de contexto |

## 🏗️ Estrutura do Pipeline

```
variables/
├── shared.yml             # Variáveis compartilhadas (este arquivo)
├── variables-global.yml   # Variáveis gerais AppV
├── variables-java.yml     # Configurações Java
├── variables-docker.yml   # Configurações Docker
├── variables-argocd.yml   # Configurações ArgoCD
└── README.md              # Documentação
```

## 📋 Parâmetros Disponíveis

O arquivo `shared.yml` não define parâmetros de entrada. É um arquivo de definição de variáveis puro que exporta variáveis para uso em pipelines.

Para ver as variáveis específicas definidas, consulte o conteúdo do arquivo `shared.yml`.

## 🔧 Dependências Externas

- Nenhuma dependência externa obrigatória
- Pipeline pai que inclui o arquivo deve estar em ambiente Azure DevOps

## 💡 Comportamentos Customizados

### Inclusão em Stages

```yaml
stages:
- stage: my_stage
  variables:
  - template: /tech_products/appv/global/variables/shared.yml
  jobs:
  - job: MyJob
    steps:
    - script: echo $(VARIABLE_FROM_SHARED)
```

### Composição com Outras Variáveis

Pode ser combinado com outras templates de variáveis:

```yaml
variables:
- template: /tech_products/appv/global/variables/shared.yml
- template: /tech_products/appv/global/variables/variables-java.yml
```

## 🔐 Variáveis de Ambiente

Todas as variáveis definidas em `shared.yml` são convertidas para variáveis de ambiente e podem ser acessadas via:
- `$(VARIABLE_NAME)` - em scripts YAML
- `$env:VARIABLE_NAME` - em PowerShell
- `$VARIABLE_NAME` - em Bash

## 💻 Exemplos Práticos

### Exemplo 1: Usar shared.yml em um Job

```yaml
trigger:
  - main

stages:
- stage: Build
  variables:
  - template: /tech_products/appv/global/variables/shared.yml
  jobs:
  - job: BuildJob
    pool:
      name: GeneralPurposeLinuxAgentsCI
    steps:
    - script: |
        echo "Project: $(PROJECT_NAME)"
        echo "Registry: $(DOCKER_REGISTRY)"
      displayName: "Echo Shared Variables"
```

### Exemplo 2: Combinar multiple variable templates

```yaml
variables:
- template: /tech_products/appv/global/variables/shared.yml
- template: /tech_products/appv/global/variables/variables-java.yml
- template: /tech_products/appv/global/variables/variables-docker.yml

stages:
- stage: CI
  jobs:
  - job: Build
    steps:
    - script: |
        echo "Using $(SHARED_VAR)"
        echo "Java: $(JAVA_VERSION)"
        echo "Docker: $(DOCKER_VERSION)"
```

## ❓ FAQ

**P: Qual é a diferença entre shared.yml e outras files de variáveis?**
R: `shared.yml` contém variáveis reutilizadas em múltiplos cenários. As outras são específicas (Java, Docker, ArgoCD).

**P: Posso sobrescrever variáveis de shared.yml?**
R: Sim! Variáveis definidas posteriormente sobrescrevem as anteriores em casos de conflito.

**P: shared.yml é obrigatório?**
R: Não. Use conforme necessário em seus pipelines.

## 📝 Decisões Tomadas

### Decisão 1: Consolidação de Variáveis

- **Data**: 2026-06-24
- **Motivador**: Evitar duplicação de variáveis comuns entre pipelines
- **Descrição**: Criação de `shared.yml` para centralizar variáveis reutilizadas, reduzindo manutenção e aumentando consistência

---

**Última atualização**: 2026-06-24

