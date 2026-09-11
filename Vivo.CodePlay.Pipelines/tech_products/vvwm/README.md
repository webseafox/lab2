# VVWM - WIAM

## cd_ping.yaml

Pipeline baseado no exemplo da Ping
- https://github.com/pingidentity/pipeline-example-infrastructure/blob/prod/.github/workflows/deploy.yaml
- https://videos.pingidentity.com/detail/video/6318020361112/reference-cicd-pipeline-demonstration

### Dependências

#### Service connection

- **vivoshift-preprod**: OpenShift - HML - Token concedido por rhayann.santos@telefonica.com
- **vivoshift-esteira01**: OpenShift - HML - Token concedido por rhayann.santos@telefonica.com
- **vivoshift-esteira02**: OpenShift - HML - Token concedido por rhayann.santos@telefonica.com
- **vivoshift-dev**: OpenShift - HML - Token concedido por rhayann.santos@telefonica.com


### Como utilizar

```yaml
parameters:
- name: environment
  displayName: 'Escolha o ambiente para publicar'
  type: string
  default: dev
  values:
    - dev
    - esteira01
    - esteira02
    - preprod
    - prodlike
    - prod


trigger: none

resources:
  repositories:
  - repository: CodePlay
    name: DevOps/Vivo.CodePlay.Pipelines
    type: git
    ref: refs/heads/feat/add-ping
    endpoint: CodePlay

extends:  
  template: /tech_products/vvwm/cd_ping.yaml@CodePlay
  parameters:
    environment: ${{ parameters.environment }}

```

### Evolução

1. O pipeline está utilizando alguns segredos hardcoded, isso **precisa** ser mudado nas próximas versões.
2. Publicação de imagens de produção para o ACR, para realizar backup.
  - Entender se a imagem muda sempre, se não mudar utilizar o internilizador
  - Pegar imagem do ACR, assim garantimos que o backup esta sendo feito e não temos o problema de IO do dockerhub
3. Repensar modelo de deploy. Clonar o repo em tempo no entrypoint não parece ser a melhor opção.
4. Se precisar de mais informações chamar o Tsuru.
   