# 5. Uso de template para AppSec

Date: 2025-11-11

## Status

Proposed

## Context

No CodePlay e Core Pipelines, a equipe de AppSec definiu um template padrão para a integração de verificações de segurança de aplicações (AppSec) nos pipelines de CI/CD. Este template visa padronizar a forma como as verificações de segurança são implementadas, garantindo consistência, eficiência e facilidade de manutenção.

No Framework desenvolvemos uma custom task, seguindo o principio de Custom Task First. Porém a mudança de paradigma pode ser grande a primeira vista. Para seguirmos com a estratégia de App Sec no framework, iremos adotar o template definido pela equipe de AppSec e introduzir a custom task de maneira gradual, para garantir que todo o time de appsec esteja confortável com a mudança.

## Decision

Decidimos adotar o template padrão definido pela equipe de AppSec para a integração de verificações de segurança nos pipelines de CI/CD do Framework. Esta decisão foi tomada para garantir que nossas práticas de segurança estejam alinhadas com as diretrizes estabelecidas pela equipe especializada, promovendo uma abordagem consistente e eficaz na detecção e mitigação de vulnerabilidades.

Em paralelo, iniciaremos um processo de avaliação e adaptação da custom task desenvolvida no Framework, visando sua integração futura de maneira que complemente e potencialize as funcionalidades oferecidas pelo template padrão. Este processo será conduzido em colaboração com a equipe de AppSec para assegurar que todas as necessidades e requisitos de segurança sejam atendidos.

## Consequences

Adotar o template padrão da equipe de AppSec, todos os pipelines do framework, deverão ser modificados para incorporar o template seguindo o padrão estabelecido no [ADR - 0004 - Estágios de AppSec nos Pipelines](0004-estagios-de-appsec-nos-pipelines.md). Isso garantirá que as verificações de segurança sejam implementadas de forma consistente e eficaz, alinhadas com as melhores práticas recomendadas pela equipe de AppSec.

Em paralelo, iniciaremos um processo de avaliação da custom task desenvolvida no Framework. Este processo envolverá a análise detalhada das funcionalidades e capacidades da custom task, comparando-as com as oferecidas pelo template padrão. O objetivo é identificar oportunidades de integração que possam melhorar a eficácia das verificações de segurança, sem comprometer a consistência e a padronização proporcionadas pelo template.

A mudança deve ser feita de modo que não precise de alterações no arquivos `.azuredevops/pipelines.yml` dos projetos que utilizam o framework, para evitar retrabalho e facilitar a adoção.
