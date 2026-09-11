# 📌 Azure DevOps Custom Tasks - Node.js Templates

Bem-vindo ao repositório de templates para criação de **Custom Tasks** no **Azure DevOps** usando **Node.js**! 🚀

# Sumário

1.Introdução

2.Sobre o Repositório

3.Visão Geral

4.Estrutura do Projeto

5.Começando

6.Execução Completa

7. Avançado

8. Problemas Comuns e Avisos

9. Documentação Oficial

10. Fluxo de CI/CD/CT

11. Sugestão para pipeline.yaml

12. Acesso ao Ambiente de Pré-Produção

13. Disponibilizar Versão Pré-Produção

14. Publicação em Produção

15. Links de Referência

16. Feedback e Reports de Erros

## 🛠 Sobre o Repositório

Este repositório contém modelos pré-configurados para facilitar a criação de **Custom Tasks** para **Azure Pipelines**. Cada template fornece uma estrutura pronta para:

- Criar novas **tasks personalizadas** em **Typescript**.
- Configurar o **manifesto (`task.json`)** corretamente.
- Implementar scripts eficientes para automação no **Azure DevOps**.
- Empacotar e publicar tasks com **`tfx-cli`**.
# Azure Devops Task


# Azure Devops Task

## Visao geral

Um [custom task](https://learn.microsoft.com/en-us/azure/devops/extend/develop/add-build-task?view=azure-devops) permite que a implementação de tarefas como build, test, package, deploy sejam desacopladas do pipeline principal.
Essas tarefas são empacotadas com um manifesto (task.json) que define seus metadados, entradas (inputs), saídas (outputs), variáveis, e requisitos de execução. O código da tarefa pode ser implementado em Node.js, PowerShell, Bash, mas recomendamos utilizar Typescript devido diversas vantagens e padronizações internas.
A custom task tem diversas vantagens, entre elas:
- É cross-platform (funciona em windows, macos,linux) se implementado com Typescript
- É testável
- Possibilita teste local, não necessitando do Azure Devops.

## Implementação e estrutura

Resumo da arquitetura geral deste projeto em:

```
.                             | Pasta raiz do projeto
├📁Tasks                 🚀 Tudo acontece aqui!
│ ├📁HelloWorld               ⚙️ Essa e a sua Task!
│ │ └📁v4                     |
│ │   ├🧪tests                |
│ │   │ ├ _suite.ts           🧪 Seus testes
│ │   │ └ L0.ts               |
│ │   ├ HelloWorld.ts         ⭐ Essa e a sua task!
│ │   ├ icon.png              |
│ │   ├ package.json          |
│ │   ├ task.json             📜 Manifesto da Task
│ │   └ tsconfig.json         |
│ └ tsconfig.v4.json          | Config comun do typescript
├📁images                     |
│ └ vss.png                   |
├ .versionrc.js               | Config do Bump de versao
├ package.json                |
├ README.md                   |
└ vss-extension.json          📜 Manifesto da extensao
```

> ⚠️ `Importante`:
>
> A máquina de desenvolvimento deve executar a versão mais recente do Node para garantir que o código escrito seja compatível com o ambiente de [produção no agente e a](https://nodejs.org/en/download/) versão não visualizada mais recente do azure-pipelines-task-lib.
>
> Se necessario atualize o arquivo [task.json](https://learn.microsoft.com/pt-br/azure/devops/extend/develop/add-build-task?view=azure-devops#taskjson-components) de acordo com o seguinte comando:

`task.json`
```json
"execution": {
   "Node16": {
     "target": "HelloWorld.js"
   }
 }
```
## Comecando

Checagem completa:

```bash
npm run clean && npm i && npm run coverage && npm run release && npm run package
```

### Combinacao windows por partes

```bash
npm run clean
npm i --ignore-scripts=true

cd Tasks/Base64/v5 && npm i && npm run compile && npm i --omit=dev && cd -

npm run release && npx tfx-cli extension create --root . --manifest-globs vss-extension.json

git push --follow-tags origin main

```

### Criando uma nova Task

```bash
npm run new:task
```


### Scripts comuns da raiz do projeto:

```bash

# Remove all files in .gitignore (node_modules, test-results.xml, *.vsix...).
npm run clean

# Install all dependencies of all packages in project.
npm i

# Compile all tasks and modules.
npm run build

# Compile and test all tasks and modules.
npm run test

# Compile, test and scan coverage on all tasks and modules.
npm run coverage

# Based on conventinal commits, bump all versioned files on .versionrc.js.
npm run release

# Same that 'release' and push commits and tags.
npm run release:full

# Clean, reinstall dependencies, build, optimise dependencies, package vsix and reinstall all dependencies.
npm run package

# CLI util to create an new Task.
npm run new:task

```

### Scripts comuns de cada `package.json`:

```bash

# Remove compiled files from current tsconfig.json
npm run clean

# Compile current tsconfig.json
npm run compile

# Integration for Debug Task
npm run debug

# Integration for Debug Test
npm run debug:test

# Compile and run tests on _suite.js
npm run test

# Compile and run converages from _suite.js
npm run coverage

```


### Avancado

Visao detalhada do projeto:

```
.                             | Pasta raiz do projeto
├ 📁azuredevops               |
│ └ azure-pipeline.yml        |
├ 📁scripts                   |
│ ├ new-task.ts               | Script para criar uma Task nova
│ └ string-case.ts            |
├ 📁vscode                    |
│ └ launch.json               | Configuracoes de Debug
├📁Tasks                 🚀 Tudo acontece aqui!
│ ├📁Common                   | Modulo comum (⚠️ Importe sempre!)
│ │ └📁v4                     |
│ │   ├🧪tests                |
│ │   │ └ _suite.ts           🧪 Seus testes
│ │   ├ .gitignore            |
│ │   ├ .taskkey              |
│ │   ├ BuiltInVariables.ts   |
│ │   ├ Common.ts             |
│ │   ├ package.json          |
│ │   ├ ParamsUtil.ts         |
│ │   ├ RuntimeUtil.ts        |
│ │   ├ TaskLibUtils.ts       |
│ │   └ tsconfig.json         |
│ ├📁HelloWorld               ⚙️ Essa e a sua Task!
│ │ └📁v4                     |
│ │   ├🧪tests                |
│ │   │ ├ _suite.ts           🧪 Seus testes
│ │   │ └ L0.ts               |
│ │   ├ .gitignore            |
│ │   ├ .taskkey              |
│ │   ├ HelloWorld.ts         ⭐ Essa e a sua task!
│ │   ├ icon.png              | Icone da Task
│ │   ├ package.json          |
│ │   ├ task.json             📜 Manifesto da Task
│ │   └ tsconfig.json         |
│ └ tsconfig.v4.json          | Config comun do typescript
├📁docs                       | Arquivos de documentacao
│ ├ new-task-1.png            |
│ └ new-task-2.png            |
├📁images                     |
│ └ vss.png                   | Icone da extensao
├ .editorconfig               |
├ .eslintrc.js                |
├ .gitignore                  |
├ .versionrc.js               | Config do Bump de versao
├ CHANGELOG.md                |
├ CONTRIBUTING.md             |
├ LICENSE                     |
├ package.json                |
├ README.md                   |
├ task-version.js             | Personalizacao do standard-version para Bump dos arquivos task.json
├ tsconfig.json               |
└ vss-extension.json          📜 Manifesto da extensao
```



## Problemas comuns e avisos.

> As imagems precisam ser `quadradas` no formato `png` e ter no minimo 128x128.

> O `id` que deve ser único esta atrelado ao nome do repo excluindo o azdo-tasks-.

> Nao mude o `id` da task nunca! Mesmo se quiser renomear uma task.

> Use sempre o `npm` evite o `yarn`.
```

## 📖 Documentação
- [Guia Oficial do Azure DevOps para Custom Tasks](https://learn.microsoft.com/en-us/azure/devops/extend/develop/add-build-task)
- [tfx-cli (Azure DevOps CLI)](https://learn.microsoft.com/en-us/azure/devops/cli)

## Fluxo de CI/CD/CT 

'''mermaid
    A["CI"] -- Commit in Branch Master --> B("Pipeline Trigger")
    B --> C{"SKIP_TESTS"}
    C -- TRUE --> D["Package"]
    C -- FALSE --> E["CT"]
    n1["CD"] --> n5["Run Build"]
    E --> n7["Unit Tests"]
    D -- "vss-extension.Version" --> n8["Tag Version"]
    n7 --> D
    n5 --> n9["Environment"]
    n9 --prod--> n12["Validate Git Tag"]
    n9 --preprod--> n12
    n12 --> n13["branch master?"]
    n13 -- YES --> n14["Checkout Tag"]
    n13 -- NO --> n15["Build fail"]
    n14 --> n16["Package"]
    n16 --> n17["Package extension (vsix)"]
    n17 --> n18["Publish in Marketplace"]

    A@{ shape: rect}
    n1@{ shape: rect}
    n9@{ shape: diam}
    n13@{ shape: diam}
    n10@{ shape: rounded}
    style A fill:#FFFFFF
    style n1 fill:#FFFFFF '''

## 📖 Sugestão para pipeline.yaml
```name: '[$(Date:yyyyMMdd)$(Rev:.r)]'

pool:
  vmImage: "ubuntu-latest"

trigger:
  branches:
    include:
      - master
      - main
      - custom-task-certe
  paths:
    exclude:
      - README.md        
      - .gitignore        
      - .vscode/          
      - .github/         
      - docs/             
      - tests/            
      - package-lock.json 
      - node_modules/     
      - .azuredevops/

#pool: 
#  name: GeneralPurposeLinuxAgents

parameters:
  - name: environment
    displayName: "Escolha o ambiente para publicar"
    type: string
    default: CI
    values:
      - CI
      - preprod
      - producao

  - name: EXTENSION_NAME
    type: string
    default: "Quickstart Test"

  - name: TAG
    type: string
    default: ""

  - name: SKIP_TESTS
    type: boolean
    default: false

variables:
  - name: System.debug
    value: "true"

  - name: EXTENSION_ID
    value: ${{ replace(variables['Build.Repository.Name'], 'azdo-task-', '') }}

resources:
  repositories:
    - repository: CodePlay
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: refs/heads/feature/master
extends:
  template: /tech_products/dvps/custom-tasks/pipeline_ctasks_ci_ct_cd_v1.yaml@CodePlay
  parameters:
    environment: "${{parameters.environment}}"
    EXTENSION_NAME: "${{parameters.EXTENSION_NAME}}"
    EXTENSION_ID: "$(EXTENSION_ID)"
    SKIP_TESTS: "${{parameters.SKIP_TESTS}}"
    TAG: "${{parameters.TAG}}" ```

## Acessando ambiente de Pré Produção

O acesso à organização de Pré Produção deve ser obtido através de solicitação.
Url de acesso:
https://dev.azure.com/telefonica-vivo-brasil-preprod/

## Como Deixar Disponível a Versão em Pré-Produção

Deve-se realizar o run do pipeline manualmente através do Azure Pipelines, inserindo o valor da tag gerada no CI previamente .

## Como e Quando Publicar para Produção
Depois de testar as devidamente as funcionalidades da custom task e suas possíveis integrações com outras ferramentas estejam validadas, poderá prosseguir para o processo de publicação em produção (org tefenoica-vivo-brasil) da mesma maneira que a publicação em pré-producção.

## Links de Referência
Uma custom taks que pode servir de referência em relação à estrutura:
https://dev.azure.com/telefonica-vivo-brasil/DevOps/_git/azdo-task-quickstart
Um link de execução da pipeline desta custom task:
https://dev.azure.com/telefonica-vivo-brasil/DevOps/_build/results?buildId=918958&view=logs&s=859b8d9a-8fd6-5a5c-6f5e-f84f1990894e

## Feedback e Reports de Erros

Este tópico é reservado para sugestões de melhorias ou correções na documentação ou até mesmo melhorias e novas funcionalidades da automação.

