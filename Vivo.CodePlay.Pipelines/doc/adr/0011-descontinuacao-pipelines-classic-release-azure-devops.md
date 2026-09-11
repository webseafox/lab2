# 11. Descontinuação de Pipelines Classic e Release no Azure DevOps
2026-05-25

## Status

Accepted


## Contexto

Atualmente, as organizações de produção e pré-produção do Azure DevOps possuem utilização de pipelines do tipo Classic Build e Classic Release para execução de processos de integração e entrega contínua (CI/CD).

Esse modelo apresenta limitações relacionadas à governança, rastreabilidade, padronização e segurança operacional, principalmente por depender de configurações realizadas manualmente via interface gráfica.

Além disso, pipelines Classic dificultam:

- versionamento das configurações;
- revisão estruturada de alterações;
- reutilização de padrões corporativos;
- auditoria de mudanças;
- integração com práticas modernas de DevSecOps;
- padronização entre equipes e projetos.

O modelo baseado em YAML permite que os pipelines sejam tratados como código (Pipeline as Code), possibilitando maior controle, rastreabilidade e alinhamento às boas práticas de mercado e às diretrizes modernas de engenharia de plataforma.

Considerando a necessidade de evolução da governança DevOps corporativa, redução de riscos operacionais e fortalecimento dos controles de segurança, foi definida a estratégia de descontinuação gradual do uso de pipelines Classic e Release.


## Decisão

Fica definida a descontinuação da criação e utilização de pipelines Classic Build e Classic Release nas organizações de produção e pré-produção do Azure DevOps.

Os times deverão adotar pipelines baseados em YAML para implementação e manutenção de fluxos de CI/CD.

Como parte da iniciativa:

- novos pipelines deverão ser criados exclusivamente em YAML;
- pipelines Classic existentes deverão passar por processo de migração gradual;
- padrões e boas práticas corporativas deverão ser aplicados aos pipelines YAML;
- documentações e orientações técnicas deverão ser disponibilizadas aos times envolvidos.


## Estrutura Básica de um Pipeline YAML

Na Vivo, os pipelines são centralizados no repositório `Vivo.CodePlay.Pipelines`, trazendo padronização e visibilidade para os processos de CI/CD.

```yaml
# /pipelines/ci.yaml
parameters:
  - name: parameterExample
    type: string
    default: 'Default Value'

variables:
  - name: EXAMPLE_VARIABLE
    value: 'Example Value'

stages:
  - stage: StageName
    displayName: 'Stage Display Name'
    jobs:
      - job: JobName
        pool: GeneralPurposeLinuxAgents
        steps:
          - task: Bash@3
            inputs:
              targetType: inline
              script: |
                echo "Hello, World!"
                echo "[debug] Example Variable: $(EXAMPLE_ENV_VAR)"
                echo "[command] Parameter Example: ${{ parameters.parameterExample }}"
            env:
              EXAMPLE_ENV_VAR: $(EXAMPLE_VARIABLE)
```

---

## Motivação

### Governança

A adoção de pipelines YAML permite:

- padronização corporativa dos processos de CI/CD;
- versionamento das configurações junto ao código-fonte;
- rastreabilidade completa de alterações;
- revisão via Pull Request;
- reutilização de templates compartilhados;
- redução de dependência de configurações manuais;
- maior visibilidade operacional dos pipelines;
- maior compatibilidade com ferramentas de IA.

### Segurança

A descontinuação do modelo Classic contribui para:

- redução da superfície de ataque associada a alterações manuais;
- aumento da auditabilidade das mudanças;
- controle das alterações via repositório Git;
- aplicação de políticas de aprovação e revisão;
- fortalecimento das práticas de DevSecOps;
- redução de riscos operacionais e incidentes relacionados à configuração.

### Arquitetura e Boas Práticas

A decisão também visa:

- alinhamento às recomendações atuais da plataforma;
- adoção do conceito de Pipeline as Code;
- maior escalabilidade operacional;
- melhoria da manutenção e suporte;
- aumento da consistência entre ambientes e projetos.


## Consequências

### Positivas

- maior padronização entre os times;
- melhor rastreabilidade e controle de alterações;
- fortalecimento da governança DevOps;
- redução de riscos operacionais;
- maior aderência às práticas de segurança;
- facilidade de reutilização e manutenção;
- melhor integração com práticas DevSecOps.

### Impactos Esperados

- esforço de migração de pipelines existentes;
- necessidade de atualização de documentações e processos;


## Referências

- [YAML vs Classic Pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/pipelines-get-started?view=azure-devops)
- [Azure Pipelines](https://dvps.redecorp.azr/portal/codeplay/roteiro/azure-pipelines/?_highlight=ymal#m%C3%A9todo-2-via-yaml-recomendado)