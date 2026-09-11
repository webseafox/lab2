# Validação de Pipelines CodePlay Framework

> **TL;DR**: Valide seus pipelines **antes de abrir o PR** com `make validate-pipelines`. Isso garante qualidade, evita retrabalho e acelera a aprovação.

---

## 🎯 Por Que Validar?

### O Problema

Sem validação automatizada, problemas comuns passam despercebidos:

- ❌ **Parâmetros duplicados** que causam comportamento inesperado
- ❌ **Valores sensíveis expostos** (senhas, tokens) em defaults
- ❌ **Documentação desatualizada** que não reflete o pipeline real
- ❌ **Convenções ignoradas** (nomenclatura, estrutura)
- ❌ **Tasks obrigatórias ausentes** (security scans, testes)

**Resultado**: PRs rejeitados, retrabalho, atrasos e pipelines frágeis em produção.

### A Solução

O **Pipeline Validator** automatiza a verificação de **políticas** que garantem:

✅ **Qualidade**: Código aderente às melhores práticas do CodePlay  
✅ **Segurança**: Detecção automática de exposição de secrets  
✅ **Documentação**: README consistente com parâmetros do pipeline  
✅ **Padronização**: Convenções de nomenclatura e estrutura  
✅ **Confiabilidade**: Validação antes do merge, não depois

---

## 🚀 Como Usar (3 Passos)

### 1️⃣ Setup Inicial (Uma Única Vez)

Configure o ambiente virtual e instale o validador:

```bash
# Define o token do Azure DevOps
export AZURE_DEVOPS_PAT="seu-token-aqui"

# Setup completo (cria venv + instala validador)
make setup-complete
```

> **💡 Dica**: Adicione o `export AZURE_DEVOPS_PAT` no seu `~/.zshrc` ou `~/.bashrc` para não precisar definir toda vez.

### 2️⃣ Valide Antes de Commitar

Antes de criar seu PR, valide as mudanças:

```bash
# Validação completa (CI + CD)
make validate-pipelines

# Ou validar apenas CI
make validate-ci

# Ou validar apenas CD
make validate-cd
```

### 3️⃣ Corrija os Problemas Identificados

O validador mostrará exatamente onde estão os problemas:

```text
🔴 CRITICAL: security_sensitive_defaults
   Arquivo: framework/pipelines/ci/build-api/pipeline.yaml
   Linha 12: Parâmetro 'apiToken' possui valor sensível no default

🟠 HIGH: parameters_documented
   Arquivo: framework/pipelines/ci/build-api/README.md
   Parâmetro 'environment' não está documentado
```

Corrija os problemas e valide novamente até obter **✅ Validação bem-sucedida**.

---

## 📋 Políticas de Validação

O validador aplica **16 políticas ativas** em 4 categorias:

### 🔧 Parâmetros (7 políticas)

- **Duplicação**: Parâmetros duplicados ou defaults inconsistentes
- **Nomenclatura**: camelCase obrigatório
- **Tipos**: Consistência entre declaração e uso
- **Uso**: Parâmetros declarados mas nunca usados

### 🔒 Segurança (1 política)

- **Valores Sensíveis**: Detecção de tokens, senhas, secrets em defaults

### 📚 Documentação (7 políticas)

- **README Obrigatório**: Todo pipeline deve ter README.md
- **Consistência**: Parâmetros documentados = parâmetros no pipeline
- **Completude**: Descrição, tipo, default e exemplo para cada parâmetro
- **Qualidade**: Seções obrigatórias, ordem correta, exemplos práticos

### ⚙️ Tasks (1 política)

- **Tasks Obrigatórias**: Security scans, testes, validações requeridas

> **Ver detalhes**: Execute `make validate-list` para listar todas as políticas ativas.

---

## 🎨 Comandos Úteis

### Validação Básica

```bash
make validate-pipelines      # Valida todos os pipelines (CI + CD)
make validate-ci             # Valida apenas pipelines CI
make validate-cd             # Valida apenas pipelines CD
```

### Validação Customizada

```bash
# Validar um pipeline específico
make validate-custom PIPELINE=framework/pipelines/ci/build-helm/pipeline.yaml

# Mudar formato do report (markdown, json, html)
make validate-custom FORMAT=json OUTPUT_DIR=reports

# Usar políticas customizadas
make validate-custom POLICIES=config/custom-policies.yaml
```

### Informações

```bash
make validate-list           # Lista todas as políticas ativas
make validate-help           # Ajuda completa do validador
make venv-status             # Status do ambiente virtual
```

---

## 💼 Integração com Pull Requests

### Workflow Recomendado

1. **Desenvolva** suas mudanças no pipeline
2. **Valide localmente** com `make validate-pipelines`
3. **Corrija** todos os problemas identificados
4. **Commit** as mudanças
5. **Abra o PR** - o validador rodará automaticamente
6. **Revisão** será mais rápida com validação prévia ✅

### O Que Esperar no PR

Quando você abre um PR, o validador executa automaticamente e **comenta no PR** com:

- ✅ **Lista de políticas validadas** (16 ativas)
- 🔴 **Problemas críticos** que bloqueiam merge
- 🟠 **Problemas graves** que devem ser corrigidos
- 🟡 **Avisos** sobre melhorias recomendadas
- 📊 **Relatório completo** em Markdown

**Dica**: Valide localmente antes do PR para evitar loops de correção → commit → validação.

---

## 🔧 Troubleshooting

### Erro: "Ambiente virtual não encontrado"

```bash
make setup-complete
```

### Erro: "AZURE_DEVOPS_PAT não definida"

```bash
export AZURE_DEVOPS_PAT="seu-token-aqui"
make install
```

### Erro: "Pipeline não encontrado"

Verifique se você está no diretório raiz do projeto:

```bash
cd /caminho/para/Vivo.Codeplay.Pipelines
make validate-pipelines
```

### Validação falha mas não sei o motivo

Execute com mais detalhes:

```bash
make validate ARGS="--verbose"
```

---

## 🤖 Automatizando Correções de Documentação

Após rodar a validação, você pode usar o **relatório gerado** como contexto para automatizar correções de documentação usando os prompts do framework.

### Como Funciona

1. **Execute a validação** e gere o relatório:

```bash
make validate-custom PIPELINE=framework/pipelines/cd/deploy-liquibase/pipeline.yaml
```

1. **Use o relatório como contexto** nos prompts de atualização:

```markdown
Adeque a documentação de #file:pipeline.yaml em #file:README.md usando como referência 
as issues encontradas em #file:pipeline_validation_report.md, mantenha toda a estrutura 
existente e modifique apenas dados que apresentem inconsistências.
```

### Prompts Disponíveis

O framework possui prompts especializados em `/framework/docs/`:

| Prompt | Quando Usar | Contexto Recomendado |
|--------|-------------|----------------------|
| **[PROMPT_CREATE_DOC.md](./PROMPT_CREATE_DOC.md)** | Criar README para pipeline novo | Pipeline YAML |
| **[PROMPT_UPDATE_DOC.md](./PROMPT_UPDATE_DOC.md)** | Atualizar README existente | Pipeline YAML + Relatório de Validação |
| **[PROMPT_FORMAT_PIPELINE.md](./PROMPT_FORMAT_PIPELINE.md)** | Formatar pipeline YAML | Pipeline YAML |

### Exemplo Prático

```markdown
# 1. Valide o pipeline específico
make validate-custom PIPELINE=framework/pipelines/cd/deploy-helm/pipeline.yaml

# 2. Use o relatório para corrigir a documentação
# No GitHub Copilot Chat:
Adeque a documentação de #file:framework/pipelines/cd/deploy-helm/pipeline.yaml 
em #file:framework/pipelines/cd/deploy-helm/README.md usando as issues de 
#file:reports/pipeline_validation_report.md como referência. Corrija especialmente 
os problemas de gravidade HIGH e MEDIUM.
```

### Benefícios

- ✅ **Correções Precisas**: IA sabe exatamente o que corrigir
- ✅ **Menos Erros**: Usa issues reais detectadas pelo validador
- ✅ **Contexto Completo**: Relatório + Pipeline + README = resultado perfeito
- ✅ **Retrabalho Zero**: Corrige tudo de uma vez

> **💡 Dica Pro**: Referencie issues específicas do relatório para correções pontuais:
> "Corrija apenas a issue [002] REQUIRED_TASKS do #file:pipeline_validation_report.md"

---

## 📖 Documentação Técnica Completa

Esta documentação foca no **uso prático** do validador. Para detalhes técnicos sobre:

- 🏗️ **Arquitetura do validador**
- 🔌 **Como criar novas políticas**
- 🧪 **Testes e desenvolvimento**
- 📦 **Publicação de versões**
- 🔧 **Configuração avançada**

Acesse o repositório oficial: **[codeplay-framework-validator](https://dev.azure.com/telefonica-vivo-brasil/DVPS%20-%20DEVOPS/_git/codeplay-framework-validator)**

---

## 🎓 Contexto e Decisão

A implementação deste validador foi formalizada através da ADR (Architecture Decision Record):

👉 **[ADR 0003 - Executar Script de Validação](./adr/0003-executar-script-de-validação.md)**

### Por Que Isso Importa?

Um dos **pilares do CodePlay Framework** é:

> **Padronização, convenções e confiabilidade da documentação**

O validador garante que:

- ✅ Pipelines sigam as convenções estabelecidas
- ✅ Documentação esteja sempre sincronizada com o código
- ✅ Problemas sejam detectados **antes** de chegarem à produção
- ✅ Qualidade seja mantida mesmo com múltiplos contribuidores

---

## 🆘 Precisa de Ajuda?

- 🏗️ **Código do Validador**: [codeplay-framework-validator](https://dev.azure.com/telefonica-vivo-brasil/DVPS%20-%20DEVOPS/_git/codeplay-framework-validator)
- 💬 **Dúvidas**: Abra uma issue ou entre em contato com o time de DevOps

---

**Lembre-se**: Validar localmente = PRs aprovados mais rápido = Deploy mais rápido = Todo mundo feliz! 🎉
