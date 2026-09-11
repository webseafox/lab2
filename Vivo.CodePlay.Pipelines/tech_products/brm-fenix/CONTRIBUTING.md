# Guia de Contribuição - BRM Fenix

> **Como contribuir para o framework BRM Fenix e seguir as melhores práticas do CodePlay**

## 📋 Índice

- [Código de Conduta](#código-de-conduta)
- [Como Começar](#como-começar)
- [Fluxo de Trabalho](#fluxo-de-trabalho)
- [Padrões de Código](#padrões-de-código)
- [Testes](#testes)
- [Documentação](#documentação)
- [Pull Requests](#pull-requests)
- [Versionamento](#versionamento)

---

## 🤝 Código de Conduta

Ao contribuir para o BRM Fenix, você concorda em:

- ✅ Manter profissionalismo e respeito com todos os colaboradores
- ✅ Seguir os padrões e diretrizes do CodePlay Framework
- ✅ Priorizar qualidade sobre velocidade
- ✅ Documentar mudanças de forma clara e completa
- ✅ Compartilhar conhecimento e ajudar outros desenvolvedores
- ❌ Não fazer commits diretos em `master` ou branches protegidas
- ❌ Não compartilhar secrets, credenciais ou dados sensíveis

---

## 🚀 Como Começar

### Pré-requisitos

1. **Acesso ao Azure DevOps**
   ```bash
   # Verificar acesso ao repositório
   git clone https://telefonica@dev.azure.com/telefonica/DevOps/_git/Vivo.CodePlay.Pipelines
   cd Vivo.CodePlay.Pipelines/tech_products/brm-fenix
   ```

2. **Ferramentas Instaladas**
   - Git 2.x+
   - YAML Linter (yamllint ou VS Code YAML extension)
   - Markdown Linter (markdownlint)
   - Azure CLI (opcional, para testes)

3. **Conhecimento Necessário**
   - Azure DevOps Pipelines (YAML)
   - Bash Scripting
   - Oracle Cloud Infrastructure (OCI)
   - Kubernetes & Helm
   - Git Flow

### Configuração do Ambiente

```bash
# 1. Fork ou clone o repositório
git clone https://telefonica@dev.azure.com/telefonica/DevOps/_git/Vivo.CodePlay.Pipelines

# 2. Criar branch de trabalho
git checkout -b feature/nome-da-feature

# 3. Instalar linters (opcional)
pip install yamllint
npm install -g markdownlint-cli

# 4. Validar YAML antes de commitar
yamllint tech_products/brm-fenix/**/*.yml
```

---

## 🔄 Fluxo de Trabalho

### Git Flow Adaptado

```
                    ┌─────────────────┐
                    │     master      │ (Produção)
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
              │                             ↓
    ┌─────────┴─────────┐         ┌────────────────┐
    │  hotfix/urgente   │         │    develop     │ (Desenvolvimento)
    └─────────┬─────────┘         └────────┬───────┘
              │                            │
              │                            ├─────────────────────────┐
              │                            │                         │
              │                            ↓                         ↓
              │                   ┌─────────────────┐      ┌─────────────────┐
              │                   │ feature/nova-   │      │  fix/correcao-  │
              │                   │  funcionalidade │      │      bug        │
              │                   └────────┬────────┘      └────────┬────────┘
              │                            │                        │
              │                            └──────────┬─────────────┘
              │                                       │
              │                                       ↓
              │                              ┌─────────────────┐
              │                              │  Pull Request   │
              │                              └────────┬────────┘
              │                                       │
              └───────────────────────────────────────┴──────► merge
```

### Tipos de Branches

| Branch | Propósito | Nomenclatura | Merge para |
|--------|-----------|--------------|------------|
| `master` | Produção | - | - |
| `develop` | Desenvolvimento | - | `master` |
| `feature/*` | Novas funcionalidades | `feature/add-new-provisioner` | `develop` |
| `fix/*` | Correções de bugs | `fix/iac-validation-error` | `develop` |
| `hotfix/*` | Correções urgentes | `hotfix/critical-security-fix` | `master` + `develop` |
| `docs/*` | Documentação | `docs/update-readme` | `develop` |

### Workflow Padrão

1. **Criar branch a partir de `develop`**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/minha-feature
   ```

2. **Fazer alterações e commits**
   ```bash
   git add .
   git commit -m "feat: adicionar validação de nodes OCI"
   ```

3. **Validar localmente**
   ```bash
   # Validar YAML
   yamllint tech_products/brm-fenix/**/*.yml
   
   # Validar Markdown
   markdownlint README.md
   
   # Testar pipeline localmente (se possível)
   az pipelines run --name "BRM-Fenix-CI"
   ```

4. **Push e criar Pull Request**
   ```bash
   git push origin feature/minha-feature
   # Criar PR via Azure DevOps UI
   ```

5. **Code Review e Merge**
   - Aguardar aprovação de pelo menos 1 reviewer
   - Resolver conflitos se necessário
   - Merge para `develop`

---

## 📝 Padrões de Código

### YAML Pipelines

#### Estrutura de Arquivo

```yaml
# ==========================================================================================
# Nome do Arquivo/Componente
#
# Description:
#   Descrição detalhada do propósito e funcionamento
#
# Parameters:
#   - param1: Descrição do parâmetro 1
#   - param2: Descrição do parâmetro 2
#
# Usage Example:
#   template: path/to/template.yml
#   parameters:
#     param1: value1
#
# Best Practices:
#   - Prática 1
#   - Prática 2
# ==========================================================================================

parameters:
  - name: paramName
    type: string
    default: ""

steps:
  - task: CmdLine@2
    displayName: "Descrição Clara"
    inputs:
      script: |
        echo "Script bem formatado"
```

#### Convenções de Nomenclatura

| Elemento | Convenção | Exemplo |
|----------|-----------|---------|
| **Arquivos** | snake_case.yml | `pipeline_initialization.yml` |
| **Parameters** | camelCase | `applicationName`, `ociCliFolder` |
| **Variables** | UPPER_SNAKE_CASE | `OCI_CLI_FOLDER_PATH` |
| **Task Names** | snake_case | `validate_environment_state` |
| **Display Names** | Title Case | `Validate Environment State` |

#### Indentação

```yaml
# ✅ CORRETO - 2 espaços por nível
parameters:
  - name: config
    type: object
    default:
      modelName: ""
      technology: ""

# ❌ INCORRETO - 4 espaços
parameters:
    - name: config
      type: object
```

#### Comentários

```yaml
# ✅ CORRETO - Comentário descritivo
# This task validates the cluster state before deployment
# Ensures cluster is ACTIVE and nodes are in correct state
- task: CmdLine@2
  displayName: "Validate Cluster State"

# ❌ INCORRETO - Comentário óbvio
# Run command
- task: CmdLine@2
```

### Bash Scripts

#### Estrutura

```bash
# ✅ CORRETO
set -e  # Parar em erro

# Variáveis no início
ENVIRONMENT="poc"
ACTION="START"

# Funções reutilizáveis
validate_state() {
    local state=$1
    if [ "$state" != "ACTIVE" ]; then
        echo "❌ Invalid state: $state"
        return 1
    fi
    return 0
}

# Lógica principal
echo "##[section]Starting validation..."
if validate_state "$CLUSTER_STATE"; then
    echo "✅ Validation successful"
else
    echo "##vso[task.logissue type=error;]Validation failed"
    exit 1
fi
```

#### Logging Padronizado

```bash
# Níveis de log
echo "##[debug] Debug information"
echo "##[command] Command being executed"
echo "##[section] Section header"
echo "##[group] Group start"
echo "##[endgroup] Group end"
echo "##[warning] Warning message"
echo "##[error] Error message"

# Emojis para clareza visual
echo "✅ Success message"
echo "❌ Error message"
echo "⚠️ Warning message"
echo "🔍 Info message"
echo "🚀 Start process"
echo "📦 Package/Bundle"
echo "🔧 Configuration"
```

#### Validações

```bash
# ✅ CORRETO - Validar inputs
if [ -z "$ENVIRONMENT" ]; then
    echo "##vso[task.logissue type=error;]ENVIRONMENT not provided"
    exit 1
fi

# ✅ CORRETO - Usar -n e -z para strings
if [ -n "$STATE" ]; then
    echo "State is set: $STATE"
fi

# ❌ INCORRETO - Comparação sem aspas
if [ $STATE == "ACTIVE" ]; then  # Falha se STATE vazio
    echo "Active"
fi

# ✅ CORRETO - Sempre usar aspas
if [ "$STATE" == "ACTIVE" ]; then
    echo "Active"
fi
```

---

## 🧪 Testes

### Validação Local

#### 1. YAML Syntax

```bash
# Validar sintaxe YAML
yamllint -c .yamllint tech_products/brm-fenix/**/*.yml

# Arquivo .yamllint (criar na raiz)
---
extends: default
rules:
  line-length:
    max: 120
  indentation:
    spaces: 2
```

#### 2. Bash Script Validation

```bash
# Instalar shellcheck
sudo apt-get install shellcheck

# Validar scripts inline (extrair de YAML)
grep -A 50 "script: |" pipeline.yml | shellcheck -
```

#### 3. Pipeline Dry-Run

```bash
# Azure DevOps - executar pipeline de teste
az pipelines run \
  --name "BRM-Fenix-Test" \
  --branch feature/minha-feature \
  --parameters config.modelName=api_default
```

### Testes de Integração

**Cenários obrigatórios antes de merge:**

- [ ] Pipeline CI executa com sucesso
- [ ] Pipeline CD executa com sucesso em ambiente de DEV
- [ ] IaC START/STOP executa sem erros
- [ ] Monitoring coleta dados corretamente
- [ ] Locks de ambiente funcionam
- [ ] Rollback funciona em caso de erro

### Checklist de Validação

```markdown
## Validação de Mudanças

- [ ] YAML validado (yamllint)
- [ ] Bash validado (shellcheck)
- [ ] Documentação atualizada (README.md, CONTRIBUTING.md)
- [ ] Variáveis documentadas
- [ ] Logs padronizados (emojis, ##[section])
- [ ] Tratamento de erros adequado
- [ ] Testado em ambiente de DEV
- [ ] Sem secrets/credenciais hardcoded
- [ ] Backwards compatible (ou changelog atualizado)
```

---

## 📚 Documentação

### README.md

- Atualizar quando adicionar novo provisioner, task ou funcionalidade
- Incluir exemplos de uso práticos
- Manter diagramas Mermaid atualizados

### Comentários Inline

```yaml
# ✅ CORRETO - Comentário útil
# This template handles source code checkout with a specific path
# Used to prepare the workspace before running deploy commands
- template: ../../task_groups/checkout/checkout.yml
  parameters:
    repository: self
    path: source_code

# ❌ INCORRETO - Comentário inútil
# Checkout code
- template: ../../task_groups/checkout/checkout.yml
  parameters:
    repository: self
    path: source_code
```

### Changelog

Atualizar `README.md` seção **Changelog** para mudanças significativas:

```markdown
### [1.1.0] - 2026-01-15

#### ✨ Features
- Novo provisioner para backup automatizado
- Suporte para ambiente de staging

#### 🐛 Fixes
- Correção de timeout em wait_pods
- Fix de validação de nodes duplicados

#### 🔧 Improvements
- Logs mais detalhados em deploy
```

---

## 🔍 Pull Requests

### Template de Pull Request

```markdown
## 📋 Descrição

Breve descrição da mudança e motivação.

## 🎯 Tipo de Mudança

- [ ] 🐛 Bug fix (correção de problema)
- [ ] ✨ Feature (nova funcionalidade)
- [ ] 📝 Documentação
- [ ] ⚡ Performance
- [ ] 🔧 Refactoring
- [ ] 🧪 Testes

## 🧪 Como Testar

1. Executar pipeline X
2. Validar saída Y
3. Confirmar Z

## ✅ Checklist

- [ ] YAML validado
- [ ] Documentação atualizada
- [ ] Testado em DEV
- [ ] Sem breaking changes (ou documentado)
- [ ] Logs padronizados
- [ ] Code review solicitado

## 📸 Screenshots (se aplicável)

<!-- Adicionar prints de execução do pipeline -->

## 📚 Referências

- Issue/Task: #123
- Documentação relacionada: [link]
```

### Code Review Guidelines

**Para Reviewers:**

- ✅ Verificar aderência aos padrões de código
- ✅ Validar logs e tratamento de erros
- ✅ Confirmar documentação atualizada
- ✅ Testar em ambiente de DEV (se possível)
- ✅ Sugerir melhorias construtivamente

**Para Autores:**

- ✅ Responder a todos os comentários
- ✅ Fazer ajustes solicitados
- ✅ Atualizar PR description se necessário
- ✅ Re-solicitar review após mudanças

---

## 🏷️ Versionamento

### Semantic Versioning

Seguimos **Semantic Versioning 2.0.0**:

```
MAJOR.MINOR.PATCH

1.2.3
│ │ │
│ │ └─ Patch: Bug fixes, melhorias menores
│ └─── Minor: Novas funcionalidades (backwards compatible)
└───── Major: Breaking changes
```

### Tags no Git

```bash
# Criar tag de release
git tag -a v1.2.0 -m "Release 1.2.0 - Novo provisioner de backup"
git push origin v1.2.0

# Azure DevOps - tags especiais por provisioner
git tag -a brm/latest_iac -m "Latest IaC provisioner"
git tag -a brm/latest_monitoring -m "Latest Monitoring provisioner"
git push origin --tags
```

### Commit Messages

Seguir **Conventional Commits**:

```bash
# Formato
<type>(<scope>): <subject>

<body>

<footer>

# Exemplos
feat(iac): adicionar validação de quota OCI
fix(monitoring): corrigir parsing de status de pods
docs(readme): atualizar exemplos de uso
refactor(lock): simplificar lógica de retry
test(iac): adicionar testes para START/STOP
chore(deps): atualizar OCI CLI para 3.71.0

# Types
feat:     Nova funcionalidade
fix:      Correção de bug
docs:     Documentação
refactor: Refatoração de código
test:     Testes
chore:    Manutenção (deps, configs)
perf:     Performance
style:    Formatação
```

---

## 🎓 Recursos Adicionais

### Documentação Interna

- [CodePlay Framework Guidelines](../../GUIDELINES.md)
- [BRM Fenix Architecture](./docs/ARCHITECTURE.md)
- [Tasks Reference](./docs/TASKS.md)
- [Security Guidelines](./docs/SECURITY.md)

### Documentação Externa

- [Azure DevOps YAML Schema](https://learn.microsoft.com/azure/devops/pipelines/yaml-schema/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [YAML Best Practices](https://yaml.org/spec/1.2/spec.html)

---

## 🆘 Suporte

**Dúvidas ou Problemas?**

- 💬 **Teams:** Canal #brm-fenix-dev
- 📧 **Email:** devops-brm@vivo.com
- 📝 **Azure DevOps:** Criar Work Item no backlog
- 📚 **Wiki:** [BRM Fenix Wiki](https://dev.azure.com/telefonica/DevOps/_wiki/)

---

## 📄 Licença

© 2025 Vivo - Telefónica Brasil  
Proprietary - Internal Use Only

---

**Última Atualização:** 2 de Janeiro de 2026  
**Versão do Guia:** 1.1.0
