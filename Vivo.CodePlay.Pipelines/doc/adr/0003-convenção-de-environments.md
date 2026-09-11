# 3. Convenção de Environments

Date: 2025-12-03

## Status

Proposed

## Context

Atualmente, não há uma convenção clara para nomear os diferentes ambientes (environments) utilizados em nossos projetos. Isso pode levar a confusões e erros, especialmente quando múltiplos ambientes são necessários para desenvolvimento, teste e produção.

Hoje utilizamos nomes variados como "dev", "development", "test", "staging", "prod" e "production", o que dificulta a identificação rápida do ambiente correto.

Além disso, a falta de padronização tem resultado em um número excessivo de environments criados, muitos dos quais nunca são utilizados, levando a desperdício de recursos e aumento da complexidade na gestão dos projetos.

- 📋 10.449 environments totais** distribuídos em 376 projetos
- ❌ 9.371 environments nunca utilizados (89,7% desperdício)**
- ✅ 1.078 environments com deployments ativos (10,3%)**
- 🏷️ 373 tipos únicos de environments** (complexidade insustentável)

Nas Referências, há uma [tabela](#tabela-de-uso-de-environments-atuais) detalhada mostrando a distribuição e o uso dos environments atuais.

Já havia uma [proposta inicial](../../GUIDELINES.md#tabela-de-ambientes-resumida) para padronização dos nomes dos environments, mas ela não foi formalmente documentada ou adotada.

A equipe de QA utiliza a seguinte convenção para seus ambientes:

- **dev**: Ambiente de desenvolvimento
- **esteira1**: Esteira de testes 1
- **esteira2**: Esteira de testes 2
- **prodlike**: Ambiente similar ao de produção
- **preprod**: Ambiente de pré-produção
- **producao**: Ambiente de produção

> Nomes curtos seriam mais convenientes para facilitar a leitura e escrita nos pipelines, além de reduzir o risco de erros de digitação. Porem, as convenção acima já são muito utilizadas, o que tornaria a padronização mais complexa.

  
## Decision

Adotar a seguinte convenção para nomeação dos environments no azure-devops:

### Deploys Convencionais:

**Motivação**: Ser possível criar politicas de aprovação baseado em grupos de acessos específicos para cada ambiente.

- **deploy-dev**: Ambiente de desenvolvimento
- **deploy-esteira1**: Esteira de testes 1
- **deploy-esteira2**: Esteira de testes 2
- **deploy-prodlike**: Ambiente similar ao de produção
- **deploy-preprod**: Ambiente de pré-produção
- **deploy-producao**: Ambiente de produção

### Deploys Blue-Green e Canary (Argo-Rollouts):

**Motivação**: Permitir a utilização de deploys blue-green para todos os ambientes, facilitando a realização de testes e rollback.

Não é possível utilizar o mesmo ambiente do deploy convencional, pois uma vez aprovado não pede mais aprovação para o mesmo ambiente.
Essa aprovação serve para poder controlar manualmente o processo de promoção e rollback dos deploys.

Uma outra abordagem seria utilizar pipelines específicos para cada ação (promote/rollback), porém isso aumentaria a carga cognitiva na execução dos pipelines.
Outras abordagens estão sendo estudadas para o futuro, como a utilização de gates e UI do argo-rollouts.

Nesse fluxo serão utilizados todos os ambientes da seção anterior, mais as seguintes nomenclaturas:

- **deploy-dev-promote**: Promoção para o ambiente de desenvolvimento
- **deploy-dev-rollback**: Rollback do ambiente de desenvolvimento
- **deploy-esteira1-promote**: Promoção para a esteira de testes 1
- **deploy-esteira1-rollback**: Rollback da esteira de testes 1
- **deploy-esteira2-promote**: Promoção para a esteira de testes 2
- **deploy-esteira2-rollback**: Rollback da esteira de testes 2
- **deploy-prodlike-promote**: Promoção para o ambiente similar ao de produção
- **deploy-prodlike-rollback**: Rollback do ambiente similar ao de produção
- **deploy-preprod-promote**: Promoção para o ambiente de pré-produção
- **deploy-preprod-rollback**: Rollback do ambiente de pré-produção
- **deploy-producao-promote**: Promoção para o ambiente de produção
- **deploy-producao-rollback**: Rollback do ambiente de produção

**Deploys IaC:**

**Motivação**: As execuções dos pipelines de infraestrutura seguem um fluxo de aprovação diferente dos deploys convencionais, por isso é necessário ter uma convenção própria para esses casos.

- **terraform-approval-apply-dev**: Aprovação para aplicar mudanças de infraestrutura no ambiente de desenvolvimento
- **terraform-approval-destroy-dev**: Aprovação para destruir infraestrutura no ambiente de desenvolvimento
- **terraform-approval-apply-test**: Aprovação para aplicar mudanças de infraestrutura no ambiente de teste
- **terraform-approval-destroy-test**: Aprovação para destruir infraestrutura no ambiente de teste
- **terraform-approval-apply-producao**: Aprovação para aplicar mudanças de infraestrutura no ambiente de produção
- **terraform-approval-destroy-producao**: Aprovação para destruir infraestrutura no ambiente de produção

## Consequences

Essa mudança padroniza apenas o nome dos ambientes no Azure DevOps, não impactando diretamente os nomes dos ambientes em outras ferramentas ou plataformas.

A adoção dessa convenção trará os seguintes benefícios:

- Redução da complexidade na gestão dos projetos, facilitando a identificação dos ambientes corretos.
- Redução na complexidade de setup de projetos, com menos environments criados.
- Melhoria na comunicação entre equipes, com uma nomenclatura clara e padronizada.
- Facilidade em a implementação de políticas de segurança e controle de acesso baseadas em ambientes.
- Facilidade em extrair métricas e relatórios sobre o uso dos ambientes.

Para ser possível implementar essa convenção, será necessário mapear o nome do environment real e o nome do environment no azure-devops em todos os projetos que não seguem a convenção proposta. Exemplo:

```yaml
parameters:
...
- name: azdoEnvironmentMapping
  description: Mapeamento dos nomes dos ambientes reais para os nomes dos environments no Azure DevOps (ReadOnly)
  type: object
  default:
    dev: deploy-dev
    development: deploy-dev
    test: deploy-esteira1
    staging: deploy-preprod
    prod: deploy-prod
    production: deploy-producao
...
  jobs:
  - deployment: 'helmDeployment'
    displayName: Deploy em ${{ parameters.environment }}
    environment:
      name: ${{ parameters.azdoEnvironmentMapping[parameters.environment] }}
...
```
## References

### Tabela de uso de environments atuais

> TODO: Mapear os nomes dos environments atuais e que estão em uso para a nova convenção proposta. ADR deve ser atualizada.

| Environment Name | Total | Ativos | Nunca Usados | % Não Usado | Nº Projetos |
|---|---:|---:|---:|---:|---:|
| deploy-dev | 334 | 111 | 223 | 66.8 | 334 |
| deploy-esteira2 | 332 | 43 | 289 | 87.0 | 332 |
| deploy-prodlike | 332 | 63 | 269 | 81.0 | 332 |
| deploy-preprod | 332 | 89 | 243 | 73.2 | 332 |
| deploy-lib | 332 | 73 | 259 | 78.0 | 332 |
| deploy-producao | 332 | 78 | 254 | 76.5 | 332 |
| deploy-esteira1 | 332 | 68 | 264 | 79.5 | 332 |
| deploy-development | 325 | 18 | 307 | 94.5 | 325 |
| deploy-production | 324 | 17 | 307 | 94.8 | 324 |
| deploy-dev-rollback | 322 | 7 | 315 | 97.8 | 322 |
| deploy-homologation | 322 | 15 | 307 | 95.3 | 322 |
| deploy-dev-promote | 321 | 8 | 313 | 97.5 | 321 |
| deploy-development-promote | 320 | 1 | 319 | 99.7 | 320 |
| deploy-development-rollback | 320 | 1 | 319 | 99.7 | 320 |
| deploy-prodlike-rollback | 319 | 1 | 318 | 99.7 | 319 |
| deploy-prodlike-promote | 319 | 1 | 318 | 99.7 | 319 |
| deploy-producao-promote | 319 | 4 | 315 | 98.7 | 319 |
| deploy-lib-promote | 319 | 0 | 319 | 100.0 | 319 |
| deploy-esteira1-rollback | 319 | 4 | 315 | 98.7 | 319 |
| deploy-homologation-promote | 319 | 0 | 319 | 100.0 | 319 |
| deploy-homologation-rollback | 319 | 0 | 319 | 100.0 | 319 |
| deploy-lib-rollback | 319 | 0 | 319 | 100.0 | 319 |
| deploy-preprod-rollback | 319 | 4 | 315 | 98.7 | 319 |
| deploy-preprod-promote | 319 | 4 | 315 | 98.7 | 319 |
| deploy-producao-rollback | 319 | 3 | 316 | 99.1 | 319 |
| deploy-esteira2-promote | 319 | 1 | 318 | 99.7 | 319 |
| deploy-esteira1-promote | 319 | 4 | 315 | 98.7 | 319 |
| deploy-esteira2-rollback | 319 | 0 | 319 | 100.0 | 319 |
| deploy-production-rollback | 317 | 0 | 317 | 100.0 | 317 |
| deploy-production-promote | 317 | 0 | 317 | 100.0 | 317 |
| terraform-approval-apply-dev | 49 | 30 | 19 | 38.8 | 49 |
| terraform-approval-apply-test | 48 | 29 | 19 | 39.6 | 48 |
| terraform-approval-apply-prod | 48 | 28 | 20 | 41.7 | 48 |
| terraform-approval-destroy-dev | 46 | 23 | 23 | 50.0 | 46 |
| terraform-approval-destroy-test | 45 | 18 | 27 | 60.0 | 45 |
| terraform-approval-destroy-prod | 43 | 17 | 26 | 60.5 | 43 |
| deploy-prod | 19 | 19 | 0 | 0.0 | 19 |
| terraform-approval-apply-shared | 15 | 7 | 8 | 53.3 | 15 |
| terraform-approval-destroy-shared | 14 | 3 | 11 | 78.6 | 14 |
| deploy-hml | 12 | 12 | 0 | 0.0 | 12 |
| deploy-from_branch | 7 | 2 | 5 | 71.4 | 7 |
| dev | 7 | 3 | 4 | 57.1 | 7 |
| deploy-db-dev | 6 | 5 | 1 | 16.7 | 6 |
| rollback-db-dev | 5 | 4 | 1 | 20.0 | 5 |
| deploy-digibee-prod | 4 | 1 | 3 | 75.0 | 4 |
| deploy-digibee-preprod | 4 | 1 | 3 | 75.0 | 4 |
| deploy-digibee-test | 4 | 3 | 1 | 25.0 | 4 |
| rollback-db-producao | 3 | 1 | 2 | 66.7 | 3 |
| rollback-db-prodlike | 3 | 0 | 3 | 100.0 | 3 |
| deploy-manager-esteira1 | 3 | 3 | 0 | 0.0 | 3 |
| rollback-db-preprod | 3 | 0 | 3 | 100.0 | 3 |
| publish-lib | 3 | 1 | 2 | 66.7 | 3 |
| deploy-preproducao | 3 | 1 | 2 | 66.7 | 3 |
| DEV | 3 | 3 | 0 | 0.0 | 3 |
| PROD | 3 | 2 | 1 | 33.3 | 3 |
| deploy-manager-prodlike | 3 | 3 | 0 | 0.0 | 3 |
| deploy-manager-prod | 3 | 3 | 0 | 0.0 | 3 |
| deploy-manager-preprod | 3 | 3 | 0 | 0.0 | 3 |
| deploy-manager-esteira2 | 3 | 3 | 0 | 0.0 | 3 |
| deploy-db-prodlike | 3 | 1 | 2 | 66.7 | 3 |
| deploy-db-preprod | 3 | 2 | 1 | 33.3 | 3 |
| vivo-core-pipelines-approval | 3 | 2 | 1 | 33.3 | 3 |
| deploy-db-producao | 3 | 1 | 2 | 66.7 | 3 |
| deploy-manager-dev | 3 | 3 | 0 | 0.0 | 3 |
| prod | 3 | 2 | 1 | 33.3 | 3 |
| rollback-dev | 3 | 1 | 2 | 66.7 | 3 |
| deploy-esteira-01 | 2 | 0 | 2 | 100.0 | 2 |
| deploy-nodemanager-dev | 2 | 2 | 0 | 0.0 | 2 |
| rollback-db-esteira2 | 2 | 0 | 2 | 100.0 | 2 |
| Prod | 2 | 2 | 0 | 0.0 | 2 |
| deploy- | 2 | 0 | 2 | 100.0 | 2 |
| deploy-db-esteira1 | 2 | 2 | 0 | 0.0 | 2 |
| deploy-producao_par | 2 | 1 | 1 | 50.0 | 2 |
| deploy-producao_impar | 2 | 2 | 0 | 0.0 | 2 |
| deploy-producao_bd | 2 | 1 | 1 | 50.0 | 2 |
| deploy-qa | 2 | 2 | 0 | 0.0 | 2 |
| deploy-desenvolvimento | 2 | 0 | 2 | 100.0 | 2 |
| deploy-db-esteira2 | 2 | 2 | 0 | 0.0 | 2 |
| hml | 2 | 2 | 0 | 0.0 | 2 |
| deploy-esteira-03 | 2 | 0 | 2 | 100.0 | 2 |
| deploy-esteira-02 | 2 | 0 | 2 | 100.0 | 2 |
| brm_ | 2 | 0 | 2 | 100.0 | 2 |
| deploy-nodemanager-noprod | 2 | 2 | 0 | 0.0 | 2 |
| rollback-db-esteira1 | 2 | 2 | 0 | 0.0 | 2 |
| deploy-lab6 | 2 | 0 | 2 | 100.0 | 2 |
| teste | 2 | 1 | 1 | 50.0 | 2 |
| producao | 2 | 0 | 2 | 100.0 | 2 |
| HML | 2 | 0 | 2 | 100.0 | 2 |
| ESTEIRA1 | 2 | 1 | 1 | 50.0 | 2 |
| deploy-nodemanager-prod | 2 | 2 | 0 | 0.0 | 2 |
| tech-product-deploy-prodlike | 2 | 2 | 0 | 0.0 | 2 |
| tech-product-deploy-prod | 2 | 2 | 0 | 0.0 | 2 |
| tech-product-deploy-preprod | 2 | 2 | 0 | 0.0 | 2 |
| tech-product-deploy-dev | 2 | 2 | 0 | 0.0 | 2 |
| ESTEIRA2 | 2 | 1 | 1 | 50.0 | 2 |
| deploy-brtlvlts1516pl | 1 | 1 | 0 | 0.0 | 1 |
| deploy-bis_lab | 1 | 1 | 0 | 0.0 | 1 |



