# Implantacao em Cloud Foundry com pipeline CI-CD para aplicações MTA no SAP BTP.

## Variaveis necessárias

* BTP_CLOUD_FOUNDRY_API
* BTP_CLOUD_FOUNDRY_USERNAME
* BTP_CLOUD_FOUNDRY_PASSWORD

* BTP_CLOUD_FOUNDRY_ORGANIZATION:
    - BTP_CLOUD_FOUNDRY_ORGANIZATION_PRODUCTION
    - BTP_CLOUD_FOUNDRY_ORGANIZATION_QA
    - BTP_CLOUD_FOUNDRY_ORGANIZATION_DEV

* BTP_CLOUD_FOUNDRY_SPACE:
    - BTP_CLOUD_FOUNDRY_SPACE_PRODUCTION
    - BTP_CLOUD_FOUNDRY_SPACE_QA
    - BTP_CLOUD_FOUNDRY_SPACE_DEV

## Como usar
`.azuredevops/azure-pipelines.yml`
```yaml
trigger: none
    
pool:
  vmImage: ubuntu-latest

parameters:
  - name: deploy_environment
    displayName: Defina para qual ambiente será feito o deploy
    type: string
    default: dev
    values:
      - dev
      - homologation
      - production

resources:
  repositories:
    - repository: CodePlayPipelines
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: refs/heads/feature/sap-btp-platform
      #ref: master
      endpoint: CodePlay

extends:
  template: /tech_products/sap-btp/cloud-foundry/ci-cd.yaml@CodePlayPipelines
  parameters:
    deploy_environment: ${{parameters.deploy_environment}}
```
