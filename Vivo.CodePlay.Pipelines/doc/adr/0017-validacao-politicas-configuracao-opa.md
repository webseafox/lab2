# 17. Validação de Políticas de Configuração com OPA

Date: 2026-07-15

## Status

Proposed

## Context

O CodePlay Framework já possui um mecanismo de governança para pipelines baseado em políticas como código e o **Compliance Decorator**, que injeta automaticamente a task `VivoDevOpsComplianceOpenPolicyAgent@1` em todas as pipelines. Esse mecanismo valida metadados da pipeline — steps, tasks, variáveis, ambientes e padrões de nomenclatura — mas **não inspeciona o conteúdo de configuração das aplicações** que as pipelines constroem e implantam.

A validação de arquivos de configuração (Dockerfile, `values.yaml`, manifests, `.env`, `appsettings.json`, etc.) exige acesso ao **conteúdo do repositório**. O decorator, porém, atua em um contexto pré/pós-job que **não realiza checkout do código-fonte**. Portanto, ele não é o mecanismo adequado para ler e avaliar arquivos do repo.

A estratégia adotada será:

1. A task de validação de configuração será **invocada explicitamente** dentro dos pipelines de CI/CD, no job que já possui o checkout do repositório.
2. O Compliance Decorator terá uma política OPA que **enforce o uso obrigatório** dessa task em pipelines de CI/CD, garantindo que nenhum repo de aplicação escape da validação.

Sem essa governança, times podem introduzir riscos conhecidos sem feedback automático no PR/CI. Exemplos reais de problemas que políticas de configuração poderiam mitigar:

| Categoria | Exemplo de Risco | Motivação |
|-----------|------------------|-----------|
| Imagem base | Uso de `ubuntu:latest`, `alpine:edge` ou imagens não aprovadas | Imagens não rastreadas dificultam patching e aumentam a superfície de ataque. Vulnerabilidades em imagens base são frequentemente exploradas (ex: [CVE-2024-21626](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2024-21626) no runc, [CVE-2024-3094](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2024-3094) no XZ). |
| Registry | Pull direto de `docker.io`, `quay.io` ou registries externos sem passar pelo mirror corporativo | Viola política de artefatos, expõe a build a dependências externas não auditadas e pode quebrar em ambientes restritos. |
| Helm / Kubernetes | `values.yaml` com `runAsRoot: true`, `privileged: true`, `hostNetwork: true`, secrets em plain text | Configurações inseguras em manifests são vetores comuns de escalada de privilégio e vazamento de dados. |
| Dockerfile | Uso de `USER root`, exposição de portas não padronizadas, ausência de `HEALTHCHECK`, imagens sem multi-stage | Aumenta o risco de runtime e dificulta a padronização operacional. |
| Configuração de aplicação | `.env`, `appsettings.json` ou ConfigMaps com endpoints não homologados, chaves hardcoded, valores sensíveis | Erros de configuração são uma das principais causas de incidentes de segurança e indisponibilidade. |

A pergunta central desta ADR é: **qual é a melhor forma de estender a governança do CodePlay para validar arquivos de configuração de aplicações, reaproveitando o ecossistema OPA já existente, sabendo que o decorator não pode acessar o conteúdo do repositório?**

## Decision

Decidimos adotar uma **task de compliance de configuração separada**, invocada explicitamente nos pipelines de CI/CD, que executa políticas OPA/Rego sobre arquivos do repositório durante o PR/CI. As políticas serão mantidas como código em um repositório dedicado de governança e distribuídas como **bundle remoto** consumido pela task.

O **Compliance Decorator** não executará a validação diretamente, mas terá uma política OPA que **garante (enforce) que pipelines de CI/CD declarem e executem a task de configuração**. Dessa forma, a validação ocorre no contexto correto (com checkout do repo) e o decorator mantém seu papel de governança obrigatória sobre a estrutura da pipeline.

### Arquitetura escolhida

```text
┌─────────────────────────────────────────────────────────────────┐
│  Repositório de Aplicação                                       │
│  ├── Dockerfile                                                 │
│  ├── helm/values.yaml                                           │
│  ├── k8s/                                                       │
│  └── azure-pipelines.yml                                        │
└──────────────────────────────┬──────────────────────────────────┘
                               │ trigger PR/CI
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│  Azure DevOps Pipeline                                          │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Compliance Decorator (organização)                     │    │
│  │  └── pré-job: VivoDevOpsComplianceOpenPolicyAgent@1     │    │
│  │      └── valida metadados da pipeline                   │    │
│  │          └── política: pipeline deve conter             │    │
│  │              VivoDevOpsConfigCompliance@1               │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Job de CI (com checkout do repo)                       │    │
│  │  └── step: VivoDevOpsConfigCompliance@1  ◄──────────────┼────┤
│  │      └── lê arquivos de configuração do repo            │    │
│  │      └── executa políticas OPA localmente               │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│  Repositório de Políticas (bundle OPA)                          │
│  ├── policies/                                                  │
│  │   ├── container/base_image.rego                              │
│  │   ├── container/registry.rego                                │
│  │   ├── helm/security.rego                                     │
│  │   ├── k8s/pod_security.rego                                  │
│  │   └── appconfig/sensitive_data.rego                          │
│  └── bundle.tar.gz  ◄── publicado em endpoint remoto            │
└─────────────────────────────────────────────────────────────────┘
```

### Por que não usar o decorator para validar arquivos de configuração?

O decorator injeta steps em um contexto que **não possui checkout do repositório**. Para avaliar um `Dockerfile`, `values.yaml` ou manifesto Kubernetes, a task precisa ter acesso ao filesystem do repo. Por isso, a validação deve ocorrer dentro de um job de CI/CD que já executou `checkout`.

O papel do decorator passa a ser:

- **Garantir** que todo pipeline de CI/CD declare a task `VivoDevOpsConfigCompliance@1`.
- **Bloquear** pipelines que tentem contornar a validação removendo a task.
- Continuar validando metadados da pipeline (estrutura, segurança, padrões) como já faz hoje.

### Por que separar da task existente?

A task `VivoDevOpsComplianceOpenPolicyAgent@1` foi projetada para validar a **pipeline em si** (estrutura, segurança e padrões do YAML). As políticas de configuração têm:

- **Ciclo de vida diferente**: regras de pipeline evoluem com o framework; regras de configuração evoluem com políticas de segurança e arquitetura corporativa.
- **Entrada diferente**: metadados da pipeline vs. arquivos do repositório.
- **Auditores diferentes**: equipe de DevOps Framework vs. equipe de Segurança/Arquitetura.
- **Granularidade diferente**: políticas de configuração tendem a ser mais numerosas e específicas por tecnologia.

Manter tasks separadas permite evoluir, versionar e escalar cada domínio sem acoplamento.

### Alternativas consideradas

| Alternativa | Descrição | Prós | Contras |
|-------------|-----------|------|---------|
| **A. Estender `VivoDevOpsComplianceOpenPolicyAgent@1` para ler arquivos do repo** | Adicionar à task atual a capacidade de fazer checkout implícito e aplicar políticas de configuração. | Reaproveita decorator e infraestrutura existente. | Mistura responsabilidades; aumenta a complexidade da task; dificulta versionamento independente; checkout implícito pode ser inesperado e lento. |
| **B. Task separada invocada no pipeline + decorator enforce (escolhida)** | Nova task `VivoDevOpsConfigCompliance@1` chamada no job de CI/CD; decorator garante que a task esteja presente. | Separação clara de responsabilidades; validação no contexto correto (com checkout); políticas versionadas e centralizadas; enforce obrigatório via decorator. | Mais uma task para publicar e manter; times precisam incluir a task nos pipelines (ou via template). |
| **C. Task separada com políticas no repo da aplicação** | Cada aplicação mantém suas próprias políticas Rego em `.policies/` ou similar. | Autonomia dos times; feedback rápido sem dependência de endpoint remoto. | Fragmentação de governança; dificulta aplicação de políticas corporativas obrigatórias; risco de times desabilitarem ou ignorarem. |
| **D. Validação apenas em CD / deploy** | Aplicar as políticas somente no momento do deploy, via task no pipeline de CD. | Menor impacto no tempo de build de PR. | Feedback tardio; problemas só são detectados quando a mudança já foi aprovada e mergeada; aumenta o ciclo de correção. |
| **E. Validação via OPA server centralizado** | Aplicação envia arquivos para um OPA server que avalia as políticas. | Políticas centralizadas e atualizadas em tempo real; possibilidade de decision logs centralizados. | Requer infraestrutura de alta disponibilidade; latência de rede; complexidade de autenticação e autorização. |

### Critérios de avaliação

A escolha foi orientada pelos seguintes critérios, em ordem de prioridade:

1. **Acesso ao repositório**: a validação precisa ocorrer em um job com checkout do código. → Descarta execução puramente pelo decorator.
2. **Garantia de execução**: a validação deve ser obrigatória e não depender de adesão voluntária do time. → Decorator enforce resolve isso.
3. **Separação de responsabilidades**: pipeline e configuração são domínios distintos. → Favorece a alternativa B.
4. **Centralização das políticas corporativas**: regras obrigatórias devem ser mantidas por um time de governança. → Favorece bundle remoto (B) sobre políticas no repo (C).
5. **Feedback rápido**: detectar problemas no PR/CI reduz o custo de correção. → Descarta D como único momento.
6. **Simplicidade operacional**: evitar infraestrutura crítica adicional em caminho de build. → Favorece bundle remoto (B) sobre OPA server (E).

### Detalhamento da task `VivoDevOpsConfigCompliance@1`

A task deve:

1. **Executar em um job com checkout do repositório**, seja chamada diretamente no `azure-pipelines.yml` ou via template compartilhado do CodePlay Framework.
2. **Coletar arquivos de configuração** do repositório, respeitando um conjunto de padrões configurável (ex: `Dockerfile`, `**/values.yaml`, `**/Chart.yaml`, `**/*.yaml` em `k8s/`, `.env`, `appsettings*.json`).
3. **Baixar o bundle de políticas** de um endpoint corporativo versionado (ex: `https://artifacts.../opa-bundles/config-compliance/v1/bundle.tar.gz`).
4. **Executar as políticas OPA localmente**, usando **Conftest** como engine padrão (com fallback para OPA CLI em cenários avançados), sem depender de servidor remoto durante a avaliação.
5. **Gerar relatório estruturado** em Markdown e JSON, indicando violações por severidade (`critical`, `high`, `medium`, `low`).
6. **Aplicar ação conforme severidade**: `critical` e `high` bloqueiam o PR; `medium` e `low` podem emitir aviso (configurável).
7. **Respeitar mecanismos de exceção**: permitir bypass controlado via arquivo de waiver justificado e aprovado, auditável.

### Exemplo de uso no pipeline

```yaml
steps:
  - checkout: self

  - task: VivoDevOpsConfigCompliance@1
    displayName: 'Validar políticas de configuração'
    inputs:
      bundleUrl: 'https://artifacts.../opa-bundles/config-compliance/v1/bundle.tar.gz'
      includePatterns: |
        Dockerfile
        **/values.yaml
        **/Chart.yaml
        k8s/**/*.yaml
```

### Política do decorator de enforce

O Compliance Decorator aplicará uma política OPA que verifica, para pipelines de CI/CD, se a task `VivoDevOpsConfigCompliance@1` está declarada. Exemplo de regra Rego:

A política deve considerar:

- Pipelines de CI ou CI/CD: obrigatório.
- Pipelines de CD puros (sem build): pode ser opcional ou exigir validação em outro momento.
- Pipelines de infraestrutura (Terraform/Bicep): avaliar se as mesmas políticas se aplicam ou se há task equivalente.
- Mecanismo de waiver para exceções justificadas e aprovadas.

### Exemplos iniciais de políticas de configuração

| Política | Descrição | Severidade |
|----------|-----------|------------|
| `container.base_image.allowed` | Imagem base deve estar em uma lista aprovada ou usar tag imutável (digest). | high |
| `container.registry.must_use_mirror` | Pull de imagens deve usar o registry mirror corporativo. | critical |
| `container.dockerfile.no_root_user` | Dockerfile não deve terminar com `USER root`. | high |
| `helm.values.no_privileged` | `values.yaml` não deve permitir container `privileged: true`. | critical |
| `helm.values.no_host_network` | `values.yaml` não deve usar `hostNetwork: true`. | high |
| `k8s.secrets.no_plaintext` | Secrets não devem estar em plain text em manifests. | critical |
| `appconfig.no_hardcoded_secrets` | Arquivos de configuração não devem conter tokens, senhas ou chaves. | critical |
| `appconfig.endpoints.approved` | Endpoints configurados devem pertencer a domínios corporativos aprovados. | medium |

### Ferramentas de execução consideradas

A task de configuração precisa executar políticas Rego sobre arquivos do repositório. Avaliamos as seguintes opções:

| Ferramenta | Descrição | Prós | Contras | Adequação para a task |
|------------|-----------|------|---------|----------------------|
| **Conftest** | CLI da Open Policy Agent especializada em testar arquivos de configuração contra políticas Rego. Suporta YAML, JSON, Dockerfile, TOML, INI, etc. | Foco exato no problema; sintaxe simples (`conftest test <arquivos>`); suporte nativo a múltiplos formatos; relatórios claros; amplamente adotada em pipelines CI/CD. | Menos flexível para lógicas complexas que exijam múltiplas queries customizadas; depende do OPA por baixo. | **Alta** — candidata principal para a execução na task. |
| **OPA CLI (`opa test` / `opa eval`)** | CLI oficial do Open Policy Agent. Permite avaliar políticas Rego de forma genérica. | Máxima flexibilidade; controle total sobre entrada, queries e saída; mesmo runtime usado pelo Conftest e pelo OPA server. | Requer mais trabalho para parsear arquivos YAML/JSON e formatar relatórios; curva de aprendizado maior. | **Alta** — opção se for necessário controle total do comportamento da task. |
| **OPA server centralizado** | Serviço OPA em execução contínua que recebe requisições de decisão via HTTP. | Políticas atualizadas em tempo real; decision logs centralizados; pode atender múltiplos consumidores. | Requer infraestrutura de alta disponibilidade; latência de rede; autenticação/autorização; ponto único de falha no caminho de build. | **Baixa para CI** — complexidade operacional excessiva para validação em PR. Pode ser reconsiderado para admission controllers em runtime. |
| **OPA Gatekeeper** | Admission controller para Kubernetes que usa Rego para validar recursos no cluster. | Integração nativa com Kubernetes; policies-as-code no cluster. | Só se aplica a recursos Kubernetes; executa no cluster, não no CI; não cobre Dockerfile, .env, appsettings, etc. | **Baixa para esta ADR** — complementar para runtime, mas não substitui validação no repo. |
| **Kyverno** | Policy engine nativo para Kubernetes, com políticas declarativas em YAML (não Rego). | Mais fácil de escrever para quem conhece Kubernetes; não exige aprender Rego. | Linguagem própria, não Rego; limitado a Kubernetes; não cobre Dockerfile, .env, appsettings, etc. | **Baixa** — fragmentaria a stack de políticas e não reaproveita o ecossistema OPA já existente. |
| **Rego + parser customizado na task** | A própria task implementa o parser e chama o OPA SDK. | Controle total; sem dependência de CLI externa. | Reinventa a roda; maior esforço de manutenção; risco de inconsistências com o ecossistema OPA. | **Baixa** — viola o princípio de reaproveitar ferramentas maduras. |

#### Recomendação de ferramenta

Recomendamos que a task `VivoDevOpsConfigCompliance@1` utilize **Conftest** como engine padrão de execução, com a opção de fallback para **OPA CLI** em cenários que exijam queries customizadas ou formatos de saída específicos.

**Por que Conftest como padrão:**

1. **Propósito alinhado**: foi criado exatamente para validar arquivos de configuração em pipelines CI/CD.
2. **Formatos suportados**: lê YAML, JSON, Dockerfile, TOML, INI e outros sem necessidade de parser customizado.
3. **Bundle OPA nativo**: Conftest pode consumir bundles OPA publicados em endpoint remoto, mantendo a política de centralização das regras.
4. **Relatórios legíveis**: saída padrão já indica arquivo, política e mensagem de violação, facilitando o relatório da task.
5. **Adoção no mercado**: ferramenta madura, documentada e com comunidade ativa, reduzindo risco de manutenção.

**Por que manter OPA CLI como alternativa:**

- Permite evoluir para cenários mais complexos sem trocar de engine.
- Mantém compatibilidade com o ecossistema OPA já existente na Vivo.
- Facilita testes unitários das políticas com `opa test`.

**Por que descartar OPA server, Gatekeeper e Kyverno como principais:**

- OPA server introduz dependência de infraestrutura em tempo de build.
- Gatekeeper e Kyverno atuam em runtime Kubernetes e não cobrem o escopo de arquivos de aplicação (Dockerfile, .env, appsettings).
- Kyverno usa linguagem própria, o que fragmentaria a stack de policies-as-code da organização.

#### Exemplo de execução com Conftest

```bash
# Baixar bundle de políticas
conftest pull https://artifacts.../opa-bundles/config-compliance/v1/bundle.tar.gz

# Validar arquivos do repositório
conftest test Dockerfile helm/values.yaml k8s/*.yaml \
  --namespace config_compliance \
  --output table
```

A task encapsularia esse comando, adicionando:

- Descoberta automática de arquivos com base em `includePatterns`.
- Cache do bundle entre execuções.
- Mapeamento de severidade das violações para ação (bloqueio ou aviso).
- Geração de relatório em Markdown para a aba Summary do Azure DevOps.

#### Considerações sobre o bundle de políticas

Independentemente da ferramenta escolhida, o bundle de políticas deve seguir o formato padrão do OPA:

```text
bundle/
├── .manifest
└── policies/
    ├── container/
    │   ├── base_image.rego
    │   └── registry.rego
    ├── helm/
    │   └── security.rego
    ├── k8s/
    │   └── pod_security.rego
    └── appconfig/
        └── sensitive_data.rego
```

Vantagens de usar bundle OPA:

- **Versionamento**: cada versão do bundle é um artefato imutável (`v1`, `v2`, etc.).
- **Distribuição**: pode ser servido por Azure Artifacts, GitHub Releases, Azure Blob Storage ou qualquer HTTP server.
- **Testabilidade**: políticas podem ser testadas localmente com `conftest verify` ou `opa test`.
- **Reuso**: mesmo bundle pode ser consumido por Conftest no CI, OPA server em runtime ou admission controllers.

## Consequences

### Positivas

- **Governança estendida**: políticas corporativas passam a cobrir não apenas como a pipeline é escrita, mas também o que ela constrói e implanta.
- **Feedback no PR/CI**: desenvolvedores descobrem violações antes do merge, reduzindo retrabalho e incidentes.
- **Execução no contexto correto**: a task roda no job de CI/CD, com acesso real aos arquivos do repositório.
- **Garantia obrigatória**: o decorator impede que pipelines de CI/CD escapem da validação.
- **Padrão corporativo centralizado**: políticas em repositório dedicado, versionadas e auditáveis, evitando fragmentação por time.
- **Reuso do bundle OPA**: o mesmo conjunto de políticas pode ser usado por ferramentas locais (Conftest), admission controllers (OPA Gatekeeper/Kyverno com conversão) e outras pipelines.
- **Transparência**: relatórios estruturados facilitam a comunicação de não conformidades e a geração de evidências de compliance.

### Negativas / Pontos de atenção

- **Nova task para manter**: publicação, versionamento e compatibilidade da `VivoDevOpsConfigCompliance@1` exigem cuidado.
- **Curva de aprendizado**: times precisam entender como incluir a task nos pipelines e como interpretar os relatórios.
- **Adesão nos templates**: a task deve ser incorporada nos templates de CI/CD do CodePlay Framework para reduzir a carga dos times.
- **Performance do CI**: varrer muitos arquivos e executar dezenas de políticas pode aumentar o tempo de build. Mitigação: cache do bundle e escolha criteriosa de arquivos a validar.
- **Falsos positivos**: políticas genéricas podem sinalizar casos legítimos. Mitigação: mecanismo de waiver auditável e revisão contínua das regras.
- **Disponibilidade do bundle**: se o endpoint remoto estiver indisponível, o CI pode falhar. Mitigação: cache local do bundle e fallback para versão anterior.
- **Bypass do decorator**: times podem tentar contornar o enforce alterando o tipo da pipeline ou usando jobs condicionais. Mitigação: política do decorator deve ser robusta e cobrir variações de estrutura.

### Ações necessárias

1. Criar o repositório de políticas de configuração e definir o processo de publicação do bundle OPA.
2. Implementar a task `VivoDevOpsConfigCompliance@1` e publicá-la como extensão do Azure DevOps.
3. Atualizar os **templates de CI/CD do CodePlay Framework** para incluir a task automaticamente nos pipelines derivados.
4. Atualizar o Compliance Decorator com a política OPA que enforce o uso da task em pipelines de CI/CD.
5. Definir o catálogo inicial de políticas e seus respectivos níveis de severidade.
6. Documentar o mecanismo de waiver e o processo de atualização de políticas.
7. Comunicar os times sobre as novas verificações, exemplos de correção e como incluir a task em pipelines customizados.

---

## Apêndice: Referências

- [Michael Nygard — Documenting Architecture Decisions](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions)
- [Open Policy Agent (OPA)](https://www.openpolicyagent.org/)
- [OPA Bundles](https://www.openpolicyagent.org/docs/latest/management-bundles/)
- [Conftest](https://www.conftest.dev/)
- [Azure DevOps Pipeline Decorators](https://learn.microsoft.com/en-us/azure/devops/extend/develop/add-pipeline-decorator)
- ADR 01 — Record architecture decisions
- ADR 09 — Política de Validação de E-mail do Committer
- ADR 15 — Service Connections Específicas para Role Assignment e APIM
