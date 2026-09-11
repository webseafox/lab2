## Como usar


Crie 3 arquivos no seu repositorio:
* `.azuredevops/azure-pipeline-cd.yml`
* `.azuredevops/azure-pipeline-ci.yml`
* `.azuredevops/azure-pipeline-pr.yml`

`.azuredevops/azure-pipeline-cd.yml`
```yaml
trigger: none

parameters:
- name: environment
  displayName: 'Escolha o ambiente para publicar'
  type: string
  default: dev
  values:
  - dev
  - preprod
  - prod

- name: vivonow_chg
  displayName: 'Numero CHG do VivoNow, somente para "prod"'
  default: CHG0000001

resources:
  repositories:
  - repository: CodePlay
    name: DevOps/Vivo.CodePlay.Pipelines
    type: git
    # ref: refs/tags/latest
    ref: refs/heads/feat/template-java-datalake
    endpoint: CodePlay

extends:
  # template: /tech_products/code/javabasecloud/tests/cd_v5-gov_app.yaml@CodePlay
  # template: /tech_products/code/javabasecloud/tests/cd_v5-push_docker_retag.yaml@CodePlay
  # template: /tech_products/code/javabasecloud/tests/cd_v5-vivo_now_chg.yaml@CodePlay
  # template: /tech_products/code/javabasecloud/tests/cd_v5-deploy_helm_deploy_pre.yaml@CodePlay
  # template: /tech_products/code/javabasecloud/tests/cd_v5-deploy_helm_deploy.yaml@CodePlay
  template: /tech_products/code/javabasecloud/cd_v5.yaml@CodePlay
  parameters: 
    environment: ${{ parameters.environment }}
    vivonow_chg: ${{ parameters.vivonow_chg }}
    sigla_bu: techarch
```

### CI Kubenetes
`.azuredevops/azure-pipeline-ci.yml`
```yaml

trigger:
  branches:
    include:
      - 'master'
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
    # ref: refs/tags/latest
    ref: refs/heads/feat/template-java-datalake
    endpoint: CodePlay

extends:
  # Use this templates to make isolated tests
  # template: /tech_products/dvps/java/v1/tests/ci_v5-build_and_sonar.yaml@CodePlay
  # template: /tech_products/dvps/java/v1/tests/ci_v5-bump_version.yaml@CodePlay
  # template: /tech_products/dvps/java/v1/tests/ci_v5-fortify.yaml@CodePlay
  # template: /tech_products/dvps/java/v1/tests/ci_v5-push_docker.yaml@CodePlay
  
  # Use this template to CI with VCR kube
  # template: /tech_products/dvps/java/v1/ci_vcr-kube.yaml@CodePlay
  
  # Use this template to CI with NEXUS mvn
  # template: /tech_products/dvps/java/v1/ci_nexus-mvn.yaml@CodePlay
  
  # Use this template to CI with NEXUS docker
  # template: /tech_products/dvps/java/v1/ci_nexus-docker.yaml@CodePlay
  
  # Use this template to CI with KUBE
  # template: /tech_products/dvps/java/v1/ci_kube.yaml@CodePlay
  
  # Use this template to CI with ACR endpoint kube
  # template: /tech_products/dvps/java/v1/ci_acr-endpoint-kube.yaml@CodePlay
  # parameters:
  #  # valores aceitaveis sao [dev | test | prod | esteira1 | esteira2 | preprod | prodlike]
  #  environment: dev 
  #  # acronimo da applicacao, 
  #  # valor encontrado dentro do catalog-info.yaml$.metadata.annotations.[techarch.governance-app.acronym]
  #  # ATENCAO! Este valor nao pode ser consumido dinamicamente do catalog-info.yaml pois a 
  #  #          service connection e carregada antes da pipeline executar.
  #  gov_app_acronym: mvpk

```

### CI Weblogic
`.azuredevops/azure-pipeline-ci.yml`
```yaml
parameters:
- name: ssh_weblogic_endpoint
  displayName: 'Escolha o ambiente para publicar'
  type: connectedService:ssh

trigger:
  branches:
    include:
      - 'master'
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
    # ref: refs/tags/latest
    ref: refs/heads/feat/template-java-datalake
    endpoint: CodePlay

extends:

  # template: /tech_products/dvps/java/v1/tests/ci_v5-build_and_sonar.yaml@CodePlay
  # template: /tech_products/dvps/java/v1/tests/ci_v5-bump_version.yaml@CodePlay
  # template: /tech_products/dvps/java/v1/tests/ci_v5-fortify.yaml@CodePlay
  # template: /tech_products/dvps/java/v1/tests/ci_v5-push_docker.yaml@CodePlay
  
  template: /tech_products/dvps/java/v1/ci_weblogic.yaml@CodePlay
  parameters: 
    ssh_weblogic_endpoint: ${{ parameters.ssh_weblogic_endpoint }}
```

`.azuredevops/azure-pipeline-pr.yml`
```yaml
trigger: none

pr:
  branches:
    include:
    - "master"
    - "main"

resources:
  repositories:
  - repository: CodePlay
    name: DevOps/Vivo.CodePlay.Pipelines
    type: git
    # ref: refs/tags/latest
    ref: refs/heads/feat/template-java-datalake
    endpoint: CodePlay

extends:
  template: /tech_products/code/javabasecloud/pr_v5.yaml@CodePlay
```

### CI Library Nexys
`.azuredevops/azure-pipeline-ci.yml`
```yaml
trigger:
  branches:
    include:
      - 'master'
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
    # ref: refs/tags/latest
    ref: refs/heads/feat/template-java-datalake
    endpoint: CodePlay

extends:

  template: /tech_products/dvps/java/v1/ci_nexus-mvn.yaml@CodePlay

```
