# CodePlay Framework

Bem-vindo ao CodePlay Framework! Este guia apresenta de forma concisa os principais conceitos, regras e estruturas que compõem o framework de pipelines, ajudando você a entender como utilizá-lo e estendê-lo.

## Objetivos do Framework

- Fornecer pipelines prontos para uso, cobrindo os principais cenários de desenvolvimento e entrega contínua.
- Fornecer um padrão para criação e manutenção de pipelines.
- Cobrir 80% dos casos comuns de forma simples e eficiente.
- Permitir customizações para cenários específicos (20% restantes).
- Habilitar o pipeline e suas capacidades de maneira self-service, sem necessidade de suporte adicional.
- Suporte otimizado, com guia de erros comuns e filas prioritárias para resolução de problemas.

:::info
Se preocupe com o desenvolvimento do código e deixe o framework cuidar da construção, garantia de qualidade e segurança e entrega do software.
:::

## FAQ

## Sou desenvolvedor e preciso de um pipeline

O codeplay framework visa ter pipelines para os principais cenários prontos para uso.

Você pode consultar quais os pipelines disponíveis no nosso [catálogo](https://dvps.redecorp.azr/portal/catalog/pipelines).

## Preciso de um pipeline de CI e outro para CD?

Sim, o framework busca desacoplamento, respingabilidade única e reaproveitamento de código. Três pilares que só são possíveis por conta dessa abordagem.

## Como configurar o CD para ser acionado pelo CI?

Utilize o gatilho de repositório (repository resource trigger) para acionar o pipeline de CD a partir do CI.

Saiba mais em:

- https://dvps.redecorp.azr/portal/code/casos-de-uso/integrando-cicd
- https://learn.microsoft.com/pt-br/azure/devops/pipelines/process/resources?view=azure-devops&tabs=schema#pipelines-resource

## Não encontrei um pipeline que atenda às minhas necessidades

Se você não encontrou um pipeline que atenda às suas necessidades procure alguém da equipe de DevOps para analisarmos o caso. Podemos:

1. Entender juntos a necessidade e verificar se um pipeline existente pode ser adaptado.
2. Criar um novo pipeline do zero, seguindo as diretrizes e práticas recomendadas do framework.
3. Sugerir que evolua um pipeline existente para atender suas necessidades via Inner Source.

### O que é o CodePlay Framework?

O CodePlay Framework são pipelines prontos para uso, de maneira self-service que habilita [capacidades](https://dvps.redecorp.azr/portal/codeplay/capacidades/), segundo as principais boas praticas de mercado.
Além disso implementa uma série de diretrizes e práticas recomendadas para a criação e manutenção de pipelines de CI/CD, visando facilitar a entrega contínua de software com qualidade e segurança.

### Como o framework lida com casos de uso específicos?

O framework foi projetado para cobrir 80% dos casos comuns de forma simples e eficiente. Para os 20% restantes, que podem envolver cenários específicos, o framework permite customizações e extensões conforme necessário.

### Nenhum pipeline atende meu cenário, o que fazer?

Se nenhum pipeline atende ao seu cenário, você pode criar um pipeline personalizado. Para isso, você pode:

#### 1. Evoluir um pipeline existente no framework

Se a funcionalidade que você precisa irá atender 80% dos casos de uso, você pode evoluir um pipeline existente. Siga o guia de [Evolução de Pipelines](/codeplay/framework/evolucao.md#evoluindo-um-pipeline-existente).

#### 2. Criar um novo pipeline

Se a funcionalidade que você precisa é muito específica e não atende 80% dos casos de uso, você pode criar um novo pipeline. Siga o guia de [Criação de Pipelines](/codeplay/framework/evolucao.md#criando-um-novo-pipeline).

Lembre-se de seguir as boas práticas de desenvolvimento e documentação, se preciso faça uma reunião de alinhamento com os mantedores do framework para garantir que sua implementação esteja alinhada com as diretrizes do projeto.

Lembre-se também que ao criar um pipeline especifico para seu caso de uso, você deve assinar a carta de [exceção de fluxo](/codeplay/framework/modelo-carta-de-excecao.md).

### Quais são os principais benefícios de usar o CodePlay Framework?

Os principais benefícios incluem:
- Padronização na criação de pipelines.
- Agilidade na entrega de valor.
- Redução de retrabalho.
- Suporte otimizado e documentação clara.

## Como Usar Este Guia

Visite o portal para mais infos.

https://dvps.redecorp.azr/portal/codeplay/framework/

---

Siga este fluxo para explorar o framework de maneira organizada. Em cada seção você encontrará descrições, exemplos e detalhes técnicos para aplicar as melhores práticas em seus pipelines.

### E se eu precisar de ajuda?

Leia mais sobre os pedidos de ajuda e suporte em [Suporte e Ajuda](https://dvps.redecorp.azr/portal/codeplay/roteiro/suporte).

### Existe algum canal para entrar em contato?

Sim, Entre no [Canal Azure DevOps - CodePlay no Teams](https://dvps.redecorp.azr/portal/codeplay/codeplay/canal).

## Links Úteis

Os exemplos de teste agora vivem em repositórios individuais por pipeline. Consulte os READMEs em [pipelines](pipelines) para localizar o repositório correspondente.

Pipeline de testes: https://dev.azure.com/telefonica-vivo-brasil/DevOps/_build?definitionScope=%5Ctestes-codeplay-framework

CodePlay Framework: https://dev.azure.com/telefonica-vivo-brasil/DevOps/_git/Vivo.CodePlay.Pipelines?path=/framework