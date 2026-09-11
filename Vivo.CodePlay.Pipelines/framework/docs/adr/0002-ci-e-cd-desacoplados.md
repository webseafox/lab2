# 2. CI e CD Desacoplados

Date: 2025-10-31

## Status

Accepted

## Context

Precisamos separar os processos de Integração Contínua (CI) e Entrega Contínua (CD) para melhorar a flexibilidade e eficiência do pipeline de desenvolvimento.

## Decision

Templates Prontos para uso de pipelines de CI e CD serão criados e mantidos separadamente. O pipeline de CI será responsável por construir, testar e validar o código, enquanto o pipeline de CD será focado na implantação e entrega do software para os ambientes apropriados.

## Consequences

### Pros:

- Maior flexibilidade na gestão dos pipelines.
- Reaproveitamento dos pipelines em diferentes casos de uso.
- Facilidade na manutenção e atualização dos processos de CI e CD.
- Templates prontos para uso com o mínimo de configuração necessária.
- Desacoplamento dos processos de CI e CD, permitindo que equipes diferentes possam trabalhar de forma independente.
- Pipelines com o mínimo de saltos (templates) necessários.
- Pipelines fáceis de entender, manter e implementar.
- Documentação clara e concisa para facilitar a adoção pelos times.
- Sem lock-in com ferramentas específicas, permitindo a adaptação a diferentes tecnologias e plataformas.

### Contras:

- Pode haver uma curva de aprendizado inicial para as equipes se adaptarem à nova estrutura.
- Requer uma boa coordenação entre as pipelines de CI e CD para garantir que o fluxo de trabalho seja eficiente.
- Necessário configurar pipelines para CI e CD separadamente.
- Necessário criar triggers adicionais para que o fluxo seja contínuo.

