# Como utilizar esse tech product

## Obrigatório
- Criar arquivo catalog-info.yaml
- Criar .azuredevops/sonar-project.properties

```
sonar.host.url=${env.SONARQUBE_URL}
sonar.token=${env.SONARQUBE_TOKEN}
sonar.projectBaseDir=./
sonar.projectName="nome-do-repositório"
sonar.projectVersion=${env.APP_VERSION}
sonar.projectDescription="Descrição do seu repositório."
sonar.links.homepage=${env.AZ_HOMEPAGE_URL}
sonar.links.ci=${env.AZ_BUILD_URL}
sonar.links.issue=${env.AZ_ISSUES_URL}
sonar.links.scm=${env.AZ_REPOSITORY_URL}
sonar.scm.exclusions.disabled=false
sonar.scm.forceReloadAll=true
# sonar.log.level=DEBUG
sonar.verbose=false
sonar.sourceEncoding=UTF-8
sonar.sources=src
sonar.tests=tests
sonar.coverage.exclusions=tests/**
sonar.python.file.suffixes=.py
sonar.python.coverage.reportPaths=coverage.xml
sonar.exclusions=

```

## Uso com versionamento utilizando arquivo VERSION + requirements.txt

Setar a variável VERSION_MANAGER_TYPE=‘version_file’ no arquivo .azuredevops/variables/private.yml, logo após a chamada do grupo de variáveis. O arquivo ficará como abaixo:

```yaml
variables:
- name: global_poollImage
  value: 'default'

- ${{ if or(eq(variables['Build.Reason'], 'PullRequest'), eq(variables['Build.SourceBranch'], 'refs/heads/master'), startsWith(variables['Build.SourceBranch'], 'refs/tags/')) }}:
    - group: lojaonline-all-python-variables

- name: VERSION_MANAGER_TYPE
  value: 'version_file'
- name: BREAK_LINT_FAILED
  value: false
- name: DEVFLOW_FILES_TO_COMMIT
  value: 'VERSION'
```

## Uso com versionamento utilizando uv + pyproject.toml

O grupo de variáveis deverá possuir a variável VERSION_MANAGER_TYPE=uv, já que o default é "version_file' (ver o arquivo de definição de variáveis tech_products/ecmc/core-pipelines/provisioners/app/global/python/variables/init.yml).
O arquivo .azuredevops/variables/private.yml ficará como abaixo:

```yaml
variables:
- name: global_poollImage
  value: 'default'

- ${{ if or(eq(variables['Build.Reason'], 'PullRequest'), eq(variables['Build.SourceBranch'], 'refs/heads/master'), startsWith(variables['Build.SourceBranch'], 'refs/tags/')) }}:
    - group: lojaonline-all-python-variables
```

## Uso desse template

NO seu arquivo de pipeline (exemplo .azuredevops/azure-pipeline.yml), use o conteúdo como abaixo:

```yaml
pool:
  vmImage: $(global_poollImage)
trigger: none
parameters:
  - name: qa_environment
    displayName: Escolha a esteira para deploy
    type: string
    default: devops
    values:
      - devops
resources:
  repositories:
    - repository: CodePlayPipelines
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: refs/heads/master

      endpoint: CorePipelines
    - repository: ArgoCD
      name: ECMC - Ecomm Cloud B2C/argocd
      type: git
      ref: refs/heads/master

    - repository: ArgoCD-Production
      name: ECMC - Ecomm Cloud B2C/argocd-production
      type: git
      ref: refs/heads/master
extends:
  template: /tech_products/ecmc/core-pipelines/provisioners/entrypoint.yml@CodePlayPipelines
  parameters:
    config:
      pipelineType: app
      technology: python
      modelName: api_default
      branchingStrategy: trunkbased
      params:
        enableDevflowValidations: True
        qa_environment: ${{ parameters.qa_environment }}
        argocd_enabled: "true"
        ACRAsDefaultDockerRegistry: False  # ou True para uso do ACR
```

## Repositórios de exemplo

- Para uso com versionamento utilizando uv + project.toml:
https://dev.azure.com/telefonica-vivo-brasil/ECMC%20-%20Ecomm%20Cloud%20B2C/_git/src-python-secret-vault-updater

- Para uso com arquivo VERSION + requirements.txt:
https://dev.azure.com/telefonica-vivo-brasil/ECMC%20-%20Ecomm%20Cloud%20B2C/_git/src-python-api-write-confluence

## Valores default das variáveis
Ver o arquivo tech_products/ecmc/core-pipelines/provisioners/app/global/python/variables/init.yml. Caso não seja setada no arquivos de variáveis ou em .azuredevops/variables/private.yml (dentro do repositório que vai consumir o yaml do CodePlay), os valores default serão considerados.
