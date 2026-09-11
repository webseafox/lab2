# 6. Uso do Sonar

Date: 2026-01-06

## Status

Accepted

## Context

O SonarQube é uma ferramenta amplamente utilizada para análise contínua de código, ajudando a identificar bugs, vulnerabilidades e code smells. A integração do SonarQube no nosso fluxo de desenvolvimento visa melhorar a qualidade do código e garantir a conformidade com os padrões estabelecidos.

O Sonar utilizado nos pipelines é a versão comunitária (Community Edition), que é gratuita e oferece funcionalidades básicas de análise de código. No entanto, essa versão possui limitações, como a ausência de paralelismo na análise, o que pode resultar em filas de espera mais longas quando múltiplos projetos são analisados simultaneamente. A fila por sua vez pode impactar o tempo de feedback para os desenvolvedores e elevar consideravelmente o tempo total de execução dos pipelines.

Notamos que grande parte dos projetos hoje no DevOps não fazem uso de gates de qualidade, basicamente é utilizado para métricas, porém isso consome a fila do sonar tornando a análise de quem realmente precisa mais demorada.

Visando melhorar o tempo de fila para projetos que querem ter um controle de qualidade mais rigoroso, construímos uma segunda instancia do SonarQuebe, que chamamos de "Sonar VIP". Essa instância é dedicada exclusivamente para projetos que implementam gates de qualidade, garantindo que esses projetos tenham prioridade na análise e recebam feedback mais rápido.

O Sonar Comum seria utilizado apenas como caráter informativo, para métricas e monitoramento, sem gates de qualidade. Enquanto o Sonar VIP seria utilizado para projetos que necessitam de uma análise mais rigorosa e controle de qualidade, com gates de qualidade implementados.

Agora, precisamos definir uma política clara para o uso dessas duas instâncias do SonarQube, garantindo que os projetos sejam direcionados corretamente com base em suas necessidades de qualidade e análise de código.

Atualmente para controle de gates é utilizado uma flag no AppConfig.
No sonar VIP, está sendo desenvolvido um processo de *waivers* para permitir que equipes possam justificar exceções em relação a certos padrões de qualidade, garantindo flexibilidade sem comprometer a integridade do código.

Perguntas a serem respondidas:

- Quais projetos devem utilizar o Sonar VIP?
- Quais critérios devem ser atendidos para que um projeto possa utilizar o Sonar VIP?
- Como saber quais times utilizam o SonarVIP?
- Como será monitorada a fila do SonarVIP para evitar sobrecarga?
- Será permitido que projetos utilizem ambas as instâncias do SonarQube, ou devem escolher apenas uma?
- Será permitido executar gates de qualidade em ambas as instâncias, ou apenas no Sonar VIP?
- O sistema de waivers será exclusivo do Sonar VIP, ou também estará disponível no Sonar Comum?
- No sonar comum será mantido o uso do AppConfig para controle de gates?

## Decision

Decidimos implementar a seguinte política para o uso das duas instâncias do SonarQube:

**Quais projetos devem utilizar o Sonar VIP?**

- Para utilizar o SonarVIP deve ser alinhado a nível executivo.
- Projetos que usam o SonarVIP devem se comprometer a manter altos padrões de qualidade de código, incluindo a implementação de gates de qualidade rigorosos.
- O SonarVIP deve ser monitorado para evitar que exista enfileiramento.

**Quais critérios devem ser atendidos para que um projeto possa utilizar o Sonar VIP?**

- Alinhamento a nível executivo.
- Compromisso com altos padrões de qualidade de código.
- Implementação de gates de qualidade rigorosos.
- O sonar deve ter capacidade adequada para suportar a demanda do projeto.

**Como saber quais times utilizam o SonarVIP?**
Será implementado um arquivo `vip.json` junto com as politicas do waivers, onde ficará documentado os projetos que utilizam o SonarVIP. A custom task lerá esse arquivo e direcionará o pipeline para a instância correta do SonarQube. Tudo que não está no `vip.json` utilizará o Sonar Comum. Será implementado uma pagina no portal CodePlay para facilitar a consulta dos times.

**Como será monitorada a fila do SonarVIP para evitar sobrecarga?**
Hoje existe um [pipeline](https://dev.azure.com/telefonica-vivo-brasil/DevOps/_build?definitionId=39722&_a=summary) que executa todos os dias que realiza a consulta das filas do Sonar Comum e Sonar VIP.
Será melhorado esse processo e se existir enfileiramento enviar notificação para o time de DevOps para que possam tomar as ações necessárias.

**Será permitido que projetos utilizem ambas as instâncias do SonarQube, ou devem escolher apenas uma?**
Não será permitido o uso de ambas as instâncias. O projeto deve escolher apenas uma instância do SonarQube para garantir clareza e evitar confusão na análise de código. 
Ao escolher o SonarVIP, o projeto deve se comprometer a manter altos padrões de qualidade de código, incluindo a implementação de gates de qualidade rigorosos.

**Será permitido executar gates de qualidade em ambas as instâncias, ou apenas no Sonar VIP?**
Sim, mas o projeto tem que ter em mente que o Sonar Comum não possui paralelismo, então o tempo de análise pode ser maior.
No Core pipelines, existe um timeout de execução configurável, os projetos devem se atentar a essa configuração e quando o timeout é atingido a análise é passada como sucesso, podendo gerar falsos positivos.

> Completar com o comportamento esperado no Framework CodePlay (SonarUtils)

**O sistema de waivers será exclusivo do Sonar VIP, ou também estará disponível no Sonar Comum?**
Por enquanto o sistema de waivers será exclusivo do Sonar VIP, garantindo que os projetos que utilizam essa instância tenham a flexibilidade necessária para justificar exceções sem comprometer a integridade do código.
Esse ponto pode ser revisado no futuro, em alinhamento com o time de Governança DevOps.

**No sonar comum será mantido o uso do AppConfig para controle de gates?**
Será mantido o uso do AppConfig para controle de gates no Sonar Comum, permitindo que os projetos configurem suas políticas de qualidade de acordo com suas necessidades específicas. Permitido um controle granular para cada projeto.
Isso também pode ser revisado no futuro, em alinhamento com o time de Governança DevOps, para evoluir tudo para o sistema de waivers.

**Uso do NFS no sonar comum**
Avaliar viabilidade de migrar os dados do sonar comum (hoje no NFS) para um disco da maquina, para melhorar a performance e reduzir custos de manutenção.
Se essa ação mostrar uma melhora significativa, podemos avaliar o uso de waiver para todos os projetos.
Antes de realizar essa ação, deve-se esperar o término da RFP do sonar cloud.


**Coleta unificada de métricas**
Para evitar a fragmentação das métricas de qualidade entre as duas instâncias do SonarQube, está sendo utilizado o DevLake para coletar e unificar essas métricas, proporcionando uma visão consolidada da qualidade do código em toda a organização.

## Consequences

### Impactos Positivos

- **Redução do tempo de feedback para projetos críticos:** Projetos no Sonar VIP terão análises mais rápidas, permitindo ciclos de desenvolvimento mais ágeis.
- **Melhor uso dos recursos:** Separação clara entre projetos que precisam de gates rigorosos e projetos que usam o Sonar apenas para métricas.
- **Flexibilidade com waivers:** Times podem justificar exceções de forma controlada, sem comprometer a governança.
- **Governança centralizada:** O arquivo `vip.json` e o portal CodePlay facilitam a auditoria e visibilidade de quem usa cada instância.
- **Escalabilidade:** Possibilidade de ajustar a capacidade de cada instância de acordo com a demanda.

### Impactos Negativos / Trade-offs

- **Complexidade operacional aumentada:** Manter duas instâncias do SonarQube requer mais esforço de infraestrutura e monitoramento.
- **Processo de aprovação executiva:** Pode gerar atrito ou atrasos para times que precisam migrar para o Sonar VIP rapidamente.
- **Risco de fragmentação:** Métricas de qualidade podem ficar dispersas entre duas instâncias, dificultando visões consolidadas, porém isso é mitigado pelo uso do DevLake.
- **Curva de aprendizado:** Times precisam entender qual instância usar e como funciona o sistema de waivers.
- **Dependência do arquivo vip.json:** Erros no arquivo podem direcionar projetos para a instância errada.

### Riscos Identificados

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| Sobrecarga do Sonar VIP com muitos projetos | Média | Alto | Monitoramento diário + alertas + processo de aprovação executiva |
| Falsos positivos no Sonar Comum por timeout | Alta | Médio | Documentação clara + recomendação de uso do VIP para gates críticos |
| Divergência de configurações entre instâncias | Baixa | Médio | Padronização de Quality Profiles e regras entre as instâncias |
| Times burlando o processo de aprovação | Baixa | Baixo | Validação automática via custom task lendo `vip.json` |

### Dependências

- [ ] Criação de sistemas de waivers no Sonar VIP
- [ ] Implementação do arquivo `vip.json` junto com as políticas de waivers
- [ ] Adequar Custom task para leitura do `vip.json` e direcionamento automático
- [ ] Página no portal CodePlay para consulta dos times no Sonar VIP
- [ ] Melhoria do pipeline de monitoramento de filas com notificações
- [ ] Documentação do Framework CodePlay (SonarUtils) atualizada
- [ ] Avaliação da viabilidade de migração do NFS para disco local
- [ ] Aguardar término da RFP do Sonar Cloud antes de mudanças no NFS

### Métricas de Sucesso

Para avaliar se esta decisão foi bem-sucedida, monitoraremos:

1. **Tempo médio de análise no Sonar VIP** - Meta: < 15 segundos de espera na fila
2. **Taxa de falsos positivos por timeout no Sonar Comum** - Meta: reduzir em 50%
3. **Número de projetos utilizando gates de qualidade ativos** - Meta: crescimento de 20% em 6 meses
4. **Satisfação dos times** - Pesquisa trimestral com usuários do Sonar VIP

### Links e Referências

- [Pipeline de Monitoramento de Filas](https://dev.azure.com/telefonica-vivo-brasil/DevOps/_build?definitionId=39722&_a=summary)
- [SonarQube Community Edition - Documentação](https://docs.sonarqube.org/latest/)
- [Portal CodePlay](https://dvps.redecorp.azr/portal/)
- Políticas de Waivers: *(link a ser adicionado após implementação)*

