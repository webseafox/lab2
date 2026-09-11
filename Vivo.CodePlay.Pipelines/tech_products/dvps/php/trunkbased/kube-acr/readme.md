# Implantacao de PHP em Kubernetes ACR com kube-config file

Pipelines para publicacao de `Aplicativos PHP` empara implantacao usando `Kubernetes` (OnPremises) e `Helm Chart`.

## Capacidades
* Lite
  * **Constroi**, **Testa** e **Empacota** projeto `PHP` x `Composer`.
  * **Bump automatico** de numero de versao e tag
  * **Constroi** e **Empura** uma imagem docker (usando o `runtime.Dockerfile`)
  * Publica o projeto no **Kubernetes** usando o **ACR** (*Azure Container Registry*)
  * Upload de logs para **Auditoria**
* Gold
  * **Sonar Scan** para projetos **Maven Solo** e **Multimodulos**
  * **Fortify Scan**
  * **SCA**

### Como usar

:::info[Sobre os exemplos abaixo]
* Alguns comentarios sao previsao onde ficarao as referencias futuras de maturidade.
:::

`.azuredevops/azure-pipeline-ci.yml`
```yaml title=".azuredevops/azure-pipeline-ci.yml"
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
parameters:
- name: environment
  displayName: 'Ambiente padrao para implantacao.'
  type: string
  default: dev
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

resources:
  repositories:
  - repository: CodePlay
    name: DevOps/Vivo.CodePlay.Pipelines
    type: git
    ref: refs/heads/master
    endpoint: CodePlay

extends:  
  template: /tech_products/dvps/php/trunkbased/kube-acr/lite-ci.yaml@CodePlay
  # template: /tech_products/dvps/php/trunkbased/kube-acr/gold-ci.yaml@CodePlay
  # template: /tech_products/dvps/php/trunkbased/kube-acr/platinum-ci.yaml@CodePlay
  # template: /tech_products/dvps/php/trunkbased/kube-acr/diamond-ci.yaml@CodePlay
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
```yaml title=".azuredevops/azure-pipeline-cd.yml"
trigger: none

parameters:
- name: environment
  displayName: 'Ambiente padrao para implantacao.'
  type: string
  default: dev
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

resources:
  repositories:
  - repository: CodePlay
    name: DevOps/Vivo.CodePlay.Pipelines
    type: git
    ref: refs/heads/master
    endpoint: CodePlay

extends:  
  template: /tech_products/dvps/php/trunkbased/kube-acr/lite-cd.yaml@CodePlay
  # template: /tech_products/dvps/php/trunkbased/kube-acr/gold-cd.yaml@CodePlay
  # template: /tech_products/dvps/php/trunkbased/kube-acr/platinum-cd.yaml@CodePlay
  # template: /tech_products/dvps/php/trunkbased/kube-acr/diamond-cd.yaml@CodePlay
  parameters:
    # # Nomes de variable groups (opcional)
    # #   Usado basicamente para substituir valores e segredos dos arquivos 'config/{environment}/*.yaml'
    # #   que iram compor o deployment do kubernetes
    # variable_groups:
    # - ms-teste-pipeline-e2e-remover-v1
    # - azdo-team-project-variables
    # Valores aceitaveis sao [dev | test | production | esteira1 | esteira2 | preprod | prodlike]
    # Valor padrao 'dev'
    environment: ${{ parameters.environment }}
    # Numero do CHG para validacao no VivoNow (⚠️ OBRIGATORIO para 'production')
    vivonow_chg: ${{ parameters.vivonow_chg }}


```

## Dependencias e configuracoes

### Ambientes dentro do seu projeto (`AzureDevOps > Pipelines > Environments`)

* `deploy-dev`
* `deploy-esteira[1...N]`
* `deploy-preprod`
* `deploy-production`
* `deploy-prodlike`

### Arquivos dentro do `Azure Repos` (git)

> Antes de executar verifique se o seu repositorio tem esses arquivos com essas configuracoes minimas.

```
📂.azuredevops
 ┣ 📂config
 ┃ ┣ 📂[dev | esteira[1...N] | preprod | prodlike | producao]
 ┃ ┃ ┣ 📜environments_variables.yml
 ┃ ┃ ┣ 📜secrets.yaml
 ┃ ┃ ┗ 📜values.yml
 ┣ 📂variables
 ┃ ┗ 📜private.yml
 ┣ 📜runtime.Dockerfile
 ┣ 📜sonar-project.properties
 ┗ 📜sonar.env
📜catalog-info.yaml
📜composer.json
```

`catalog-info.yaml`
```yaml title="catalog-info.yaml"
metadata:
  name: mfe-...-v[1...N]
  annotations:
    techarch.governance-app.acronym: 'dip'
    techarch.governance-app.module: 'common-domain'
    sonarqube.org/project-key: 'mfe-...'
    vivo.io/kubernetes-k8s-namespace-dev: 'dip-dev'
    vivo.io/kubernetes-k8s-namespace-esteira[1...N]: 'dip-esteira[1...N]'
    vivo.io/kubernetes-k8s-namespace-preprod: 'dip-preprod'
    vivo.io/kubernetes-k8s-namespace-production: 'dip-production'
    vivo.io/kubernetes-k8s-namespace-prodlike: 'dip-prodlike'
```

`./health.php`
```php
<?php
phpinfo();
phpinfo(INFO_MODULES);
?>
```

> `environment` pode ser **dev**, **esteira1**, **esteira2**, **qa**, **preprod** ou **prod**

`.azuredevops/config/[environment]/values.yml`
```yaml title=".azuredevops/config/[environment]/values.yml"
replicaCount: 1

# See https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/
serviceAccount:
  create: false
  annotations: {}
  name: ""

# See https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
podAnnotations:
  instrumentation.opentelemetry.io/inject-java: "true"
  
# See https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
podSecurityContext: {}

# See https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
securityContext: {}

# See https://kubernetes.io/docs/concepts/services-networking/service/
service:
  type: ClusterIP
  port: 8080

# container settings
container:
  port: 80
  schema: HTTP

# See https://istio.io/
istio:
  # Enabled istio service mesh
  enabled: true
  # Enabled istio release canary
  canaryEnabled: false
  # See https://istio.io/latest/docs/tasks/traffic-management/circuit-breaking/
  circuitBreak:
    connectionPool:
      # Enabled circuit break
      enabled: false
      # The maximum number of connections to a backend. Any excess connection will be pending in
      # a queue. You can modify this number by changing the maxConnections field.
      maxConnections: 10
      # The maximum number of pending requests to a backend. Any excess pending requests will be 
      # denied. You can modify this number by changing the http1MaxPendingRequests field.
      http1MaxPendingRequests: 50
      # The maximum number of requests in a cluster at any given time. You can modify this 
      # number by changing the maxRequestsPerConnection field.
      maxRequestsPerConnection: 10 
  # See https://istio.io/latest/docs/reference/config/networking/virtual-service/
  virtualService:
    hosts: 
      - "dvps-integracao.redecorp.br"
    gateways:
      - "dvps-gateway.dvps-common.svc.cluster.local"
    
#     # See https://istio.io/latest/docs/reference/config/networking/virtual-service/#CorsPolicy
#     allowOrigins: ["*"]
#     allowCredentials: True
#     allowHeaders: []
#     allowMethods: ["POST", "GET", "PUT", "DELETE", "OPTIONS", "PATCH", "TRACE", "HEAD", "CONNECT" ]

# See https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
resources: {}
  # limits:
  #   cpu: 500m
  #   memory: 512Mi
  # requests:
  #   cpu: 100m
  #   memory: 128Mi

# See https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
autoscaling:
  enabled: false
  istioEnabled: false
  minReplicas: 1
  maxReplicas: 1
  targetCPUUtilizationPercentage:

# See https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
nodeSelector: {}

# See https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
tolerations: []

# See https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/
affinity: {}

# See https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
liveness:
  enabled: false
  failureThreshold: 3
  initialDelaySeconds: 30
  periodSeconds: 30
  successThreshold: 1
  timeoutSeconds: 120
  healthCheck: /health.php
# See https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
readiness:
  enabled: false
  failureThreshold: 3
  initialDelaySeconds: 30
  periodSeconds: 30
  successThreshold: 1
  timeoutSeconds: 120
  healthCheck: /health.php

####################################################################################################################
#                                          MICROSERVICE SECTION                                                    #
####################################################################################################################
# Microservice default Timezone
timezone: "America/Sao_Paulo"

# Name of your microservice, this name will be registered in service discovery,
# so it is important to follow a pattern of names and that this name is not too long.
# Ex: cac-sample-microservice.
applicationName: "$(CATALOG_YAML_NAME)"
applicationVersion: "1"
applicationPrefix: "/$(CATALOG_YAML_NAME)/v1"
    
# Additional keys that will be added to the configmap.
# See the examples below.
configMapKeys: {}
  # key: value

  # configuration: |
  #   #!/bin/bash
  #   echo teste ..  

# Environment variables that will be used by the worker.
# See the example below.
applicationVariables: []

volumes: []

volumeMounts: []
```
`.azuredevops/config/[environment]/secrets.yaml`
```yaml title=".azuredevops/config/[environment]/secrets.yml"
secrets: []
secretFiles: []
```

`.azuredevops/config/[environment]/environments_variables.yml`
```yaml title=".azuredevops/config/[environment]/values.yml"
env: []
```