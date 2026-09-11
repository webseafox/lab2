# 18. Integração da Custom Task de Config Compliance nos modelos de pipelines

Date: 2026-08-27

## Status

Accepted

## Context

Os modelos corporativos de pipelines são utilizados por diversos projetos e representam um dos principais mecanismos para padronização dos processos de CI/CD.

A custom task `VivoDevOpsConfigCompliance@1`, definida no **ADR 17 — Validação de Políticas de Configuração com OPA**, precisa ser incorporada aos modelos e pipelines elegíveis para que os pipelines que produzem artefatos Docker executem as validações de configuração de forma padronizada.

Nesta primeira etapa, o rollout será direcionado aos pipelines que produzem artefatos Docker, contemplando:

- Modelos do **Vivo Core Pipelines**;
- Templates do **CodePlay Framework**;
- Modelos Inner Source de Package em Docker presentes nos Tech Products, considerando os modelos existentes na branch `master` do repositório `Vivo.CodePlay.Pipelines` no momento do inventário;
- Pipelines dos times que estejam dentro do escopo definido para o rollout.

Como a task depende do conteúdo do repositório para realizar a análise, sua integração deve ocorrer em um contexto de pipeline que possua acesso ao código-fonte por meio de checkout.

O mecanismo de execução da task, obtenção das políticas, utilização do bundle centralizado e integração com o mecanismo de governança seguem as decisões estabelecidas no **ADR 17**.

## Decision

Será realizada a integração da custom task `VivoDevOpsConfigCompliance@1` nos modelos e pipelines elegíveis que produzem artefatos Docker, tornando a validação de Config Compliance uma etapa do fluxo de execução desses pipelines.

O rollout inicial seguirá o escopo definido no Context desta ADR, abrangendo os modelos do Vivo Core Pipelines, CodePlay Framework, os modelos Inner Source de Package em Docker identificados no inventário e os pipelines dos times incluídos no escopo.

A integração seguirá as seguintes diretrizes:

1. **Integração nos pipelines:** os modelos e pipelines elegíveis deverão incluir a `VivoDevOpsConfigCompliance@1` em seu fluxo de execução.

2. **Contexto de execução:** a task deverá ser executada em um job que possua acesso ao repositório da aplicação, garantindo acesso aos arquivos que serão avaliados.

3. **Configuração centralizada:** a task utilizará a configuração corporativa definida conforme o mecanismo estabelecido no ADR 17.

Pipelines que não estejam no escopo Docker da primeira etapa não serão alterados por este rollout.

## Consequences

### Positivas

- **Aplicação padronizada:** os modelos e pipelines definidos no escopo passam a incorporar a validação de Config Compliance como parte do fluxo de execução.

- **Maior cobertura de segurança:** os artefatos Docker produzidos pelos pipelines integrados passam a ser avaliados pelas políticas corporativas de Config Compliance.

- **Políticas centralizadas:** as regras utilizadas pela validação permanecem centralizadas na configuração corporativa, evitando a replicação das políticas nos diferentes projetos.

### Negativas / Pontos de atenção

- **Alteração dos pipelines:** os modelos e pipelines existentes precisam ser atualizados para incluir a `VivoDevOpsConfigCompliance@1`.

- **Manutenção da integração:** alterações futuras na forma de execução da task ou nos templates podem exigir atualização dos modelos e pipelines envolvidos.

- **Falhas de configuração:** problemas no acesso à configuração corporativa ou ao bundle de políticas podem impedir a execução da validação.

## Impacto nos projetos consumidores

Os projetos consumidores que utilizam os modelos de pipeline incluídos no escopo desta ADR serão impactados pela inclusão da task `VivoDevOpsConfigCompliance@1` no fluxo de validação.

Os pipelines dos times incluídos no escopo também deverão ser atualizados para incorporar a task, quando aplicável.

Os times consumidores deverão acompanhar os resultados das validações e corrigir as violações identificadas.

Quando uma exceção for necessária, ela deverá seguir o processo corporativo de waiver, contendo justificativa, aprovação e prazo de validade conforme as regras aplicáveis.

Projetos e pipelines que não estejam incluídos no escopo definido para o rollout inicial não serão impactados diretamente.

## Próximos passos

- Monitorar a cobertura da `VivoDevOpsConfigCompliance@1` nos modelos e pipelines incluídos no inventário.
- Acompanhar violações, falsos positivos e impacto no tempo de execução dos pipelines.
- Manter o inventário atualizado conforme novos modelos e pipelines sejam criados, removidos ou alterados.
- Evoluir os templates corporativos conforme novas necessidades de Config Compliance sejam identificadas.
- Avaliar a ampliação da validação para outros tipos de artefato, mediante definição formal do novo escopo.

## Referências

- ADR 17 — Validação de Políticas de Configuração com OPA
- Custom Task `VivoDevOpsConfigCompliance@1`
