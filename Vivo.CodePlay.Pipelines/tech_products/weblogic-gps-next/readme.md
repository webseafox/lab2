# Como usar


`.azuredevops/azure-pipeline-ci.yml`
```yaml
trigger:
  branches:
    exclude:
      - '*'
  paths:
    exclude:
      - '.azuredevops/azure-pipeline-cd.yml'

resources:
  repositories:
  - repository: CodePlay
    name: DevOps/Vivo.CodePlay.Pipelines
    type: git
    # ref: refs/tags/latest
    ref: refs/heads/tech-weblogic-srv-gps
    endpoint: CodePlay

parameters:
- name: useMavenCache
  displayName: Usar cache do maven
  type: boolean
  default: True

extends:
  # template: /tech_products/weblogic-gps-next/tests/cd-deploy-weblogic.yml@CodePlay
  # template: /tech_products/weblogic-gps-next/tests/ci-deploy-nexus.yml@CodePlay
  # template: /tech_products/weblogic-gps-next/tests/ci-gate-fortify.yml@CodePlay
  # template: /tech_products/weblogic-gps-next/tests/ci-gate-sonar.yml@CodePlay
  # template: /tech_products/weblogic-gps-next/tests/pipeline-teste-deps.yml@CodePlay
  # template: /tech_products/weblogic-gps-next/tests/ci-build-bump-and-tag.yml@CodePlay
  # template: /tech_products/weblogic-gps-next/cd.yml@CodePlay
  template: /tech_products/weblogic-gps-next/ci.yml@CodePlay
  parameters:
    useMavenCache: ${{ parameters.useMavenCache }}

```

`.azuredevops/azure-pipeline-cd.yml`
```yaml

trigger:
  branches:
    exclude:
      - '*'
  paths:
    exclude:
      - '*'
  
parameters:  
- name: deploymentName
  displayName: Escolha o modulo para publicar no WebLogic
  values:
  - wizard
  - admin

- name: environment
  displayName: Escolha a esteira de QA para para deploy
  type: string
  default: DEV
  values:
  - DEV
  - ESTEIRA1
  - ESTEIRA2
  - PREPROD
  - PRODLIKE
  - PROD 


resources:
  repositories:
  - repository: CodePlay
    name: DevOps/Vivo.CodePlay.Pipelines
    type: git
    # ref: refs/tags/latest
    ref: refs/heads/tech-weblogic-srv-gps
    endpoint: CodePlay


extends:
  template: /tech_products/weblogic-gps-next/cd.yml@CodePlay
  parameters:
    deploymentName: ${{ parameters.deploymentName }}
    environment: ${{ parameters.environment }}
```