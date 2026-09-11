# NodeJs to Visual Studio Extension

Implantacao de `Extenssoes (Tasks, Decorators, etc.)` para o `Marketplace do Azure DevOps`, usando **NodeJs**.

### Capacidades
* Lite
  * **Constroi**, **Testa** e **Empacota** projeto `NodeJs` + `Npm` + `Tfx CLI`.
  * **Bump automatico** de numero de versao e tag.
  * **Constroi** e **Empura** uma versao para o `Artifacts`.
  * Publica a extenssao no **Marketplace do Azure DevOps**. 
  * Upload de logs para **Auditoria**
* Gold
  * *Em breve!*

### Como usar

:::info[Sobre os exemplos abaixo]
* Alguns comentarios sao previsao onde ficarao as referencias futuras de maturidade.
:::

`.azuredevops/azure-pipeline-ci.yml`
```yaml title=".azuredevops/azure-pipeline-ci.yml"
name: '[$(Date:yyyyMMdd)$(Rev:.r)]'

trigger:
  branches:
    include:
      - master

resources:
  repositories:
    - repository: CodePlay
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: refs/heads/master

extends:
  template: /tech_products/dvps/nodejs/trunkbased/azdo-extension/lite-ci.yaml@CodePlay
  parameters:
    # Pasta para empacotar, diretorio do onde estara o vss-extension.json e os arquivos transpilados. 
    # Ex. "dist", "package"
    # padrao e './' para custom tasks simples usando javascript puro
    packageFolder: "./dist"
```

`.azuredevops/azure-pipeline-cd.yml`
```yaml title=".azuredevops/azure-pipeline-cd.yml"
name: '[$(Date:yyyyMMdd)$(Rev:.r)]'

trigger: none

parameters:
- name: environment
  displayName: 'Escolha o ambiente para publicar'
  type: string
  default: producao
  values:
  - preprod
  - producao

resources:
  repositories:
    - repository: CodePlay
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: refs/heads/master

extends:
  template: /tech_products/dvps/nodejs/trunkbased/azdo-extension/lite-cd.yaml@CodePlay
  parameters:
    environment: "${{parameters.environment}}"
```

## Dependencias e configuracoes

### Configuracoes no `Azure DevOps`

### Service Connections

Confira dentro do seu projeto se existem as seguintes `Service Connections`:

> Voce pode encontrar seguindo essa rota no menu do Azure DevOps `[XXX - SEU PROJETO]` > `Project Settings` > `Service Connections`

* `vso-telefonica-vivo-brasil`**`-preprod`**
* `vso-telefonica-vivo-brasil`

> Essas **Service Connections** devem ser compatilhadas atraves do projeto `DevOps` > `Project Settings` > `Service Connections`


### Ambientes 

Atualmente existem somente **2 ambientes**, respectivamente duas **Organizacoes no Azure DevOps**:

* `telefonica-vivo-brasil`**`-preprod`**
* `telefonica-vivo-brasil`

### Arquivos dentro do `Azure Repos` (git)

> Antes de executar verifique se o seu repositorio ou se o seu tem esses arquivos com essas configuracoes minimas.

#### Exemplo para javascript puro
``` 
📚tasks ______________> 🏠 Agrupamento de custom tasks
 ┣ 📂MyTaskOne _______> 
 ┃ ┣ 📣task.json _____> Manisfesto de custom task
 ┃ ┣ 📜index.js ______> Codigo da custom task
 ┃ ┗ 🖼️icon.png ______> Icone da custom task
 ┣ 📂MyTaskTwo _______> ...
 ┃ ┣ 📣task.json _____> ...
 ┃ ┣ 📜index.js ______> ...
 ┗ ┗ 🖼️icon.png ______> ...
📚images
 ┗ 🖼️vss.png _________> Icone da extenssao
📜.nvmrci ____________> Versao do nodejs
📣package.json _______> Manifesto do NPM
📣vss-extension.json _> Manifesto da extenssao
```


`package.json`
```json title="package.json"
{
  "version": "1.0.0",
  
  "scripts": {
    "test": "...", // (opcional)
    "coverage": "...", // (opcional)
    "build": "...", // (recomendado)
    ...
  }
  ...
}
```

`.nvmrc`
```ini title=".nvmrc"
v18.18.0
```

#### Exemplo para Typescript com recursos avancados

Visao de arquivos de `codigo fonte`

``` 
 🏁(root)
 ┣ 📚dist _______________> 🏠 Arquivos transpilados
 ┃ ┗ ...
 ┣ 📂images
 ┃ ┗ 🖼️vss.png __________> Icone da extenssao
 ┣ 🛠️tasks ______________> 🚧 Codigos typescript custom tasks
 ┃ ┣ 📂MyTaskOne ________> 
 ┃ ┃ ┣ 📜task.json ______> 📣 Manisfesto de custom task
 ┃ ┃ ┣ 📜index.ts _______> Codigo da custom task
 ┃ ┃ ┣ 📜package.json ___> 📣 Manifesto do NPM da task
 ┃ ┃ ┗ 🖼️icon.png _______> Icone da custom task
 ┃ ┣ 📂MyTaskTwo ________> ...
 ┃ ┃ ┣ 📜task.json ______> ...
 ┃ ┃ ┣ 📜index.ts _______> ...
 ┃ ┃ ┣ 📜package.json ___> ...
 ┃ ┗ ┗ 🖼️icon.png _______> ...
 ┣ 📜.nvmrci ____________> Versao do nodejs
 ┣ 📜package.json _______> Manifesto do NPM
 ┣ 📜READEME.md _________> Documentacao de uso
 ┣ 📜LICENCE.md _________> Licenca de uso
 ┗ 📜vss-extension.json _> 📣 Manifesto da extenssao
```

Visao de arquivos e pastas do `pacote` na pasta `dist`, `dist` e normalmente utilizada para arquivos transpilados do typescript pelo `tsc` ou pelo `webpack`.

```
 🏁(root)
 ┣ 📚dist _________________> 🏠 Arquivos transpilados
 ┃ ┣ 📂images
 ┃ ┃ ┗ 🖼️vss.png __________> Icone da extenssao
 ┃ ┣ 📂tasks ______________> ...
 ┃ ┃ ┣ 📂MyTaskOne ________> ...
 ┃ ┃ ┃ ┣ 📜task.json ______> ...
 ┃ ┃ ┃ ┣ 📜index.js _______> Codigo trasnpilado
 ┃ ┃ ┃ ┗ 🖼️icon.png _______> ...
 ┃ ┃ ┣ 📂MyTaskTwo ________> ...
 ┃ ┃ ┃ ┣ 📜task.json ______> ...
 ┃ ┃ ┃ ┣ 📜index.js _______> ...
 ┃ ┃ ┗ ┗ 🖼️icon.png _______> ...
 ┃ ┣ 📜READEME.md _________> Documentacao de uso
 ┃ ┣ 📜LICENCE.md _________> Licenca de uso
 ┃ ┗ 📜vss-extension.json _> 📣 Manifesto da extenssao
 ┣ 📂images
 ┃ ┗ ...
 ┣ 🛠️tasks
 ┃ ┗ ...
 ┗...
```

`package.json`
```json title="package.json"
{
  "version": "1.0.0",
  
  "scripts": {
    "test": "...", // (opcional)
    "coverage": "...", // (opcional)
    // Comando transpilar e copiar os arquivos 
    // para a pasta 'dist'
    "build": "...", // (obrigatorio)
    ...
  }
  ...
}
```
> Tudo o que esta entre `[` `]` sao seus valores.

`vss-extension.json`
```json title="vss-extension.json"
{
  "$schema": "https://json.schemastore.org/vss-extension.json",
  "manifestVersion": 1,
  "id": "vivo-azdo-[my-extension]",
  "version": "4.3.2",
  "name": "Vivo [My Extension]",
  "description": "Vivo [My Extension]",
  "publisher": "telefonica-vivo-devops-brasil",
  "public": false,
  "targets": [
    {
      "id": "Microsoft.VisualStudio.Services"
    }
  ],
  "categories": [
    "Azure Pipelines"
  ],
  "icons": {
    "default": "images/vss.png"
  },
  "screenshots": [],
  "content": {
    "details": {
      "path": "README.md"
    },
    "license": {
      "path": "LICENSE"
    }
  },
  "links": {
    "support": {
      "uri": "https://wikicorp.telefonica.com.br/display/AC/Abertura+de+chamados+DevOps+-+VivoNow"
    }
  },
  "repository": {
    "type": "git",
    "uri": "https://dev.azure.com/devops/azdo-task-my-extensio"
  },
  "tags": [
    "azure devops",
    "pipeline",
    "task"
  ],
  "files": [
    {
      "path": "tasks/[MyTaskOne]"
    },
    {
      "path": "tasks/[MyTaskTwo]"
    },
    {
      "path": "images",
      "addressable": true
    }
  ],
  "contributions": [
    {
      "id": "[MyTaskOne]",
      "type": "ms.vss-distributed-task.task",
      "targets": [
        "ms.vss-distributed-task.tasks"
      ],
      "properties": {
        "name": "tasks/[MyTaskOne]"
      }
    },
    {
      "id": "[MyTaskTwo]",
      "type": "ms.vss-distributed-task.task",
      "targets": [
        "ms.vss-distributed-task.tasks"
      ],
      "properties": {
        "name": "tasks/[MyTaskTwo]"
      }
    }
  ]
}

```

`.nvmrc`
```ini title=".nvmrc"
v18.18.0
```

