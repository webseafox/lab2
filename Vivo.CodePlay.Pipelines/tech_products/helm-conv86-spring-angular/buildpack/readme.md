
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
  
  template: /tech_products/dvps/java/v1/buildpack/package.package--helm_ci.yaml@CodePlay

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
# - template: /tech_products/helm-conv86-spring-angular/buildpack/tests/ci_build_src.src-.yaml@CodePlay
# - template: /tech_products/helm-conv86-spring-angular/buildpack/tests/ci_push-docker_src.src-.yaml@CodePlay
# - template: /tech_products/helm-conv86-spring-angular/buildpack/tests/ci_push-maven_src.src-.yaml@CodePlay
# - template: /tech_products/helm-conv86-spring-angular/buildpack/tests/ci_heml-upgrade_src.src-.yaml@CodePlay
#   parameters:
#     environment: dev

extends:
  template: /tech_products/helm-conv86-spring-angular/buildpack/ci_src.src-.yaml@CodePlay

```

