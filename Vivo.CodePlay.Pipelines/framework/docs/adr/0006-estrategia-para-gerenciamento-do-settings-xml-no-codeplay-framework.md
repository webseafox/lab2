# 6. Estratégia para gerenciamento do settings.xml no CodePlay Framework

Date: 2026-02-13

## Status

Proposed

## Context

No Azure DevOps, o template de pipeline Java do **Vivo Core Pipelines** permite armazenar arquivos `settings.xml` como **Secure Files** na Library do projeto.

Essa abordagem oferece, principalmente, a possibilidade de:

- Compartilhar um mesmo `settings.xml` entre múltiplos pipelines Java de um mesmo projeto.
- Atualizar o arquivo em um único ponto (Secure File) para que todos os pipelines passem a utilizar a nova versão.

No **CodePlay Framework** o template de pipeline Java atualmente suporta:

1. Uso de um arquivo `settings.xml` presente **no repositório** da aplicação; ou  
2. Uso de um arquivo `settings.xml` padrão na **$HOME** do usuário das VMs agentes do Azure DevOps.

Os times consumidores do framework levantaram como principal benefício do Secure File justamente a facilidade de atualização centralizada do `settings.xml` compartilhado.

Por outro lado, manter o `settings.xml` **versionado nos repositórios** traz benefícios relevantes:

- **Rastreabilidade:** histórico de alterações via Git (commits, autor, data, motivo).
- **Transparência:** todos os desenvolvedores podem ver o conteúdo e entender de onde vêm as dependências.
- **Onboarding:** o setup de novos desenvolvedores fica mais simples, pois é claro quais repositórios e registries são utilizados para obtenção de dependências.
- **Configuration as Code:** as configurações relevantes para build e dependências permanecem próximas ao código que as utiliza.

É necessário, portanto, decidir se o CodePlay Framework deve:

- (a) manter o modelo atual (repositório / `$HOME`),  
- (b) reintroduzir o suporte a Secure Files como no Vivo Core Pipelines, ou  
- (c) manter o modelo atual, adicionando mecanismos de automação para facilitar atualizações massivas do `settings.xml` em múltiplos repositórios.

## Decision

**Decidimos:**

1. **Manter o suporte ao `settings.xml` com uso de variáveis presentes na plataforma para autenticação (sem credenciais diretas no arquivo):**
   - **Versionado nos repositórios** das aplicações; e
   - Na **$HOME** das VMs dos agentes do Azure DevOps (arquivo padrão).

2. **Não reintroduzir o suporte a Secure Files** para `settings.xml` no template Java do CodePlay Framework.

3. **Disponibilizar um script genérico de automação** para atualização do `settings.xml` em múltiplos repositórios de forma centralizada e padronizada.

   Haverá um refinamento próprio do time DevOps para definição dos requisitos do script. Em linhas gerais esse script deverá:

   - Receber como parâmetros:
     - Um **diretório** contendo o(s) arquivo(s) a serem atualizado nos repositórios;
     - Uma **lista de repositórios** a serem atualizados;
     - O **nome da branch** de alteração a ser criada em cada repositório;
     - Um **arquivo texto** opcional com o conteúdo (template) da descrição do Pull Request.
   - Para cada repositório informado:
     - Criar (ou atualizar) os arquivos conforme o padrão definido;
     - Criar uma branch com as alterações;
     - Abrir um Pull Request utilizando o conteúdo padrão informado.

Dessa forma, mantemos o modelo de **configuration as code**, com rastreabilidade por repositório, sem perder a vantagem de atualizações centralizadas, agora através de automação e PRs.

### Justificativa

#### 1. Rastreabilidade e governança

- Alterações no `settings.xml` passam a ser auditáveis via histórico Git:
  - É possível saber **quem** alterou, **quando** e **por quê** (via mensagem de commit / PR).
- Cada repositório mantém um histórico próprio do arquivo, alinhado a suas necessidades específicas.
- Evitamos alterações “silenciosas” em um Secure File que impactam múltiplas aplicações sem visibilidade dos times consumidores.

#### 2. Transparência e alinhamento entre times

- O conteúdo do `settings.xml` fica explícito dentro do próprio repositório.
- Desenvolvedores e equipes de segurança podem inspecionar facilmente:
  - Quais repositórios/remotos de artefatos são utilizados;
  - Quais credenciais/tokens (quando referenciados) estão configurados.
- Reduz-se a dependência de configurações opacas na Library/Secure Files do Azure DevOps.

#### 3. Onboarding e setup simplificados

- Com o `settings.xml` versionado no repositório:
  - O setup local (build em máquinas de desenvolvimento) fica mais previsível.
  - É claro de onde as dependências são baixadas e quais ajustes são necessários em ambientes locais.
- Diminui-se a chance de divergência entre build local e build em pipeline devido a configurações centralizadas pouco visíveis.

#### 4. Padronização e Configuration as Code

- O CodePlay Framework reforça o modelo de **configuration as code**, mantendo configurações relevantes ao lado do código que as consome.
- Evita-se manter dois modelos paralelos (Secure Files + repositório), o que aumentaria:
  - Complexidade dos templates;
  - Matriz de cenários de suporte e troubleshooting.
- Alinha-se às boas práticas de DevOps e GitOps, onde alterações de configuração passam por revisão de código e PR.

#### 5. Automação para mitigar esforço operacional

- O script genérico oferece uma forma **centralizada e automatizada** de atualizar o `settings.xml` em diversos repositórios:
  - Reproduz o principal benefício percebido do Secure File (atualização massiva) sem abrir mão de rastreabilidade por repositório.
- Atualizações massivas podem seguir um fluxo padrão:
  - Geração de branches;
  - Abertura de PRs com descrição padronizada;
  - Aprovação pelos times donos dos repositórios;
  - Monitoramento de builds e rollbacks dirigidos por PR.

### Contrapontos e Respostas

#### Contraponto 1  
> “Com o Secure File eu não preciso saber quais pipelines usam o `settings.xml`. Agora, para a alteração via script, eu preciso informar quais repositórios fazem uso dele.”

**Resposta:**

1. **Visibilidade de impacto é requisito de governança**
   - Não saber exatamente quais pipelines usam determinado `settings.xml` é, na prática, falta de governança.
   - Alterar um Secure File compartilhado sem conhecer todos os consumidores significa operar “às cegas”, com risco aumentado de quebrar pipelines inesperados.

2. **O mapeamento é pontual e automatizável**
   - A lista de repositórios que utilizam o `settings.xml` pode ser:
     - Mantida em um **inventário** (arquivo de configuração central, por exemplo em um repositório de plataforma); e/ou
     - Descoberta automaticamente por **buscas em código** (por exemplo, repositórios que contêm `settings.xml` ou referências a um template/passo específico no pipeline).
   - Uma vez criado esse inventário, o próprio script pode utilizá-lo, minimizando esforço manual recorrente.

3. **Melhor controle de escopo e rollback**
   - Ao informar explicitamente quais repositórios serão atualizados:
     - É possível aplicar mudanças em **ondas controladas** (canário, piloto, depois massivo).
     - Problemas detectados ficam restritos ao conjunto de repositórios daquela onda.
   - O rollback pode ser feito revertendo PRs específicos, sem afetar todos os consumidores de um Secure File compartilhado.

4. **Alinhamento com compliance e auditoria**
   - Ter clareza de **quem depende de quê** é fundamental para auditorias e gestão de risco.
   - A centralização opaca via Secure File dificulta rastreamento de dependências.
   - O modelo com inventário + configuração versionada nos repositórios torna o uso **explícito, auditável e documentado**.

#### Contraponto 2  
> “Perdemos a facilidade de atualizar um único Secure File e refletir em todos os pipelines.”

**Resposta:**

- O script genérico devolve essa facilidade na forma de **automação com PRs**, conciliando:
  - Atualização centralizada;
  - Revisão por time responsável;
  - Log completo de mudanças por repositório.
- Em vez de uma alteração global e silenciosa, temos uma alteração global, porém **controlada e observável**, com histórico e aprovação explícita.

#### Contraponto 3  
> “Ter o arquivo `settings.xml` em todos os repositórios gera duplicação.”

**Resposta:**

- A duplicação é **intencional** para garantir:
  - Isolamento entre aplicações;
  - Autonomia de cada time na evolução e customização de suas configurações.
- Uma alteração que faz sentido para um conjunto de serviços pode não ser adequada para todos os consumidores do Secure File.
- Com o script, é possível **aplicar padrões** mantendo a possibilidade de exceções por repositório.

## Consequences

### Consequências positivas

- Maior **rastreabilidade** de mudanças de configuração via Git.
- Melhor **transparência** para os times consumidores quanto às dependências e configurações utilizadas.
- **Onboarding** de novos desenvolvedores mais simples e previsível.
- Alinhamento com práticas de:
  - **Configuration as Code**;
  - **GitOps** e fluxo baseado em PRs.
- Possibilidade de **atualizações centralizadas e automatizadas**, com controle fino do escopo e rollback via PR.
- Melhor aderência a requisitos de **governança, auditoria e compliance**.

### Consequências negativas / trade-offs

- Necessidade de manter um **inventário** (ou mecanismo de descoberta) de repositórios que utilizam o `settings.xml`.
- Inclusão de uma etapa adicional de automação (desenvolvimento, manutenção e operação do script).
- Aumento do número de PRs criados em operações massivas (embora mitigado por automação e templates).
- Transição de times que hoje dependem do modelo com Secure Files para o novo modelo baseado em arquivo versionado + script de atualização.
