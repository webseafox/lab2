# Implantação MuleSoft

Faz parte de um grupo de **modelos de pipelines** para publicação de `pacotes MuleSoft` **Azure Artifacts** e implantação via pipelines separadas de CI/CD.

## Capacidades
* Lite
  * **Constroi**, **Testa** e **Empacota** projeto `Java` x `Maven`
  * Adaptavel a modelos de projetos **Maven Solo** e **Multimodulos** (*desde que o **pom.xml** parent fique na raiz*)
  * **Bump automático** de número de versão e tag
  * **Constrói** e **Empurra** uma imagem docker (usando o `runtime.Dockerfile`)
  * Publica o projeto no **Kubernetes** usando o **ACR** (*Azure Container Registry*)
  * Upload de logs para **Auditoria**
* Gold
  * **Sonar Scan** para projetos **Maven Solo** e **Multimodulos**
  * **Fortify Scan**
  * **SCA**

## Como usar

### `.azuredevops/azure-pipeline-ci.yml`

```yaml
trigger:
  - dev
  - esteira01
  - esteira02
  - preprod
  - prodlike
  - master
  - release/*

parameters:
- name: ENV_CONFIG_NAME
  displayName: Ambiente
  type: string
  default: dev
  values:
  - dev
  - esteira01
  - esteira02
  - preprod
  - prodlike
  - master

resources:
  repositories:
    - repository: CodePlay
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: refs/heads/feat/pipeline-fenix-davi
      endpoint: CodePlay

extends:
  template: /tech_products/dvps/java/trunkbased/mule-soft/gold-ci.yml@CodePlay
  # template: /tech_products/dvps/java/trunkbased/mule-soft/lite-ci.yml@CodePlay
  parameters:
    ENV_CONFIG_NAME: ${{parameters.ENV_CONFIG_NAME}}
```

### `.azuredevops/azure-pipeline-cd.yml`
```yaml
trigger: none

parameters:
- name: ENV_CONFIG_NAME
  displayName: Ambiente
  type: string
  default: dev
  values:
  - dev
  - esteira01
  - esteira02
  - preprod
  - prodlike
  - master

- name: packageVersion
  displayName: Versão do pacote
  type: string
  default: ""

resources:
  repositories:
    - repository: CodePlay
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: refs/heads/feat/pipeline-fenix-davi
      endpoint: CodePlay

extends:
  template: /tech_products/dvps/java/trunkbased/mule-soft/gold-cd.yml@CodePlay
  # template: /tech_products/dvps/java/trunkbased/mule-soft/lite-cd.yml@CodePlay
  parameters:
    ENV_CONFIG_NAME: ${{parameters.ENV_CONFIG_NAME}}
    packageVersion: ${{parameters.packageVersion}}
```

## Dependências e configurações

### Ambientes dentro do seu projeto (`AzureDevOps > Pipelines > Environments`)

* `deploy-dev`
* `deploy-esteira[1...N]`
* `deploy-lib`
* `deploy-preprod`
* `deploy-prodlike`
* `deploy-producao`

### Arquivos dentro do `Azure Repos` (git)

> Antes de executar verifique se o seu repositorio tem esses arquivos com essas configurações mínimas.

```
📂.azuredevops
 ┣ 📜azure-pipeline-ci.yml
 ┣ 📜azure-pipeline-cd.yml
 ┣ 📜sonar-project.properties
📜catalog-info.yaml
📜pom.xml
```

`./catalog-info.yaml`
```yaml  
  metadata:
    name: ms-...-v[1...N]
    annotations:
      techarch.governance-app.acronym: 'dip'
      techarch.governance-app.module: 'common-domain'
      sonarqube.org/project-key: ''
      arqtech.telefonica.com.br/language-version: '[7, 8, 11, 17, 19, 21]'
      vivo.io/kubernetes-k8s-namespace-dev: 'dip-dev'
      vivo.io/kubernetes-k8s-namespace-esteira[1...N]: 'dip-esteira[1...N]'
      vivo.io/kubernetes-k8s-namespace-preprod: 'dip-preprod'
      vivo.io/kubernetes-k8s-namespace-production: 'dip-production'
      vivo.io/kubernetes-k8s-namespace-prodlike: 'dip-prodlike'
```

`./pom.xml`
```xml  
<?xml version="1.0" encoding="UTF-8"?>
<project ...>
  <groupId>br.com.tlf.dip</groupId> 
  <artifactId>ms-...-v[1...N]</artifactId>
  <version>1.0.0</version>
  ...
</project>
```