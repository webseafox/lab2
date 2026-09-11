# Implantacao em Kubernetes com pipeline Lite para Azure Federation 

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
  template: /tech_products/dvps/java/kube-azure-federation/gold-ci.yaml@CodePlay
  parameters:
   # valores aceitaveis sao [dev | test | prod | esteira1 | esteira2 | preprod | prodlike]
   environment: dev 
   
   # Acronimo da applicacao, 
   # valor encontrado dentro do 
   # catalog-info.yaml$.metadata.annotations.[techarch.governance-app.acronym]
   #
   # ATENCAO! Este valor nao pode ser consumido dinamicamente do catalog-info.yaml pois a 
   #          service connection e carregada antes da pipeline executar.
   gov_app_acronym: mvpk

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

- name: gov_app_acronym
  displayName: 
    Gov app acronym para a service connection ex 'aks-{gov_app_acronym}-brsouth-dev', 
    Veja esse parametro no catalog-info.yaml do seu projeto
  type: string
  default: mvpk

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
  template: /tech_products/dvps/java/kube-azure-federation/gold-cd.yaml@CodePlay
  parameters:
   # valores aceitaveis sao [dev | test | prod | esteira1 | esteira2 | preprod | prodlike]
   environment: ${{ parameters.environment }}
   
   # Acronimo da applicacao, 
   # valor encontrado dentro do 
   # catalog-info.yaml$.metadata.annotations.[techarch.governance-app.acronym]
   #
   # ATENCAO! Este valor nao pode ser consumido dinamicamente do catalog-info.yaml pois a 
   #          service connection e carregada antes da pipeline executar.
   gov_app_acronym: ${{ parameters.gov_app_acronym }}
   vivonow_chg: ${{ parameters.vivonow_chg }}

```
