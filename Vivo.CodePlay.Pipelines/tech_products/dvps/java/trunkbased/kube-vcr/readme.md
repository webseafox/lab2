# Java Kube + VCR

Implantacao de `Aplicativos Java` para `Kubernetes` (OnPremises) e `Helm Chart` atraves do `VCR` e `kube-config`.

## Capacidades
* Lite
  * **Constroi**, **Testa** e **Empacota** projeto `Java` x `Maven`
  * Adaptavel a modelos de projetos **Maven Solo** e **Multimodulos** (*desde que o **pom.xml** parent fique na raiz*)
  * **Bump automatico** de numero de versao e tag
  * **Constroi** e **Empura** uma imagem docker (usando o `runtime.Dockerfile`)
  * Publica o projeto no **Kubernetes** usando o **VCR** (*Vivo Container Registry*)
  * Upload de logs para **Auditoria**
* Gold
  * **Sonar Scan** para projetos **Maven Solo** e **Multimodulos**
  * **Fortify Scan**
  * **SCA**

### Como usar

> **Sobre os exemplos abaixo:**
> *   Alguns comentarios sao previsao onde ficarao as referencias futuras de maturidade.

`.azuredevops/azure-pipeline-ci.yml`
```yaml
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
resources:
  repositories:
  - repository: CodePlay
    name: DevOps/Vivo.CodePlay.Pipelines
    type: git
    ref: refs/heads/master
    endpoint: CodePlay

extends:  
  ## Maturidades disponiveis
  template: /tech_products/dvps/java/trunkbased/kube-vcr/lite-ci.yaml@CodePlay
  # template: /tech_products/dvps/java/trunkbased/kube-vcr/gold-ci.yaml@CodePlay
  # template: /tech_products/dvps/java/trunkbased/kube-vcr/platinum-ci.yaml@CodePlay
  # template: /tech_products/dvps/java/trunkbased/kube-vcr/diamond-ci.yaml@CodePlay
  # parameters:
  #   # Nomes de variable groups (opcional)
  #   #   Usado basicamente para substituir valores e segredos dos arquivos 'config/{environment}/*.yaml'
  #   #   que iram compor o deployment do kubernetes
  #   variable_groups:
  #   - ms-teste-pipeline-e2e-remover-v1
  #   - azdo-team-project-variables
  #   # Valores aceitaveis sao [dev | test | production | esteira1 | esteira2 | preprod | prodlike]
  #   # Valor padrao 'dev'
  #   environment: ${{ parameters.environment }}


```

`.azuredevops/azure-pipeline-cd.yml`
```yaml
parameters:
- name: environment
  displayName: 'Escolha o ambiente para publicar'
  type: string
  default: preprod
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

trigger: none

resources:
  repositories:
  - repository: CodePlay
    name: DevOps/Vivo.CodePlay.Pipelines
    type: git
    ref: refs/heads/master
    endpoint: CodePlay

extends:  
  template: /tech_products/dvps/java/trunkbased/kube-vcr/lite-cd.yaml@CodePlay
  # template: /tech_products/dvps/java/trunkbased/kube-vcr/gold-cd.yaml@CodePlay
  # template: /tech_products/dvps/java/trunkbased/kube-vcr/platinum-cd.yaml@CodePlay
  # template: /tech_products/dvps/java/trunkbased/kube-vcr/diamond-cd.yaml@CodePlay
  parameters:
    # Nomes de variable groups (opcional)
    #   Usado basicamente para substituir valores e segredos dos arquivos 'config/{environment}/*.yaml'
    #   que iram compor o deployment do kubernetes
    variable_groups:
    - azdo-team-project-variables
    - ms-teste-pipeline-e2e-remover-v1

    # Valores aceitaveis sao [dev | test | production | esteira1 | esteira2 | preprod | prodlike]
    # Valor padrao 'dev'
    environment: ${{ parameters.environment }}

    # Numero do CHG para validacao no VivoNow (⚠️ OBRIGATORIO para 'production')
    vivonow_chg: ${{ parameters.vivonow_chg }}

```

`.azuredevops/azure-pipeline-pr.yml`
```yaml
trigger:
  branches:
    include:
      - 'master'
      - 'main'
      - 'develop'
      - 'release'
      - 'codeplay'
  paths:
    exclude:
      - .azuredevops/*cd.*

resources:
  repositories:
  - repository: CodePlay
    name: DevOps/Vivo.CodePlay.Pipelines
    type: git
    ref: refs/heads/master
    endpoint: CodePlay

extends:  
  template: /tech_products/dvps/java/trunkbased/kube-vcr/lite-pr.yaml@CodePlay
  # template: /tech_products/dvps/java/trunkbased/kube-vcr/gold-pr.yaml@CodePlay
  # template: /tech_products/dvps/java/trunkbased/kube-vcr/platinum-pr.yaml@CodePlay
  # template: /tech_products/dvps/java/trunkbased/kube-vcr/diamond-pr.yaml@CodePlay
```

## Dependencias e configuracoes

### Configuracoes no `Azure DevOps`

Ambientes dentro do seu projeto (`AzureDevOps > Pipelines > Environments`)

* `deploy-dev`
* `deploy-esteira<1...N>`
* `deploy-preprod`
* `deploy-production`
* `deploy-prodlike`

### Arquivos dentro do `Azure Repos` (git)

> Antes de executar verifique se o seu repositorio tem esses arquivos com essas configuracoes minimas.

```
📂.azuredevops
 ┣ 📂config
 ┃ ┣ 📂[dev | esteira<1...N> | preprod | prodlike | producao]
 ┃ ┃ ┣ 📜environments_variables.yml
 ┃ ┃ ┣ 📜secrets.yaml
 ┃ ┃ ┗ 📜values.yml
 ┣ 📂variables
 ┃ ┗ 📜private.yml
 ┣ 📜pull_request_template.md
 ┣ 📜runtime.Dockerfile
 ┣ 📜sonar-project.properties
 ┣ 📜[any-prefix]settings.xml (opcional)
 ┗ 📜sonar.env
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
