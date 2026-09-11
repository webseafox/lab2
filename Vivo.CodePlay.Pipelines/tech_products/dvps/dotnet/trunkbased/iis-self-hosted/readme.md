# Dotnet (.NET) + IIS Self Hosted

Implantacao de `Aplicativos Dotnet` para `IIS` (OnPremises).

### Capacidades
* Lite
  * **Constroi**, **Testa** e **Empacota** projeto `Dotnet`.
  * **Bump automatico** de numero de versao e tag.
  * Upload de logs para **Auditoria**
* Gold
  * **Sonar Scan** para projetos **Maven Solo** e **Multimodulos**
  * **Fortify Scan**
  * **SCA**

### Como usar

:::info[Sobre os exemplos abaixo]
* Alguns comentarios sao previsoes onde ficariam de outros templates.
:::

```yaml title=".azuredevops/azure-pipeline-ci.yml"
trigger:
  branches:
    include:
      - 'master'
      - 'main'
      - 'codeplay'
  paths:
    exclude:
      - .azuredevops/*cd.*
      - .azuredevops/*pr.*
parameters:
- name: environment
  displayName: 'Ambiente padrao para implantacao.'
  type: string
  default: dev
  values:
  - dev
  # - esteira1
  # - esteira2
  # - esteira3
  # - preprod
  - production
  # - prodlike

- name: vivonow_chg
  displayName: 'Numero CHG do VivoNow, somente para "production"'
  default: CHG0000001

resources:
  repositories:
  - repository: CodePlay
    name: DevOps/Vivo.CodePlay.Pipelines
    type: git
    ref: refs/heads/master
    endpoint: CodePlay

extends:  
  template: /tech_products/dvps/dotnet/trunkbased/iis-self-hosted/lite-ci.yaml@CodePlay
  # template: /tech_products/dvps/dotnet/trunkbased/iis-self-hosted/gold-ci.yaml@CodePlay
  # template: /tech_products/dvps/dotnet/trunkbased/iis-self-hosted/platinum-ci.yaml@CodePlay
  # template: /tech_products/dvps/dotnet/trunkbased/iis-self-hosted/diamond-ci.yaml@CodePlay
  parameters:
    # Nomes de variable groups (opcional)
    #   Usado basicamente para substituir valores e segredos dos arquivos 'config/{environment}/*.yaml'
    #   que iram compor o deployment do kubernetes
    variable_groups:
      - azdo-team-project-variables
      - fe-document-manager

    # Valores aceitaveis sao [dev | test | production | esteira1 | esteira2 | preprod | prodlike]
    # Valor padrao 'dev'
    environment: ${{ parameters.environment }}

    # Numero do CHG para validacao no VivoNow (⚠️ OBRIGATORIO para 'production')
    vivonow_chg: ${{ parameters.vivonow_chg }}

    # Endereco de implantacao no servidor
    #   IISWebAppManagementOnMachineGroup > WebsitePhysicalPath
    website_physical_path: "S:\Sistema_Web"
    
    # Nome do WebSite registrado no IIS
    #   IISWebAppManagementOnMachineGroup > [WebsiteName, ParentWebsiteNameForVD, AppPoolName, StartStopRecycleAppPoolName, VirtualApplication]
    website_name: "TiSimplesProjeto"

```

```yaml title=".azuredevops/azure-pipeline-cd.yml"
trigger: none

parameters:
- name: environment
  displayName: 'Ambiente padrao para implantacao.'
  type: string
  default: dev
  values:
  - dev
  - esteira1
  - esteira2
  - esteira3
  - preprod
  - production
  - prodlike

- name: vivonow_chg
  displayName: 'Numero CHG do VivoNow, somente para "production"'
  default: CHG0000001

resources:
  repositories:
  - repository: CodePlay
    name: DevOps/Vivo.CodePlay.Pipelines
    type: git
    ref: refs/heads/master
    endpoint: CodePlay

extends:  
  template: /tech_products/dvps/dotnet/trunkbased/iis-self-hosted/lite-ci.yaml@CodePlay
  # template: /tech_products/dvps/dotnet/trunkbased/iis-self-hosted/gold-ci.yaml@CodePlay
  # template: /tech_products/dvps/dotnet/trunkbased/iis-self-hosted/platinum-ci.yaml@CodePlay
  # template: /tech_products/dvps/dotnet/trunkbased/iis-self-hosted/diamond-ci.yaml@CodePlay
  parameters:
    # Gov app acronym para a service connection ex 'aks-xyzk-brsouth-dev',
    kubernetes_connection: aks-kcli-brsouth-${{ parameters.environment }}
    resource_group: rg-aks-kcli-brsouth-${{ parameters.environment }}
    # Nomes de variable groups (opcional)
    #   Usado basicamente para substituir valores e segredos dos arquivos 'config/{environment}/*.yaml'
    #   que iram compor o deployment do kubernetes
    variable_groups:
      - azdo-team-project-variables
      - fe-document-manager

    # Valores aceitaveis sao [dev | test | production | esteira1 | esteira2 | preprod | prodlike]
    # Valor padrao 'dev'
    environment: ${{ parameters.environment }}

    # Numero do CHG para validacao no VivoNow (⚠️ OBRIGATORIO para 'production')
    vivonow_chg: ${{ parameters.vivonow_chg }}

    # Endereco de implantacao no servidor
    #   IISWebAppManagementOnMachineGroup > WebsitePhysicalPath
    website_physical_path: "S:\Sistema_Web"
    
    # Nome do WebSite registrado no IIS
    #   IISWebAppManagementOnMachineGroup > [WebsiteName, ParentWebsiteNameForVD, AppPoolName, StartStopRecycleAppPoolName, VirtualApplication]
    website_name: "TiSimplesProjeto"

```

## Dependencias e configuracoes

### Configuracoes no `Azure DevOps`

### Service Connections

Confira dentro do seu projeto se existem as seguintes `Service Connections`:

> Voce pode encontrar seguindo essa rota no menu do Azure DevOps `[XXX - SEU PROJETO]` > `Project Settings` > `Service Connections`

* Azure DevOps Api Generic
* CodePlay
* DevOpsSharedResources
* governanceapi
* VIVO_SONARQUBE

> Algumas das **Service Connections** devem ser compatilhadas atraves do projeto `DevOps` > `Project Settings` > `Service Connections`


### Ambientes 

Confira dentro do seu projeto se existem os seguintes ambientes:

> Voce pode encontrar seguindo essa rota no menu do Azure DevOps `[XXX - SEU PROJETO]` > `Pipelines` > `Environments`

* `deploy-dev`
* `deploy-esteira[1...N]`
* `deploy-preprod`
* `deploy-production`
* `deploy-prodlike`

### Arquivos dentro do `Azure Repos` (git)

> Antes de executar verifique se o seu repositorio tem esses arquivos com essas configuracoes minimas.

```
📂.azuredevops
 ┣ 📜sonar-project.properties
 ┗ 📜sonar.env
📜catalog-info.yaml
```

```yaml title="catalog-info.yaml"
metadata:
  name: mfe-...-v[1...N]
  annotations:
    techarch.governance-app.acronym: 'dip'
    techarch.governance-app.module: 'common-domain'
    sonarqube.org/project-key: 'mfe-...'
    vivo.io/kubernetes-k8s-namespace-dev: 'dip-dev'
    vivo.io/kubernetes-k8s-namespace-esteira[1...N]: 'dip-esteira[1...N]'
    vivo.io/kubernetes-k8s-namespace-preprod: 'dip-preprod'
    vivo.io/kubernetes-k8s-namespace-production: 'dip-production'
    vivo.io/kubernetes-k8s-namespace-prodlike: 'dip-prodlike'
```
