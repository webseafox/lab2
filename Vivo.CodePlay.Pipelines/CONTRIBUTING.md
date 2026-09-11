# Guia de Contribuição - CodePlay Framework

> **🤝 Contribua com o ecossistema de pipelines da Vivo seguindo os princípios do InnerSource**

---

## 🚀 Novo por aqui?

Consulte primeiro o [Quickstart](/framework/docs/quickstart.md) para aprender a **usar** os pipelines existentes.

Este guia é para quem deseja **contribuir** com novos pipelines ou melhorias no framework.

---

## 📋 Sumário

1. [Antes de Contribuir](#-antes-de-contribuir)
2. [Fluxo de Decisão](#-fluxo-de-decisão)
3. [Contribuindo com o Framework](#-contribuindo-com-o-framework)
4. [Criando um Tech Product (Exceção)](#-criando-um-tech-product-exceção)
5. [Fazendo Fork de um Pipeline](#-fazendo-fork-de-um-pipeline)
6. [Processo de Pull Request](#-processo-de-pull-request)
7. [Ferramentas Recomendadas](#-ferramentas-recomendadas)

---

## 🎯 Antes de Contribuir

### Princípio Fundamental

> **"Se preocupe com o desenvolvimento do código e deixe o framework cuidar da construção, garantia de qualidade e segurança e entrega do software."**

### Verifique Primeiro

Antes de criar qualquer pipeline novo, **SEMPRE** verifique:

1. ✅ **Existe um pipeline pronto?** → Consulte o [Catálogo de Pipelines](https://dvps.redecorp.azr/portal/catalog/pipelines)
2. ✅ **Pode adaptar um existente?** → Verifique os templates em `/framework/pipelines/`
3. ✅ **Leu as diretrizes?** → Arquivo obrigatório: [`GUIDELINES.md`](./GUIDELINES.md)
4. ✅ **Conhece as premissas?** → Leia as [Premissas do Framework](https://dvps.redecorp.azr/portal/codeplay/framework/premissas)

### Canal de Suporte

Comunidade e Orientação DevOps: [Canal DevEx - Teams](https://teams.microsoft.com/l/channel/19%3A8fbd00946cf044d7a844182ac71e6aa1%40thread.tacv2/Azure%20DevOps?groupId=038b4415-d6dd-42ce-92e5-31a8e2a13bf8&tenantId=9744600e-3e04-492e-baa1-25ec245c6f10)

---

## 🔀 Fluxo de Decisão

### Diagrama do Processo

```
┌─────────────────────────────────────────────────────────────────┐
│  🚀 Preciso de um pipeline para minha aplicação                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │ Existe pipeline no catálogo? │
              └───────────────────────────────┘
                     │              │
                    SIM            NÃO
                     │              │
                     ▼              ▼
        ┌────────────────┐  ┌─────────────────────────┐
        │ ✅ Use o       │  │ Entre em contato com    │
        │ pipeline       │  │ equipe DevOps           │
        │ existente      │  └─────────────────────────┘
        └────────────────┘              │
                                        ▼
                         ┌───────────────────────────────┐
                         │ Atende 80% dos casos comuns? │
                         └───────────────────────────────┘
                                │              │
                               SIM            NÃO
                                │              │
                                ▼              ▼
                   ┌────────────────┐  ┌─────────────────────┐
                   │ 🏗️ FRAMEWORK   │  │ 📦 TECH_PRODUCT     │
                   │ Contribua no   │  │ Crie em             │
                   │ /framework/    │  │ /tech_products/     │
                   └────────────────┘  │ + Carta de Exceção  │
                                       └─────────────────────┘
```

### Critérios para Contribuir no Framework

Sua contribuição deve ir para `/framework/` se:

- ✅ Atende **pelo menos 80%** das necessidades comuns para o tipo de aplicação
- ✅ É **reutilizável** por múltiplos times/projetos
- ✅ Segue as [premissas do framework](https://dvps.redecorp.azr/portal/codeplay/framework/premissas)
- ✅ Possui **documentação completa**
- ✅ Implementa **capacidades padronizadas** (Build & Tests, Security Analysis, Package & Publish, Deploy)

### Critérios para Tech Product (Exceção)

Seu pipeline deve ir para `/tech_products/<SIGLA>/` se:

- ⚠️ Atende **menos de 80%** dos casos comuns
- ⚠️ É **específico** para um único time/projeto
- ⚠️ Possui requisitos **muito particulares** que não se generalizam
- ⚠️ Depende de **tecnologias legadas** ou proprietárias

> **⚠️ IMPORTANTE**: Mesmo em exceções, você **DEVE** seguir os padrões do framework!
> Somos a mesma empresa, todos devem e podem se beneficiar de melhorias e capacidades implementadas.

---

## 🏗️ Contribuindo com o Framework

### Passo 1: Alinhe com a Equipe DevOps

Antes de começar a codificar:

1. Entre no [canal DevEx](https://teams.microsoft.com/l/channel/19%3A8fbd00946cf044d7a844182ac71e6aa1%40thread.tacv2/Azure%20DevOps?groupId=038b4415-d6dd-42ce-92e5-31a8e2a13bf8&tenantId=9744600e-3e04-492e-baa1-25ec245c6f10)
2. Apresente sua necessidade e proposta
3. Valide se há aderência com o framework
4. Defina escopo e responsabilidades

### Passo 2: Crie sua Branch

```bash
# Clone o repositório
git clone https://dev.azure.com/telefonica-vivo-brasil/DevOps/_git/Vivo.CodePlay.Pipelines

# Crie uma branch descritiva
git checkout -b feature/framework-<tipo>-<descricao>

# Exemplos:
# feature/framework-ci-build-golang
# feature/framework-cd-deploy-ecs
# feature/framework-template-sast-veracode
```

### Passo 3: Estruture seu Pipeline

**Para pipelines de CI** (`/framework/pipelines/ci/`):

```
framework/pipelines/ci/build-<tipo-build>/
├── pipeline.yaml           # Pipeline
├── README.md               # Documentação obrigatória
```

**Para pipelines de CD** (`/framework/pipelines/cd/`):

```
framework/pipelines/cd/deploy-<tipo-deploy>/
├── pipeline.yaml           # Pipeline
├── README.md               # Documentação obrigatória
```

**Para templates compartilhados** (`/framework/templates/`):

> **⚠️ IMPORTANTE**: Evite ao máximo o uso de templates. Prefira sempre **custom tasks**.
> Utilize o tech product [azdo-custom-task](https://code.redecorp.br/platform-code/applications/create/template%3Adefault%2Fazdo-custom-task) para criar suas custom tasks.

```
framework/templates/
├── <nome-template>.yaml    # Template reutilizável
└── README.md               # Documentação do template
```

### Passo 4: Siga as Premissas do Framework

#### Parâmetros (camelCase)

```yaml
parameters:
  - name: artifactRepositoryUrl
    type: string
    default: "https://default-repo.com"
    displayName: "URL do repositório de artefatos"
    
  - name: enableUnitTests
    type: boolean
    default: true
    displayName: "Habilita a execução de testes unitários"
```

#### Variáveis (UPPER_SNAKE_CASE)

```yaml
variables:
  SOME_DEFAULT_URL: "https://example.com"
  SOME_ENV_VAR: "value"
```

#### Stages Padrão

```yaml
stages:
  - stage: BuildAndTests
    displayName: 'Build & Tests'
    # Compilar, testar e validar o código

  - stage: SecurityAnalysis
    displayName: 'Security Analysis'
    dependsOn: BuildAndTests
    # Análise de segurança e gates

  - stage: PackageAndPublish
    displayName: 'Package & Publish'
    dependsOn: SecurityAnalysis
    # Empacotar e publicar artefatos

  - stage: Deploy
    displayName: 'Deploy'
    dependsOn: PackageAndPublish
    # Implantação no ambiente
```

### Passo 5: Formate o Pipeline

Utilize o prompt para formatar o pipeline de acordo com as melhores práticas:

```text
Formate o pipeline #pipeline.yaml de acordo com #/framework/docs/PROMPT_FORMAT_PIPELINE.md
```

### Passo 6: Documente no README.md

Utilize o prompt para criar a documentação:

```text
Crie a documentação do pipeline #pipeline.yaml de acordo com #/framework/docs/PROMPT_CREATE_DOC.md
```

Para atualizar documentação existente:

```text
Atualize a documentação do pipeline #pipeline.yaml de acordo com #/framework/docs/PROMPT_UPDATE_DOC.md
```

### Passo 7: Crie um Pipeline de Testes

Crie um exemplo de repositório de teste em: [testes-codeplay-framework](https://dev.azure.com/telefonica-vivo-brasil/DVPS%20-%20DEVOPS/_git/testes-codeplay-framework)

O exemplo deve conter tudo que o pipeline precisa para funcionar (código fonte, scripts, etc).

**Dica**: Passe um parâmetro para definir a branch do CodePlay a ser utilizada:

```yaml
parameters:
- name: codePlayBranchName
  type: string
  default: 'master' 

resources:
  repositories:
    - repository: CodePlay
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: ${{ parameters.codePlayBranchName }}
      endpoint: CodePlay

extends:
  template: /framework/pipelines/ci/build-<seu-pipeline>/pipeline.yaml@CodePlay
```

### Passo 8: Valide antes do PR

Antes de criar o Pull Request, **SEMPRE** execute:

```bash
# Setup inicial (apenas na primeira vez)
export AZURE_DEVOPS_PAT=seu_token_aqui
make setup-complete

# Validação
make validate-pipelines
```

O relatório será gerado em `./reports/validation-report.md`.

---

## 📦 Criando um Pipeline em Tech Product (Exceção)

> **⚠️ Use apenas quando sua necessidade NÃO atende 80% dos casos comuns**

### Passo 1: Documente a Exceção

Você **DEVE** criar uma [Carta de Exceção](https://dvps.redecorp.azr/portal/codeplay/framework/modelo-carta-de-excecao) explicando:

- Por que o framework não atende sua necessidade
- Quais são os requisitos específicos
- Plano de remediação (se aplicável)
- Aprovação dos responsáveis

### Passo 2: Estruture o Pipeline

```
tech_products/<SIGLA>/<nome-do-tech-product>/
├── pipeline.yaml           # Pipeline principal
├── README.md               # Documentação obrigatória
├── OWNERS.md               # Responsáveis pelo tech product
└── carta-excecao.md        # Carta de exceção obrigatória
```

> **Nota**: O padrão foi atualizado para seguir o modelo do framework, porém os pipelines legados podem permanecer na estrutura antiga.

### Passo 3: Mesmo em Exceção, Siga o Padrão!

**OBRIGATÓRIO**: Mesmo sendo um tech product específico, você **DEVE**:

- ✅ Usar a estrutura de stages padrão
- ✅ Reutilizar templates do framework quando possível
- ✅ Seguir convenções de nomenclatura (parâmetros em camelCase, variáveis em UPPER_SNAKE_CASE)
- ✅ Documentar completamente
- ✅ Validar antes do PR (`make validate-pipelines`)

---

## 🔀 Fazendo Fork de um Pipeline

> **⚠️ ATENÇÃO**: Ao optar por fazer um fork, você deve assinar o termo de responsabilidade e carta de risco, e **não terá prioridade no suporte**.

Use fork apenas para mudanças significativas que só fazem sentido para o escopo do seu projeto:

1. Navegue até o repositório do pipeline original
2. Copie o conteúdo do arquivo `pipeline.yaml` para a pasta da sua sigla em `/tech_products/<SIGLA>/`
3. Faça as alterações necessárias
4. Execute `make validate` para garantir que o pipeline esteja correto
5. Realize testes e code review antes de publicar
6. Crie um pull request
7. **Assine a [carta de exceção](https://dvps.redecorp.azr/portal/codeplay/framework/modelo-carta-de-excecao)**

> **Lembre-se**: Ao fazer fork, você assume a responsabilidade pela manutenção e suporte do pipeline.

---

## 🔄 Processo de Pull Request

### Checklist Pré-PR

- [ ] Li o [`GUIDELINES.md`](./GUIDELINES.md)
- [ ] Li as [Premissas do Framework](https://dvps.redecorp.azr/portal/codeplay/framework/premissas)
- [ ] Executei `make validate-pipelines` ✅
- [ ] Criei/atualizei `README.md`
- [ ] Testei o pipeline no [repositório de testes](https://dev.azure.com/telefonica-vivo-brasil/DVPS%20-%20DEVOPS/_git/testes-codeplay-framework)
- [ ] (Se tech_product) Criei a carta de exceção

### Templates de PR

- **Alterações no Framework**: Use o template [framework.md](/.azuredevops/pull_request_template/framework.md)
- **Alterações em Tech Products**: Use o template [pull_request_template.md](/.azuredevops/pull_request_template/pull_request_template.md)

### Criando o PR

1. **Título descritivo**: `feat(framework): adiciona pipeline CI para Golang`
2. **Descrição completa**: O que foi feito, por que, como testar
3. **Link para testes**: Pipeline executado com sucesso
4. **Relatório de validação**: Output do `make validate-pipelines`
5. **Reviewers**: Adicione a equipe DevOps

### Aprovação

- **Framework**: Requer aprovação da Arquitetura DevOps
- **Tech Products**: Requer aprovação de 2 revisores + DevOps

---

## 🔧 Ferramentas Recomendadas

### VS Code Extensions

| Extensão | Descrição |
|----------|-----------|
| ⭐ [YAML Embedded Languages](https://marketplace.visualstudio.com/items?itemName=harrydowning.yaml-embedded-languages) | Syntax highlighting para scripts em YAML |
| ⭐ [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens) | Git supercharged |
| ⭐ [YAML](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) | Validação YAML |
| [REST Client](https://marketplace.visualstudio.com/items?itemName=humao.rest-client) | Testar APIs |
| [Conventional Commits](https://marketplace.visualstudio.com/items?itemName=vivaxy.vscode-conventional-commits) | Padronização de commits |

### Comandos Úteis

```bash
# Setup inicial
export AZURE_DEVOPS_PAT=seu_token_aqui
make setup-complete

# Validar pipelines
make validate                    # Validação geral
make validate-pipelines          # Valida CI e CD
make validate-ci                 # Apenas pipelines CI
make validate-cd                 # Apenas pipelines CD
make validate-custom PIPELINE=<path>  # Pipeline específico

# Ajuda
make help                        # Lista todos os comandos
```

### Aceleradores (Prompts)

| Prompt | Uso |
|--------|-----|
| `PROMPT_FORMAT_PIPELINE.md` | Formatar pipeline segundo padrões |
| `PROMPT_CREATE_DOC.md` | Criar documentação do pipeline |
| `PROMPT_UPDATE_DOC.md` | Atualizar documentação existente |

---

## 📚 Referências

- [Portal CodePlay](https://dvps.redecorp.azr/portal/codeplay/framework/)
- [Premissas do Framework](https://dvps.redecorp.azr/portal/codeplay/framework/premissas)
- [Evolução de Pipelines](https://dvps.redecorp.azr/portal/codeplay/framework/evolucao)
- [Modelo de Documentação](https://dvps.redecorp.azr/portal/codeplay/framework/documentacao)
- [Carta de Exceção](https://dvps.redecorp.azr/portal/codeplay/framework/modelo-carta-de-excecao)

### 📋 ADRs - Decisões Arquiteturais

As decisões arquiteturais são documentadas através de ADRs (Architecture Decision Records):

| Pasta | Escopo |
|-------|--------|
| [`/doc/adr/`](/doc/adr/) | Decisões do **DevOps Corporativo** (ambientação, políticas, padrões gerais) |
| [`/framework/docs/adr/`](/framework/docs/adr/) | Decisões específicas do **CodePlay Framework** (pipelines, templates, capacidades) |

**Exemplos de ADRs:**
- Convenção de environments
- Artifacts registry
- CI e CD desacoplados
- Estágios de AppSec nos pipelines

> **💡 Dica**: Consulte os ADRs antes de propor mudanças arquiteturais. Se sua contribuição envolver uma nova decisão arquitetural, crie um ADR seguindo o [padrão de Michael Nygard](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions).

---

> **🎯 Lembre-se**: O InnerSource é uma jornada de colaboração. Sua contribuição fortalece todo o ecossistema DevOps da Vivo!
