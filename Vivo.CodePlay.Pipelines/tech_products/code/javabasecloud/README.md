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
  displayName: Escolha o ambiente para publicar
  type: string
  default: dev
  values:
  - dev
  - preprod
  - prod

- name: vivonow_chg
  displayName: Numero CHG do VivoNow, somente para 'prod'
  default: CHG0000001

resources:
  repositories:
  - repository: CodePlay
    name: DevOps/Vivo.CodePlay.Pipelines
    type: git
    # ref: refs/tags/latest
    ref: refs/heads/feat/munf
    endpoint: CodePlay

extends:
  # template: /tech_products/java/v1/tests/cd_v5-gov_app.yaml@CodePlay
  # template: /tech_products/java/v1/tests/cd_v5-push_docker_retag.yaml@CodePlay
  # template: /tech_products/java/v1/tests/cd_v5-vivo_now_chg.yaml@CodePlay
  # template: /tech_products/java/v1/tests/cd_v5-deploy_helm_deploy_pre.yaml@CodePlay
  # template: /tech_products/java/v1/tests/cd_v5-deploy_helm_deploy.yaml@CodePlay
  template: /tech_products/java/v1/cd_v5.yaml@CodePlay
  parameters: 
    environment: ${{ parameters.environment }}
    vivonow_chg: ${{ parameters.vivonow_chg }}
    sigla_bu: techarch
```
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
  # template: /tech_products/code/javabasecloud/tests/ci_v5-build_and_sonar.yaml@CodePlay
  # template: /tech_products/code/javabasecloud/tests/ci_v5-bump_version.yaml@CodePlay
  # template: /tech_products/code/javabasecloud/tests/ci_v5-fortify.yaml@CodePlay
  # template: /tech_products/code/javabasecloud/tests/ci_v5-push_docker.yaml@CodePlay
  template: /tech_products/code/javabasecloud/ci_v5.yaml@CodePlay

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
    ref: refs/heads/feat/munf
    endpoint: CodePlay

extends:
  template: /tech_products/java/v1/pr_v5.yaml@CodePlay
```