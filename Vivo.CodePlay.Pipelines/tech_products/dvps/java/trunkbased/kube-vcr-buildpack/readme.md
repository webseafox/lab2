
# CI & CD para projetos BuildPack

## Estrutura macro

* `deploy.deploy-`*{nome-sua-app}*
* `package.package-`*{nome-sua-app}*
* `package.package-`*{nome-sua-app}*`-helm`
* `src.src-`*{nome-sua-app}*

## CI para Helm *package.package-{nome-sua-app}-helm*

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
    # ref: refs/heads/master
    ref: refs/heads/feat/buildpack
    endpoint: CodePlay

extends:
  
  template: /tech_products/dvps/java/buildpack/kube-vcr/ci_package.package--helm.yaml@CodePlay

```
## CI para SRC *src.src-{nome-sua-app}*

`.azuredevops/azure-pipeline-ci.yml`
```yaml
trigger:
  branches:
    include:
      - 'master'
      - 'codeplay'
      - 'codeplay-v2'
  paths:
    exclude:
      - .azuredevops/*cd.*
      - .azuredevops/*pr.*
resources:
  repositories:
  - repository: CodePlay
    name: DevOps/Vivo.CodePlay.Pipelines
    type: git
    # ref: refs/heads/master
    ref: refs/heads/feat/buildpack
    endpoint: CodePlay
  - repository: Helm
    name: <MY-PROJECT-NAME>/package.package-<my-helm-definition-repo>-helm
    type: git
    ref: refs/heads/master

# stages:
# - template: /tech_products/dvps/java/buildpack/tests/ci_build_src.src-.yaml@CodePlay
# - template: /tech_products/dvps/java/buildpack/tests/ci_push-docker_src.src-.yaml@CodePlay
# - template: /tech_products/dvps/java/buildpack/tests/ci_push-maven_src.src-.yaml@CodePlay
# - template: /tech_products/dvps/java/buildpack/tests/ci_heml-upgrade_src.src-.yaml@CodePlay
#   parameters:
#     environment: dev

extends:
  template: /tech_products/dvps/java/buildpack/kube-vcr/ci_src.src-.yaml@CodePlay

```

## CD para SRC *src.src-{nome-sua-app}*

`.azuredevops/azure-pipeline-cd.yml`
```yaml
trigger:
  branches:
    include:
      - 'master'
      - 'codeplay'
      - 'codeplay-v2'
  paths:
    exclude:
      - .azuredevops/*cd.*
      - .azuredevops/*pr.*
resources:
  repositories:
  - repository: CodePlay
    name: DevOps/Vivo.CodePlay.Pipelines
    type: git
    # ref: refs/heads/master
    ref: refs/heads/feat/buildpack
    endpoint: CodePlay
  - repository: Helm
    name: <MY-PROJECT-NAME>/package.package-<my-helm-definition-repo>-helm
    type: git
    ref: refs/heads/master

# stages:
# - template: /tech_products/dvps/java/buildpack/tests/ci_build_src.src-.yaml@CodePlay
# - template: /tech_products/dvps/java/buildpack/tests/ci_push-docker_src.src-.yaml@CodePlay
# - template: /tech_products/dvps/java/buildpack/tests/ci_push-maven_src.src-.yaml@CodePlay
# - template: /tech_products/dvps/java/buildpack/tests/ci_heml-upgrade_src.src-.yaml@CodePlay
#   parameters:
#     environment: dev

extends:
  template: /tech_products/dvps/java/buildpack/kube-vcr/cd_src.src-.yaml@CodePlay

```


`.azuredevops/runtime.Dockerfile`
```dockerfile
FROM vcr-docker.nexus.telefonica.com.br/corp/java/11/runtime/corp-jre11

WORKDIR /app
COPY target/{projectId}-{version}.jar /app/app.jar
ENTRYPOINT ["java","-jar","/app/app.jar"]
```

`catalog-info.yaml`
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  # !importante
  name: "{{repository-name}}"
  namespace: azure
  # !importante
  description: "{{repository-name}}"
  annotations:
    # Backstage default annotations  
    #backstage.io/techdocs-ref: dir:.
    backstage.io/code-coverage: scm-only
    # !importante
    backstage.io/kubernetes-id: "{{repository-name}}"
    backstage.io/kubernetes-namespace: "default"
    backstage.io/template-origin: none
    # Governance App
    # !importante
    techarch.governance-app.application: "digital-integration-platform"
    # !importante
    techarch.governance-app.module: "common-domain"
    techarch.governance-app.technical_component_type: "ms"
    techarch.governance-app.technical_component_intrastructure_type: "on premise"
    techarch.governance-app.provider: "n/a"
    # !importante
    techarch.governance-app.acronym: "pofs"
    techarch.governance-app.ic: "tlv_si_pofs"
    techarch.governance-app.uuid: "N/A"
    techarch.governance-app.spti: "N/A"
    techarch.governance-app.projeto: "none"
    techarch.governance-app.business_unit: "none"

    # KUBERNTES
    vivo.io/kubernetes-k8s-image-repo: "conv86-docker"
    # !importante
    vivo.io/kubernetes-k8s-namespace-dev: "default"
    # !importante
    vivo.io/kubernetes-k8s-namespace-esteira1: "default"
    # !importante
    vivo.io/kubernetes-k8s-namespace-esteira2: "default"
    # !importante
    vivo.io/kubernetes-k8s-namespace-preprod: "default"
    # !importante
    vivo.io/kubernetes-k8s-namespace-prodlike: "default"
    # !importante
    vivo.io/kubernetes-k8s-namespace-producao: "default"
    # Azure DevOps Plugin
    dev.azure.com/project-repo: "{{project-az}}/{{repository-name}}"
    dev.azure.com/project: "{{project-az}}"
    dev.azure.com/repo: "{{repository-name}}"
    dev.azure.com/organization: "telefonica-vivo-brasil"
    # Sonarqube Plugin
    sonarqube.org/project-key: "{{uuid}}"

    # Framework
    arqtech.telefonica.com.br/framework: springboot
    arqtech.telefonica.com.br/framework-version: '3.0.4'
    # Language
    arqtech.telefonica.com.br/language: java
    arqtech.telefonica.com.br/language-version: '11'
spec:
  type: service
  lifecycle: experimental   
  owner: "digital-integration-platform"
  system: common-domain

```