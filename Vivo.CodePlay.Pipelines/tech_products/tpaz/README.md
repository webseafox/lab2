# Vivo Core Pipelines

O Vivo Core Pipelines fornece um conjunto de pipelines que disponibilizam processos de validação de qualidade, construção, implantação e auto remediação em múltiplas plataformas.

Seu objetivo é fornecer um caminho ágil e simples que não menospreza qualidade, segurança e disponibilidade.

O projeto foi organizado de modo a simplificar o seu entendimento e evolução.

O principal foco do Vivo Core Pipeline é ser um projeto evolutivo que consiga adequar-ser aos objetivos de forma escalável sem a necessidade da intervenção de alguém do time para novos pipelines, evitando gargalos.

Uma vez que uma tecnologia esteja disponível, temos o objetivo que isso seja o suficiente para atender todos que tenham as mesmas necessidades, evitando desenvolvimentos sem fim.

Todos os pipelines que definem os fluxos principais estão organizados como archetypes agrupados por tipos de tecnologia.

## Versioning

### Branching model
Atalmente o utilizado para o Inner Source é **Short-Lived Feature Branches**

### Tags
O versionamento de tags é automático a cada Pull Request completado seguindo o [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)

As tags "deslizantes" são atualizadas apenas pela equipe de **DevOps Estruturante**

> - v1
> - latest

O uso das tags acima por parte dos projetos é recomendado para um rollout mais ágil de novas features e correções serem incorparadas nas esteiras de CI/CD que utilizam templates do Core.

## Agent Pools

Os pools de agentes para execução dos pipelines são mantidos pela equipe DevOps.

Consulte mais detalhes na página [Agent pools](https://wikicorp.telefonica.com.br/x/eQ3OGg) da wiki do time DevOps.

### GeneralPurposeLinuxAgentsCI

Utilizado pela maioria dos jobs de CI e que não necessitam de liberações de Rede ambientes privados da Cloud.

- Build
- Tests
- Quality Gates
- Package
- Validation

### GeneralPurposeLinuxAgentsCD

Utilizado pelos seguintes use-cases:
- CI/CD de IaC (Terraform na Azure)
- Stages de Deploy (Cloud & On-Premise)

### VivoOnPremDevAgents, VivoOnPremHmlAgents e VivoOnPremPrdAgents

Utilizados para stages de deploy que necessitam acesso de network nos ambientes On-Premise da Vivo

### TestRunnerAgents

Testes automatizados para garantir a qualidade dos templates e alterações para prevenir impactos nos clientes do Core Pipeline.

## Documentação
[Link Wiki Corporativa do Vivo Core Pipelines](https://wikicorp.telefonica.com.br/display/AC/Vivo+Core+Pipelines)
