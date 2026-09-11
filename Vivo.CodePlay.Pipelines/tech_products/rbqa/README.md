1. Visão Geral
O Stage de Testes RBQA é uma solução corporativa de execução automatizada de testes pós-deploy, integrada ao ecossistema Azure DevOps. Seu objetivo central é garantir que deploys em ambientes de QA (pré-produção, esteiras etc) sejam validados automaticamente por meio de cenários E2E (End-to-End) cadastrados no ALM Octane fornecendo feedback rápido aos QAs e desenvolvedores.

Problemas que resolve:

Elimina gargalos de validação manual após deploys
Reduz lead time de detecção de regressões funcionais
Centraliza orquestração e rastreabilidade (Jira ↔ Octane ↔ Azure DevOps)
Suporta múltiplos browsers, frameworks e módulos de repositório
Executa cenários em paralelo com balanceamento inteligente de recursos
Quando é acionada: O stage é tipicamente adicionado ao final de um pipeline CD, após o deploy da aplicação em ambiente de stage, declarando dependência (dependsOn) do stage de deploy.

2. Arquitetura Geral
O Stage tem o seguinte fluxo de execução:



3. Estrutura de Arquivos
tech_products/rbqa/
│
├── pipeline_rbqa_testexecution_ci_v1.yml                # Entrypoint CI Individual (consumidores)
│
├── initialize/
│   └── hosts                                            # Entradas /etc/hosts do fluxo CI Individual
│
├── test-execution-stage/                                # FLUXO STAGE
│   ├── latest/
│   │   └── pipeline_rbqa_testexecution_stage.yml        # Alias estável → aponta para v3
│   ├── v3/                                              # Versão corrente (ativa)
│   │   ├── pipeline_rbqa_testexecution_stage_cd_v3.0.yml
│   │   ├── scripts/
│   │   │   ├── docker_test_execution.sh                 # Orquestra o container (agente → Docker)
│   │   │   ├── test_execution.sh                        # Script principal (dentro do container)
│   │   │   ├── check_for_failed_tests.sh                # Verifica falhas e falha a pipeline
│   │   │   └── hosts                                    # Entradas /etc/hosts injetadas no container
│   │   └── variables/
│   │       └── variables.yml                            # Variáveis globais do stage
│   ├── v2/                                              # Versão anterior (mantida para compatibilidade)
│   └── v1/                                              # Versão legada
│
└── test-execution-pipeline/                             # PIPELINES STANDALONE
    └── capacidade/
        └── pipeline_rbqa_testexecution_stage_pipeline.yml  # Wrapper → latest

latest/ é um alias funcional para v3/: o arquivo latest/pipeline_rbqa_testexecution_stage.yml referencia os scripts de v3/scripts/. Consumidores devem sempre usar a referência latest/ para se beneficiar de atualizações sem mudança de configuração.

4. Histórico de Versões
v1	pipeline_rbqa_testexecution_stage_cd_v1.yml	Versão inicial. Parâmetro component_id. Sem suporte a paralelismo. Sem framework.
v2	pipeline_rbqa_testexecution_stage_cd_v2.yml	Adição do parâmetro framework. Separação de variables.yml. Script test_execution.sh com blocos de cenários.
v3	pipeline_rbqa_testexecution_stage_cd_v3.0.yml	Renomeação para component_test_id. Algoritmo de balanceamento de memória. Suporte a COMPONENT_ID dentro do container. Monitoramento periódico com hwmonitor.log.
latest	latest/pipeline_rbqa_testexecution_stage.yml	Alias para v3. Ponto de referência estável para todos os consumidores.
5. Template Principal — latest
Referência de Uso
stages:
  - template: /tech_products/rbqa/test-execution-stage/latest/pipeline_rbqa_testexecution_stage.yml@CodePlay
    parameters:
      jira_id: "PTI-1234-56"
      test_environment: "preprod"
      component_test_id: "meu-modulo"
      octane_workspace: "102001"
      dependsOn:
        - deploy
### Parâmetros e comportamento (resumido)

```text
RBQA — Parâmetros, Variáveis & Comportamento (v3)

Template
- /test-execution-stage/latest/pipeline_rbqa_testexecution_stage.yml → aponta para v3. Consumidores: use latest/.

Parâmetros (v3)
- jira_id: ID Jira para GetOctaneTests.
- test_environment: ambiente (ex.: preprod).
- component_test_id: pasta do módulo de testes.
- octane_workspace: Octane workspace id.
- docker_image: alias da imagem (padrão: selenium).
- framework: JUnit | Cucumber.
- octane_environment: escolhe Variable Group Octane (PROD → test-stage-octane-variables, outro → test-stage-octane-variables-hom).
- dependsOn: lista de stages upstream.

Variáveis / Segredos
- PRIVATE_AGENT_QA (TestRunnerAgents), DOCKER_WORKDIR (/app), AKV_DEVOPS_NAME (kv-azdevops-shared).
# RBQA — Test Execution Stage (v3)

Stage de execução de cenários E2E. Consumidores devem usar `test-execution-stage/latest/pipeline_rbqa_testexecution_stage.yml`.

Uso (exemplo mínimo):
```yaml
stages:
  - template: /tech_products/rbqa/test-execution-stage/latest/pipeline_rbqa_testexecution_stage.yml@CodePlay
    parameters:
      jira_id: "PTI-1234"
      test_environment: "preprod"
      component_test_id: "meu-modulo"
      octane_workspace: "102001"
```

Principais pontos:
- Busca de cenários: `AzdoTaskRbqaOctaneGetStageTestsFromVivo@1` → define `TEST_IDS`, `TEST_MATRIX`.
- Compose Email Recipients: step `Compose Email Recipients` seta `RECIPIENT_EMAILS` (library + requester + `TEST_MATRIX.emailQA`).
- Execução: `docker_test_execution.sh` injeta `SCENARIOS=$(TEST_IDS)` e executa `/scripts/test_execution.sh` no container.
- Scheduler: `test_execution.sh` usa `MAX_PARALLEL_SCENARIOS=10`, `MAX_MEMORY_PER_PROCESS=3` (GB), `MEMORY_SAFETY_MARGIN=5` (GB); cada cenário roda com cópia em `/tmp/<cenario>`; RunResults → `/app/RunResults`; falhas → `/app/failed_tests.txt`.
- Publicação: `logs` e `RunResults` são publicados com `condition: always()`.
- Relatório e notificação: `Generate Failure Report for Email` cria `$(Agent.TempDirectory)/rbqa_reports/failed_scenarios_<env>.txt` e seta `EMAIL_ATTACHMENT` quando o job falha; `AzdoTaskRbqaNotificationDispatcherFromVivo@1` envia `sendTeams` e `sendEmail` (emailTo=`$(RECIPIENT_EMAILS)`, emailAttachment=`$(EMAIL_ATTACHMENT)`).
- Resultado em Octane: `SetOctaneTestsResults@1.0.59` é usado para reportar `testMatrix` ao ALM.
- Falha intencional: `check_for_failed_tests.sh` (rodado após publicação) retorna exit code 1 se `FAIL_PIPELINE=true` e `failed_tests.txt` contém `FAILED`.

### Validação de Execução e Depuração de Falhas Silenciosas

A partir de v3, a stage valida em **dois pontos**:

1. **Dentro do container** (`test_execution.sh`, linhas 328-332):
   - Valida que cenários foram carregados com sucesso
   - Falha imediatamente se `.azuredevops/cenarios/` está ausente ou vazio
   - Mensagem: `[ERROR] Nenhum cenário foi carregado. Verifique a configuração.`

2. **No agente** (`check_for_failed_tests.sh`, linhas 9-14):
   - Valida que `RunResults` foi criado e contém resultados
   - Falha se o diretório está vazio ou ausente (indicador de que nenhum teste foi executado)
   - Mensagem: `[ERROR] Os testes não foram executados. O diretório RunResults está vazio ou ausente.`

Variáveis/segredos importantes:
- `PRIVATE_AGENT_QA` (pool), `AKV_DEVOPS_NAME` (Key Vault), Octane Variable Group (`test-stage-octane-variables` ou `test-stage-octane-variables-hom`).
- `RBQA_NOTIFICATION_EMAILS`, `RBQA_TEAMS_WEBHOOK_URL`, `RBQA_SMTP_SERVER`, `RBQA_SMTP_PORT`.
- `NEXUS_DEPS_USR` / `NEXUS_DEPS_PSW` via Key Vault; `System.AccessToken` usado quando necessário.

Arquivos-chave (consulte para detalhes):
- `test-execution-stage/latest/pipeline_rbqa_testexecution_stage.yml`
- `test-execution-stage/v3/scripts/docker_test_execution.sh`
- `test-execution-stage/v3/scripts/test_execution.sh`
- `test-execution-stage/v3/scripts/check_for_failed_tests.sh`

### Parâmetro `extra_env` — Variáveis de Ambiente Extras

**Escopo de uso:** O parâmetro `extra_env` é destinado a configurações e credenciais de ambientes de teste/QA (pré-produção). Evite utilizá-lo para expor segredos de produção diretamente no pipeline.

O parâmetro `extra_env` permite injetar variáveis de ambiente customizadas diretamente no container Docker de execução dos testes, **sem** passá-las via `-D` no Maven. Foi replicado a partir do tech product **qa** do CodePlay.

#### Por que usar?

- **Segurança**: Variáveis não aparecem na linha de comando Maven (visíveis em logs e `ps aux`)
- **Organização**: Separa credenciais/tokens dos parâmetros funcionais do Maven
- **Flexibilidade**: Cada pipeline pode definir suas variáveis sem alterar o template

#### Como funciona internamente

1. O pipeline injeta variáveis com prefixo `EXTRA_VAR_` no `env:` da task
2. O script gera um arquivo temporário seguro (`mktemp` + `chmod 600`)
3. O prefixo `EXTRA_VAR_` é **removido** — o container recebe a variável com o nome original
4. O `docker run` carrega o arquivo via `--env-file`
5. Após a execução, o arquivo é removido automaticamente

**Exemplo:** `EXTRA_VAR_MY_SECRET=abc` → container vê `MY_SECRET=abc`

#### ⚠️ Importante — Não insira valores literais de segredos

O parâmetro `extra_env` aceita **referências a variáveis do Azure DevOps**, não os valores sensíveis em si. Utilize o variable group do pipeline ou a edição no Azure DevOps.

✅ **Correto:**
```yaml
extra_env:
  SECRET_ABC: $(POLICY_ABC)
  KEY_123: $(KEY_123)
```

❌ **Errado (nunca faça isso):**
```yaml
extra_env:
  SECRET: "valor_secreto_aqui"
```
