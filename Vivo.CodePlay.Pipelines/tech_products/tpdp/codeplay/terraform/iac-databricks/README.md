# Pipeline Terraform Lite CI - IAC Databricks

Pipeline migrada do projeto TPAZ/codeplay/terraform/iac-databricks.
Esse pipeline está apontando para o ambientes antigos da landing zone de dados. Foi criado a sigla TPDP para migrar a infraestrutura como código e os novos workspaces para a nova landing zone. Estamos fazendo refatorações e testes em paralelo para não gerar impacto no ambiente antigo da landing zone e parar os pipelines existentes.

## Visao geral
Este pipeline executa ciclo de vida Terraform para infraestrutura Databricks com suporte a:

- plan
- apply
- plan destroy
- destroy

O pipeline oferece duas abordagens de execução:

1. **Execução Simples** ([lite-ci.yml](lite-ci.yml)): Pipeline standalone para execução direta de um componente específico
2. **Execução Orquestrada** ([iac-databricks-template.yml](iac-databricks-template.yml)): Orquestra múltiplos componentes (foundation, storage, databricks) com gerenciamento automático de dependências

### Arquivos principais

| Arquivo | Propósito |
|---------|-----------|
| [lite-ci.yml](lite-ci.yml) | Pipeline simples para execução de um único componente |
| [iac-databricks-template.yml](iac-databricks-template.yml) | Orquestrador de múltiplos componentes |
| [iac-databricks-component-template.yml](iac-databricks-component-template.yml) | Template reutilizável para cada componente (foundation, storage, databricks) |

## Acoes suportadas
A execução é controlada pelo parametro action.

| action | Stages executados |
|---|---|
| plan | stage_*_plan |
| apply | stage_*_plan -> stage_*_apply |
| planDestroy | stage_*_plan_destroy |
| destroy | stage_*_plan_destroy -> stage_*_destroy |

## Parametros

### Abordagem Simples (lite-ci.yml)

| Nome | Tipo | Default | Valores | Descricao |
|---|---|---|---|---|
| environmentType | string | nonprod | nonprod, prod | Define qual ambiente será usado para backend/state e tfvars. |
| environment | string | dev | dev, test, prod | Ambiente específico de execução. |
| action | string | plan | plan, apply, destroy, planDestroy | Define o fluxo Terraform do pipeline. |
| workDir | string | foundation | foundation, storage, databricks | Define qual componente será executado. |
| requiresManualApproval | boolean | false | true, false | Variavel de controle de aprovação manual (uso interno do pipeline). |
| isDestroy | boolean | false | true, false | Variavel de controle para condicoes especificas (uso interno do pipeline). |

### Abordagem Orquestrada (iac-databricks-template.yml)

| Nome | Tipo | Default | Valores | Descricao |
|---|---|---|---|---|
| environment | string | - | dev, test, prod | Ambiente específico de execução. |
| environmentType | string | - | nonprod, prod | Define qual ambiente será usado para backend/state e tfvars. |
| action | string | - | plan, apply, destroy, planDestroy | Define o fluxo Terraform do pipeline. |
| workDir | string | all | all, foundation, storage, databricks | Define quais componentes serão executados (all executa todos). |
| runFoundation | boolean | true | true, false | Habilita execução do componente foundation. |
| runStorage | boolean | true | true, false | Habilita execução do componente storage. |
| runDatabricks | boolean | true | true, false | Habilita execução do componente databricks. |

## Estrutura esperada no repositorio
O pipeline espera arquivo de variaveis por ambiente no caminho:

- environments/nonprod/foundation.tfvars.json
- environments/nonprod/storage.tfvars.json
- environments/nonprod/databricks.tfvars.json
- environments/prod/foundation.tfvars.json
- environments/prod/storage.tfvars.json
- environments/prod/databricks.tfvars.json

A variavel interna tfvarsLocation e resolvida como:

- environments/${environmentType}/${workDir}.tfvars.json

## Arquitetura de Componentes

O pipeline foi projetado com uma arquitetura modular de 3 componentes que devem ser provisionados na seguinte ordem:

1. **foundation**: Recursos base de infraestrutura
2. **storage**: Recursos de armazenamento
3. **databricks**: Workspace Databricks e configurações

### Dependências entre componentes

**Durante Apply:**
- storage depende de foundation
- databricks depende de storage
- Cada componente é aplicado sequencialmente

**Durante Destroy (ordem reversa):**
- databricks é destruído primeiro
- storage é destruído após databricks
- foundation é destruído por último

Esta ordem é essencial para evitar conflitos de dependência entre recursos. O template [iac-databricks-component-template.yml](iac-databricks-component-template.yml) gerencia automaticamente essas dependências através dos parametros `previousWorkDir` e `nextWorkDir`.

## Detalhes dos Arquivos de Template

### lite-ci.yml
Pipeline standalone simplificado para execução de um único componente por vez.

**Características:**
- Fluxo linear e direto
- Ideal para execução de componentes individuais
- Todos os stages em um único arquivo
- Perfeito para uso em repositórios de componentes específicos

**Stages:**
- stage_plan: Plano Terraform
- stage_apply: Aplicar mudanças
- stage_plan_destroy: Plano de destruição
- stage_destroy: Destruir recursos

### iac-databricks-template.yml
Orquestrador que coordena a execução de múltiplos componentes.

**Características:**
- Gerencia dependências automáticas entre componentes
- Suporta execução de componentes específicos ou todos
- Controla ordem de aplicação (foundation -> storage -> databricks)
- Inverte ordem automaticamente para destroy
- Habilita/desabilita componentes por parâmetro

**Comportamento:**
- Condiciona inclusão de stages baseado em parâmetros runFoundation, runStorage, runDatabricks
- Gerencia previousWorkDir e nextWorkDir para coordenar dependências
- Valida que a ordem está correta mesmo em execuções parciais

### iac-databricks-component-template.yml
Template reutilizável que define os stages para cada componente individual.

**Características:**
- Define os 4 stages por componente: plan, plan_destroy, apply, destroy
- Gerencia dependências através de dependsOn condicional
- Implementa validação de conflitos (create+destroy simultaneo)
- Executa scans de segurança (Checkov, tfsec) e custo (Infracost)
- Publica resultados de testes em formato JUnit

**Parametros principais:**
- workDir: foundation, storage ou databricks
- previousWorkDir: Componente que este depende (usado em apply)
- nextWorkDir: Próximo componente na cadeia (usado em destroy)
- action: Define qual fluxo executar

## Pre-requisitos

### Agent pool
- GeneralPurposeLinuxAgentsCD

### Service connections
- DevOpsSharedResources
- SharedResources
- sp-dados-tp-terraform-nonprod
- sp-dados-tp-terraform-prod

### Key Vault e secrets
Key Vault esperado: kv-azdevops-shared

Secrets utilizados:
- NEXUS-DEPS-USR
- NEXUS-DEPS-PSW
- AZ-DEVOPS-PAT-TOKEN
- PHPIPAM-PASSWORD
- INFRACOST-API-KEY

### Ferramentas no agente
- Terraform 1.4.5 (instalado no pipeline)
- jq
- checkov
- tfsec
- infracost

## O que o pipeline faz
Em cada stage de plan/plan destroy:

1. Checkout do repositorio
2. Terraform init (backend remoto Azure Storage)
3. Terraform validate
4. Terraform plan (normal ou com -destroy)
5. Export do plano para tfplan.json
6. Estimativa de custo com Infracost
7. Scans de seguranca com Checkov e tfsec
8. Publicacao de resultados de teste JUnit (TEST-*.xml)

No fluxo apply:

1. Terraform init
2. Terraform apply com --auto-approve
3. Export de terraform output para outputs.json
4. Publicacao do artifact terraform_apply

No fluxo destroy:

1. Terraform init
2. Export de outputs atuais para outputs.json
3. Publicacao do artifact terraform_destroy
4. Terraform destroy com --auto-approve

## Aprovacao manual
Durante o stage de plan para apply, o pipeline verifica se o plano contem criação e destruicao simultaneas de recursos.

Se detectar esse cenario, a variavel requiresManualApproval e definida como true e um job de aprovação manual e acionado antes de prosseguir.

## Artefatos e resultados
- Artifact terraform_apply: publicado no stage_apply quando ha outputs
- Artifact terraform_destroy: publicado no stage_destroy quando ha outputs
- Test results JUnit: arquivos TEST-*.xml de checkov/tfsec

## Como executar

### Abordagem Simples (lite-ci.yml)

Use quando precisar executar um único componente isoladamente.

No Azure DevOps:

1. Selecione Run Pipeline
2. Escolha environmentType (nonprod ou prod)
3. Escolha environment (dev, test ou prod)
4. Escolha action (plan, apply, planDestroy ou destroy)
5. Escolha workDir (foundation, storage ou databricks)
6. Execute

**Exemplo**: Para fazer plan do componente foundation no ambiente de desenvolvimento do nonprod:
- environmentType: nonprod
- environment: dev
- action: plan
- workDir: foundation

### Abordagem Orquestrada (iac-databricks-template.yml)

Use quando precisar provisionar múltiplos componentes com gerenciamento automático de dependências.

No Azure DevOps:

1. Selecione Run Pipeline
2. Escolha environment (dev, test ou prod)
3. Escolha environmentType (nonprod ou prod)
4. Escolha action (plan, apply, planDestroy ou destroy)
5. Escolha workDir:
   - **all**: Executa todos os componentes (foundation -> storage -> databricks)
   - **foundation**: Executa somente foundation
   - **storage**: Executa somente storage
   - **databricks**: Executa somente databricks
6. Selecione quais componentes deseja habilitar (runFoundation, runStorage, runDatabricks)
7. Execute

**Exemplo**: Para fazer plan de todos os componentes:
- environment: dev
- environmentType: nonprod
- action: plan
- workDir: all
- runFoundation: true
- runStorage: true
- runDatabricks: true

**Exemplo**: Para fazer apply apenas de storage (quando foundation já existe):
- environment: dev
- environmentType: nonprod
- action: apply
- workDir: storage
- runFoundation: false
- runStorage: true
- runDatabricks: false

## Recomendacoes operacionais

### Para provisão inicial completa
1. Use action=plan com workDir=all para visualizar todas as mudanças
2. Revise os planos de cada componente
3. Revise resultados de segurança (Checkov/tfsec) e custo (Infracost)
4. Execute action=apply com workDir=all

### Para atualizações de componentes específicos
1. Use a abordagem simples (lite-ci.yml) para componentes individuais
2. Valide que componentes dependentes não serão impactados
3. Execute plan e valide antes de apply

### Para destroy/limpeza
1. Use action=planDestroy para visualizar o que será removido
2. Revise cuidadosamente os recursos a serem destruídos
3. Use action=destroy quando tiver certeza
4. A ordem de destruição é automática (inversa à criação)

### Aprovacao manual
Durante o stage de plan para apply, o pipeline verifica se o plano contem criação e destruicao simultaneas de recursos.

Se detectar esse cenario, uma aprovação manual é acionada antes de prosseguir. Isso evita ciclos de recriação que poderiam impactar dados ou configurações.

## Troubleshooting rapido
- **Falha em tfvars**: Valide existência de environments/<env>/{foundation,storage,databricks}.tfvars.json
- **Falha de autenticação**: Valide service connections e permissão no Key Vault
- **Falha em scans**: Confira disponibilidade de checkov/tfsec/infracost no agente
- **Falha em terraform init**: Valide backend remoto e permissões da service connection SharedResources
- **Dependência entre componentes não é respeitada**: Confirme que a abordagem orquestrada está sendo usada (iac-databricks-template.yml)
- **Pipeline falha em destroy**: Valide que a ordem inversa está sendo mantida (databricks -> storage -> foundation)
- **Aprovação manual nunca termina**: Verifique se há realmente recursos sendo criados e destruídos simultaneamente no plano
- **Output não é publicado**: Confirme que terraform output contém valores válidos no stage_apply ou stage_destroy
