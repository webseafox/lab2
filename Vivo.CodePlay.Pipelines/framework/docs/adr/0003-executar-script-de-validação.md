# 3. Executar Script de Validação

Date: 2025-11-03

## Status

Accepted

## Context

Com o passar do tempo e o aumento da complexidade dos pipelines de CI/CD, tornou-se evidente a necessidade de garantir que todas as definições de pipeline estejam em conformidade com as melhores práticas e padrões estabelecidos pela equipe de DevOps. Atualmente, a validação manual dessas definições é propensa a erros e consome um tempo valioso da equipe. 

Mesmo utilizando IA, a janela de contexto pode ser limitada, e a validação automática pode ajudar a garantir que as definições de pipeline estejam corretas antes de serem implementadas.

Com base nisso, propomos a adoção de um script de validação automatizado que possa ser executado como parte do processo de integração contínua. Este script verificará as definições de pipeline contra um conjunto predefinido de regras e padrões, garantindo que qualquer desvio seja identificado e corrigido antes da implementação.

Lembrando que um dos pilares do framework é a padronização, convenções e confiabilidade da documentação. Portanto, a implementação deste script de validação é crucial para manter a integridade e a qualidade dos pipelines de CI/CD.

## Decision

Decidimos implementar um script de validação automatizado que será integrado ao processo de CI/CD. Este script será responsável por verificar as definições de pipeline contra um conjunto de regras e padrões estabelecidos pela equipe de DevOps.

O script foi desenvolvido em [codeplay-framework-validator](https://dev.azure.com/telefonica-vivo-brasil/DVPS%20-%20DEVOPS/_git/codeplay-framework-validator). E é importando para o repositório através da lib python `pipeline-validator`, que será instalado no ambiente virtual do projeto, utilizando `make setup-complete`.

## Consequences

A implementação deste script de validação trará vários benefícios para a equipe de DevOps e para o processo de CI/CD como um todo:

- **Redução de Erros**: A validação automatizada reduzirá significativamente a probabilidade de erros humanos na definição dos pipelines, garantindo que todas as definições estejam em conformidade com os padrões estabelecidos.
- **Economia de Tempo**: A automação do processo de validação permitirá que a equipe de DevOps se concentre em tarefas mais estratégicas, economizando tempo que seria gasto na validação manual.
- **Melhoria Contínua**: Com a validação automatizada, será possível identificar rapidamente quaisquer desvios dos padrões estabelecidos, permitindo uma melhoria contínua dos processos de CI/CD.
- **Documentação Atualizada**: A integração do script de validação com o processo de CI/CD garantirá que a documentação dos pipelines esteja sempre atualizada e em conformidade com as melhores práticas.
- **Facilidade de Uso**: A inclusão de comandos no Makefile, como `make validate` e `make validate-help`, facilitará a execução do script de validação pelos membros da equipe, promovendo sua adoção e uso consistente.
- **Listagem de Políticas**: A adição do comando `make validate-list` permitirá que os usuários visualizem facilmente as políticas disponíveis no validador de pipelines, facilitando a compreensão das regras aplicadas durante a validação.

