# Implantacao em Kubernetes com pipeline Lite para VCR com kube-config file 

## Como usar
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
    ref: refs/heads/master
    endpoint: CodePlay

extends:  
  template: /tech_products/java/kube-vcr/lite-ci.yaml@CodePlay
  parameters:
   # valores aceitaveis sao [dev | test | prod | esteira1 | esteira2 | preprod | prodlike]
   environment: dev 

```

`.azuredevops/azure-pipeline-cd.yml`
```yaml
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

trigger: none

resources:
  repositories:
  - repository: CodePlay
    name: DevOps/Vivo.CodePlay.Pipelines
    type: git
    ref: refs/heads/master
    endpoint: CodePlay

extends:  
  template: /tech_products/java/kube-vcr/lite-cd.yaml@CodePlay
  parameters:
   # valores aceitaveis sao [dev | test | prod | esteira1 | esteira2 | preprod | prodlike]
   environment: ${{ parameters.environment }}
   vivonow_chg: ${{ parameters.vivonow_chg }}


```
