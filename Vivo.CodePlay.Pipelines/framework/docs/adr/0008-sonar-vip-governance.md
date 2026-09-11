# ADR 0008: Depreciação do Parâmetro sonarServiceConnection e Governança Centralizada via vip.json

Data: 2026-05-13

## Status
Proposed


## Context


Historicamente, pipelines do CodePlay Framework permitiam a configuração manual do parâmetro `sonarServiceConnection` para definir a conexão com o SonarQube (Community ou VIP). Essa abordagem oferecia flexibilidade, mas exigia controle manual para garantir que apenas projetos alinhados utilizassem o Sonar VIP, conforme as diretrizes do framework.

Com a evolução do controle de qualidade e segurança, tornou-se necessário centralizar a governança do acesso ao Sonar VIP, garantindo que apenas projetos autorizados possam utilizá-lo. Conforme definido no ADR 0006, o uso do Sonar VIP depende de alinhamento executivo, compromisso com altos padrões de qualidade de código e implementação de gates de qualidade rigorosos.


## Decision

- O parâmetro `sonarServiceConnection` será depreciado em todos os pipelines do framework.
- O controle de acesso ao Sonar VIP passa a ser feito exclusivamente via arquivo `vip.json`, que lista as siglas dos projetos autorizados.
- A custom task do framework será responsável por ler o `vip.json` e aplicar a conexão correta automaticamente, sem intervenção manual.
- Pipelines que ainda expõem o parâmetro devem exibir aviso de depreciação e orientar sobre o novo fluxo.
- Após período de transição, o parâmetro será removido definitivamente dos pipelines.


## Consequences

- Elimina a possibilidade de burlar a governança do Sonar VIP via override manual.
- Facilita auditoria e rastreabilidade de quem pode usar o Sonar VIP.
- Simplifica a configuração dos pipelines, reduzindo parâmetros manuais.
- Exige atualização dos pipelines existentes e comunicação clara aos times.


## Next Steps

1. Adicionar aviso de depreciação do parâmetro nos pipelines afetados.
2. Atualizar e manter o arquivo `vip.json` com as siglas autorizadas.
3. Remover o parâmetro dos pipelines após o período de transição.
4. Comunicar a mudança a todos os mantenedores de pipelines.

## References
- ADR 0006 - Uso do SonarQube e Governança: [doc/adr/0006-uso-do-sonar.md](../../../doc/adr/0006-uso-do-sonar.md)
- Exemplos de pipelines afetados: build-nodejs-lib, build-nodejs-docker, build-java-lib, build-python-lib, etc.
- Documentação do framework: [framework/README.md](../../README.md)

---

> Este ADR formaliza a decisão de centralizar a governança do Sonar VIP e garantir compliance em todos os pipelines do CodePlay Framework.
