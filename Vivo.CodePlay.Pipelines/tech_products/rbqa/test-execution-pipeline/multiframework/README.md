# Pipeline de Execução Automatizada com Cypress e Playwright

Este diretório contém o padrão oficial de execução de testes automatizados do **RBQA**.

A solução orquestra execução em CI com Docker, scripts de execução e integração com Azure DevOps. O fluxo foi desenhado para suportar três modos explícitos a partir de um dispatcher único: Cypress, Playwright puro e Playwright BDD, sem duplicar a camada de orquestração.

---

## Estrutura Geral da Solução

A execução dos testes é composta pelas seguintes camadas:

| Camada | Responsabilidade |
|--------|-----------------|
| Pipeline Azure DevOps | Orquestração do fluxo |
| `docker_test_execution.sh` | Bootstrap do container e variáveis de ambiente |
| `exec_test.sh` | Dispatcher do framework selecionado |
| `exec_test_cypress.sh` | Execução Cypress e geração de evidências |
| `exec_test_playwright.sh` | Execução Playwright puro |
| `exec_test_playwright_bdd.sh` | Execução Playwright com Cucumber/BDD |
| `RunResults` | Estrutura de evidências |

---

## Estrutura de Diretórios

```text
multiframework/
├── scripts/
│   ├── docker_test_execution.sh   # Orquestra execução via Docker
│   ├── exec_test.sh               # Dispatcher do framework
│   ├── exec_test_cypress.sh       # Núcleo da execução Cypress
│   ├── exec_test_playwright.sh    # Núcleo da execução Playwright puro
│   └── exec_test_playwright_bdd.sh # Núcleo da execução Playwright BDD
│
├── templates/
│   └── test_execution.yml         # Template de execução
│
└── pipeline_rbqa_test_execution_multiframework_v1.yml  # Pipeline versionada
```

---

Responsável por:

- Preparar o ambiente de execução
- Invocar scripts de execução
- Publicar artefatos ao final da execução

> A pipeline é reutilizável e pode ser consumida por múltiplos projetos.

## Visão de Execução

O fluxo escolhe o framework com base na variável `FRAMEWORK`:

```
Azure DevOps Pipeline
  ↓
docker_test_execution.sh
  ↓
Container Docker
  ↓
exec_test.sh
  ├── cypress  → exec_test_cypress.sh
  ├── playwright → exec_test_playwright.sh
  └── playwright-bdd → exec_test_playwright_bdd.sh
  ↓
RunResults (logs | reports | screenshots)
```

---

## Componentes

### `docker_test_execution.sh`
Script responsável por:

- Subir o container Docker com a imagem definida para o framework escolhido
- Configurar o ambiente de execução
- Mapear variáveis sensíveis via `env-file`
- Delegar a execução para o `exec_test.sh`

### `exec_test.sh`
Dispatcher do container.

- Lê `FRAMEWORK`
- Seleciona o script correto
- Repassa argumentos posicionais, se houver
- Falha explicitamente quando o framework não é suportado
- Resolve `playwright` como fluxo puro e `playwright-bdd` como fluxo BDD

### `exec_test_cypress.sh`
Script responsável por:

- Executar Cypress (`cypress run`)
- Preparar dependências e cache do runtime
- Gerar relatório HTML quando habilitado
- Gerar PDF quando habilitado
- Publicar resultados no ALM Octane quando habilitado
- Consolidar logs, screenshots e metadados em `RunResults`

### `exec_test_playwright.sh`
Script responsável por:

- Executar `npm ci`
- Executar `npx playwright test`
- Usar a configuração nativa do projeto consumidor (`playwright.config.*`)
- Respeitar `playwright.config.*` e `--project` sem forçar override de browser quando o projeto já define a execução
- Publicar apenas relatórios Playwright válidos, ignorando páginas vazias como `No tests found`
- Exibir diagnósticos centralizados de runtime para Node, NPM, Playwright e Cucumber
- Publicar evidências em `playwright-report` e `test-results` quando existirem

### `exec_test_playwright_bdd.sh`
Script responsável por:

- Executar Playwright com Cucumber/BDD no contrato legado do projeto
- Ler `CUCUMBER_PROFILE`, `TAGS`, `HEADLESS`, `RETRY_COUNT` e `PARALLEL_WORKERS`
- Centralizar diagnósticos de runtime em uma única seção, incluindo Cucumber Version
- Registrar `Browser Selection`, `Project` e `Grep Pattern` para facilitar troubleshooting
- Publicar apenas relatórios Playwright válidos, ignorando páginas vazias como `No tests found`
- Publicar logs e consolidação de evidências no padrão legado do fluxo BDD

---

## Fluxo de Execução

### Cypress

```
Azure DevOps Pipeline
  ↓
docker_test_execution.sh
  ↓
exec_test.sh
  ↓
exec_test_cypress.sh
  ↓
Cypress CLI
  ↓
/app/RunResults
```

### Playwright

```
Azure DevOps Pipeline
  ↓
docker_test_execution.sh
  ↓
exec_test.sh
  ↓
exec_test_playwright.sh
  ↓
Playwright Test Runner
  ↓
artefatos do projeto / RunResults conforme o projeto
```

Observação:
- O executor puro do Playwright respeita `playwright.config.*` e `--project` quando definidos no projeto consumidor.
- O browser via CLI só é aplicado quando a execução não está ancorada em config/projeto explícito.

---

## Execução dos Testes

A execução acontece dentro de um container Docker e segue o fluxo abaixo. Algumas etapas são comuns aos dois frameworks e outras são específicas de Cypress.

1. Preparação do ambiente e estrutura de evidências
2. Instalação do Oracle Instant Client em runtime
3. Validação das variáveis Oracle (aviso se ausentes, testes de banco são ignorados)
4. Instalação de dependências (`npm ci` com fallback automático para `npm install` no fluxo Cypress; `npm ci` no fluxo Playwright puro e no Playwright BDD)
5. Instalação dos binários e browsers necessários ao framework
6. Validação de tags nos cenários Cucumber quando `FRAMEWORK=cypress` ou `FRAMEWORK=playwright-bdd` e `TAGS` estiver informado
7. Execução da suíte selecionada pelo dispatcher
8. Consolidação de screenshots e evidências para `RunResults`
9. Geração de relatório HTML quando `GENERATE_REPORT=true` no fluxo Cypress
10. Geração de PDF de evidências quando `GENERATE_PDF=true` no fluxo Cypress
11. Publicação no ALM Octane quando `ALM_UPDATE_OCTANE=true` no fluxo Cypress
12. Geração de metadata e finalização

> As variáveis ALM_* são obtidas através do Variable Group configurado na pipeline.
---
## Mapeamento de Parâmetros

Os parâmetros recebidos pela pipeline são convertidos para variáveis de ambiente consumidas pelos scripts de execução.

| Pipeline Parameter | Variável Interna | Utilização |
|-------------------|------------------|------------|
| `framework` | `FRAMEWORK` | Seleciona o executor a ser utilizado |
| `browser` | `BROWSER` | Browser utilizado durante a execução |
| `tags` | `TAGS` | Filtro de cenários por tag |
| `test_environment` | `ENVIRONMENT` | Ambiente de execução |
| `cucumber_profile` | `CUCUMBER_PROFILE` | Profile utilizado no Playwright BDD |
| `headless` | `HEADLESS` | Define execução com ou sem interface gráfica |
| `retry_count` | `RETRY_COUNT` | Quantidade de reexecuções em caso de falha |
| `parallel_workers` | `PARALLEL_WORKERS` | Número de workers paralelos para execução |
| `generate_report` | `GENERATE_REPORT` | Habilita geração de relatório |
| `generate_pdf` | `GENERATE_PDF` | Habilita geração de PDF |
| `update_octane` | `ALM_UPDATE_OCTANE` | Publicação de resultados no ALM Octane |
| `playwright_install_browsers` | `PLAYWRIGHT_INSTALL_BROWSERS` | Instala browsers Playwright em runtime |

## Controle de Execução

### `framework`

Define qual executor será utilizado pelo dispatcher.

| Valor | Descrição |
|-------|-----------|
| `cypress` | Mantém o fluxo legado de Cypress |
| `playwright` | Executa Playwright puro |
| `playwright-bdd` | Executa Playwright com Cucumber/BDD |

Regra prática:
- `playwright` sempre vai para o executor puro
- `playwright-bdd` sempre vai para o executor BDD

### `tags`

Permite execução parcial baseada em tags (Cucumber):

- Aceita tags do Cucumber como `@api`, `@smoke`
- Executa apenas cenários que possuam a tag informada
- Quando vazio, todos os testes são executados

### `browser`

Define o browser utilizado durante a execução.

#### Playwright

| Valor |
|---------|
| `chromium` |
| `webkit` |

#### Cypress

| Valor |
|---------|
| `chrome` |
| `edge` |
| `firefox` |

> Os browsers suportados dependem do framework selecionado e da imagem utilizada na execução.

### `test_environment`

Define o ambiente de execução utilizado pelos testes.

| Valor | Descrição |
|---------|----------|
| `DEV` | Ambiente de desenvolvimento |
| `HOM` | Ambiente de homologação |
| `PREPROD` | Ambiente pré-produtivo |
| `PRODLIKE` | Ambiente similar à produção |
| Customizado | Projetos consumidores podem definir ambientes adicionais de acordo com sua necessidade |

> O valor é disponibilizado para os scripts através da variável `ENVIRONMENT`.

### `cucumber_profile`

Define o profile do Cucumber usado apenas pelo fluxo `playwright-bdd`.

- Quando vazio, o Playwright puro ignora esse parâmetro
- Quando preenchido, o executor BDD usa o profile informado
- O executor não mantém lista fixa de profiles.
- Novos profiles podem ser criados diretamente no `cucumber.js` do projeto consumidor.
- Para utilização via pipeline, basta disponibilizar o profile no parâmetro `cucumber_profile`.

### `playwright_install_browsers`

Flag booleana que instala os browsers do Playwright no container.

- Aplica-se ao fluxo Playwright puro
- No fluxo BDD, a instalação pode ser feita pela imagem ou pelo bootstrap do projeto consumidor

### `generate_report`

Flag booleana que habilita a geração do relatório HTML ao final da execução no fluxo Cypress.

### `update_octane`

Flag booleana que, quando ativada, publica as evidências no ALM Octane ao final da execução no fluxo Cypress.

- Quando `true`, executa `npm run publish:results`
### `generate_pdf`

Flag que habilita a geração de PDF de evidências a partir do relatório HTML no fluxo Cypress.

- Quando `true`, executa `npm run convert:pdf` utilizando Puppeteer

### `variableGroup`

Nome do Variable Group cadastrado na Library do Azure DevOps.

- Centraliza variáveis sensíveis que antes eram passadas via `.env`
- Evita exposição de credenciais diretamente na pipeline

#### Variáveis Oracle (injetadas via Variable Group)

| Variável | Descrição |
|----------|-----------|
| `ORACLE_DB_USER` | Usuário do banco Oracle |
| `ORACLE_DB_PASSWORD` | Senha do banco Oracle |
| `ORACLE_DB_CONNECT_STRING` | String de conexão Oracle |

> Se variáveis Oracle estiverem ausentes, o script segue sem testes de banco.
> Se estiverem presentes, o script usa o client Oracle pré-instalado na imagem e, se necessário, faz fallback para instalação runtime.

#### Variáveis ALM Octane (obrigatórias quando `update_octane=true`)

| Variável | Descrição |
|----------|-----------|
| `ALM_USERNAME` | Usuário/API key de acesso ao Octane |
| `ALM_HOST` | URL base do Octane |
| `ALM_DOMAIN` | Domínio no Octane |
| `ALM_PROJECT` | Identificador do projeto no Octane |

## Requisitos por Framework

### Cypress

- Projeto com dependências Cypress compatíveis
- Arquivo de testes e configuração compatíveis com o comando `cypress run`
- Estrutura de evidências em `RunResults`

### Playwright

- `package-lock.json` presente para manter instalação reproduzível
- Configuração do Playwright no projeto consumidor, por exemplo `playwright.config.ts` ou `playwright.config.js`
- Dependências do Playwright instaladas pela imagem ou pelo fluxo de build do projeto
- Browsers compatíveis com o runner do container

### Playwright BDD

- `CUCUMBER_PROFILE` definido quando a suíte exigir profile
- Arquivos `cucumber.js`, `features/` e `src/step-definitions/` presentes no projeto consumidor
- Os cenários devem usar o contrato legado de Cucumber para tags, hooks e step definitions

## Considerações de Arquitetura

A evolução da pipeline foi projetada para suportar múltiplos frameworks de automação mantendo a compatibilidade com a solução atual.

As principais decisões adotadas são:

- Manter um único ponto de entrada para execução dos testes através da pipeline RBQA.
- Utilizar um dispatcher (`exec_test.sh`) responsável por direcionar a execução para o framework selecionado.
- Evitar duplicação da lógica de bootstrap, autenticação, montagem de volumes e inicialização do container.
- Permitir que cada modo possua sua própria implementação de execução (`exec_test_cypress.sh`, `exec_test_playwright.sh`, `exec_test_playwright_bdd.sh`), reduzindo acoplamento entre tecnologias.
- Preservar compatibilidade com o fluxo atualmente utilizado pelo Cypress.
- Separar de forma explícita o Playwright puro do Playwright BDD para reduzir ambiguidade de configuração no projeto consumidor.

### Evolução futura

A arquitetura atual foi concebida para permitir a inclusão de novos frameworks através da combinação de:

- Parâmetro `framework` na pipeline.
- Seleção dinâmica de imagem Docker.
- Dispatcher de execução.
- Script específico por framework.

Dessa forma, a introdução de novas tecnologias tende a exigir apenas a criação de uma nova imagem e de um novo script de execução, mantendo inalterada a infraestrutura principal da pipeline.

Para o Playwright, a convenção final ficou assim:

- `framework: cypress` -> Cypress legado
- `framework: playwright` -> Playwright puro
- `framework: playwright-bdd` -> Playwright com BDD/Cucumber

## Segurança e Operação

- A limpeza do agente foi limitada a diretórios do próprio job para evitar impacto em agentes compartilhados.
- O step de pre-heal de permissões não usa elevação de privilégios por conformidade com OPA. Se chown ou chmod falharem, o pipeline registra um aviso e continua, então a imagem ou agent precisa já expor permissões compatíveis para evitar falhas em etapas posteriores.

### Pré-requisitos da imagem de execução
- Node.js e npm compatíveis com o projeto
- Cypress e dependências de browser compatíveis, quando `framework=cypress`
- Playwright e browsers compatíveis, quando `framework=playwright`
- Usuário `node` e comando `runuser` (quando disponíveis)

> O arquivo `.npmrc` do projeto consumidor é opcional. Quando existe, a pipeline injeta `SYSTEM_ACCESSTOKEN` para autenticação em feeds privados; quando não existe, o bootstrap segue sem montar `.npmrc` e a execução continua normalmente.

> O dispatcher não decide a forma de instalação do browser; isso deve ser garantido pela imagem ou pelo bootstrap do próprio projeto consumidor.

---

## Artefatos Gerados

Após a execução do fluxo Cypress, é gerado o diretório `/app/RunResults` com a seguinte estrutura:

```text
/app/RunResults/
├── logs/
│   ├── cypress.log        # saída completa do Cypress
│   └── execution.log      # metadata da execução
│   └── html/              # gerado quando GENERATE_REPORT=true
└── screenshots/           # capturas de falha
```

> Os arquivos JSON do Mochawesome são gerados em `cypress/reports/json` durante a execução e servem como fonte para o relatório HTML.
- Octane Suite Run
- Data e hora da execução
- Versão do Node
- Versão do npm
- Versão do Cypress
- Exit code da execução

No fluxo Playwright, os artefatos ficam sob responsabilidade do projeto consumidor, respeitando a convenção de saída definida pela suíte e pela imagem utilizada.

---

# Exemplo de Uso em Projetos Consumidores

Os projetos podem utilizar a pipeline via template:

```yaml
name: test-execution-multiframework
trigger:
  branches:
    include:
      - master
pr:
  branches:
    include:
      - master
parameters:
- name: framework
  displayName: Framework
  type: string
  default: cypress
  values:
    - cypress
    - playwright
    - playwright-bdd

- name: test_environment
  displayName: Environment
  type: string
  default: PREPROD
  values:
    - PREPROD
    - PRODLIKE

- name: tags
  displayName: "Tags (ex: @smoke)"
  type: string
  default: " "

- name: cucumber_profile
  displayName: "Profile do Cucumber (apenas playwright-bdd)"
  type: string
  default: ""

- name: browser
  displayName: "Browser"
  type: string
  default: chromium
  values:
    - chromium
    - webkit

resources:
  repositories:
    - repository: CodePlay
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: refs/heads/feat/test-playwright
      endpoint: CodePlay

extends:
  template: /tech_products/rbqa/test-execution-pipeline/multiframework/pipeline_rbqa_test_execution_multiframework_v1.yml@CodePlay
  parameters:
    framework: ${{ parameters.framework }}
    tags: ${{ parameters.tags }}
    browser: ${{ parameters.browser }}
    test_environment: ${{ parameters.test_environment }}
    cucumber_profile: ${{ parameters.cucumber_profile }}
    variableGroup: <nome-do-variable-group>
```

### Exemplo com Playwright puro

```yaml
extends:
  template: /tech_products/rbqa/test-execution-pipeline/multiframework/pipeline_rbqa_test_execution_multiframework_v1.yml@CodePlay
  parameters:
    framework: playwright
    variableGroup: <nome-do-variable-group>
    test_environment: PREPROD
```

### Exemplo com Playwright BDD

```yaml
extends:
  template: /tech_products/rbqa/test-execution-pipeline/multiframework/pipeline_rbqa_test_execution_multiframework_v1.yml@CodePlay
  parameters:
    framework: playwright-bdd
    variableGroup: <nome-do-variable-group>
    test_environment: PREPROD
    cucumber_profile: smoke
```

### Browser padrão por framework

| Framework | Browser Padrão |
|------------|----------------|
| Cypress | `chrome` |
| Playwright | `chromium` |
| Playwright BDD | `chromium` |

### Parâmetros da Pipeline

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|---------|-----------|
| `framework` | string | `cypress` | Framework de execução |
| `browser` | string | Framework Default | Browser utilizado na execução |
| `tags` | string | `" "` | Filtro de cenários por tag |
| `test_environment` | string | `PREPROD` | Ambiente de execução |
| `cucumber_profile` | string | `""` | Profile utilizado pelo Playwright BDD |
| `headless` | boolean | `true` | Executa os testes sem interface gráfica |
| `retry_count` | string | `0` | Número de tentativas em caso de falha |
| `parallel_workers` | string | `2` | Quantidade de workers paralelos |
| `playwright_install_browsers` | boolean | `false` | Instala browsers do Playwright durante a execução |
| `generate_report` | boolean | `false` | Geração de relatório HTML |
| `generate_pdf` | boolean | `false` | Geração de PDF de evidências |
| `update_octane` | boolean | `false` | Publicação no ALM Octane |
| `variableGroup` | string | — | Variable Group utilizado pela execução |
---
