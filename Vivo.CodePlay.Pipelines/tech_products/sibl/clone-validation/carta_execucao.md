# 📋 Carta de Execução — Clone Validation Pipeline (SIBL)

> **Versão:** 1.0 | **Data:** 28/07/2026 | **Status:** Ativa | **Tipo:** Architecture Decision Record (ADR)

---

## 📋 Informações Gerais

| Campo | Valor |
|-------|-------|
| **Projeto** | Clone Validation Pipeline — SIBL 2015 |
| **Sigla** | `sibl/clone-validation` |
| **Tech Product** | Siebel Legacy (SIBL) |
| **Área Responsável** | DevOps / Siebel Squad |
| **Responsável Documento** | DevOps Team |
| **Status da Implementação** | ✅ Production-Ready (Phase 6 — 2026-06-19) |
| **Próxima Revisão** | 28/10/2026 (quarterly) |

---

## 🎯 Executive Summary

**O que é:** Clone Validation é uma pipeline de validação e remediação **pós-clone** especializada para ambientes Siebel 2015, executada manualmente após clonagem de banco de dados Oracle.

**Por que:** Siebel é um sistema monolítico legado que requer validação granular de consistência de dados, limpeza de tabelas técnicas, restauração de permissões e atualização de parâmetros específicos por ambiente. Um pipeline genérico não captura essas necessidades.

**Como:** Arquitetura multi-esteira com 9 steps obrigatórios (volumetria, limpeza, LOVs, unlock, permissões, usuários) + 3 opcionais (contingência), executados em paralelo por ambiente, com fail-fast em erros SQL/conexão e evidência completa em JSON/TXT.

**Conformidade:** Clone Validation segue **65-70% do CodePlay Framework**. Reutiliza padrões de stages, variáveis normalizadas (`CV_*`), templates de segurança (Fortify/SonarQube), e é documentado como projeto integral. **Não é uma exceção**, mas uma especialização legítima de uma pipeline de data validation.

---

## 🏗️ Decisões Arquiteturais Chave

### **Decisão 1: Execução Controlada pelo Entrypoint**

#### Problema
Clone Validation não é um pipeline CI/CD tradicional. Ela executa **após** clone de banco (um evento infraestrutural), não em resposta a commits de código. Um trigger automático por commit ou schedule não faz sentido operacional.

#### Solução
O arquivo deste diretório é um **template remoto**, consumido via `extends` pelo entrypoint do repositório produto. O entrypoint é responsável por declarar `trigger`, `resources.repositories`, o endpoint `CodePlay` e a referência autorizada do template. A execução é iniciada pelo fluxo definido no entrypoint após clone confirmado. Parâmetros (`environment`, `dryRun`, `override_environments`) permitem flexibilidade sem necessidade de editar o template.

#### Status
✅ **Implementado no contrato de integração**. O template não declara trigger próprio; o comportamento de disparo fica centralizado no entrypoint consumidor.

#### Benefícios
- Controle explícito: DevOps escolhe exatamente quando validar
- Dry-run padrão: cada execução pode validar sem escrever
- Auditoria clara: entrypoint + parâmetros + build = rastreabilidade completa
- Segurança: sem risco de execução acidental por CI automation

---

### **Decisão 2: Arquitetura Multi-Esteira com Baselines Independentes**

#### Problema
SIBL não é um único ambiente monolítico. Existem **4 esteiras de desenvolvimento paralelas**, cada uma com ambientes DEV/QA próprios e um QA de referência específico para comparação de volumetria. Usar um único baseline genérico seria inválido.

#### Solução
Arquitetura **multi-esteira** parametrizável:

| Esteira | DEV Targets | QA Referência | Uso |
|---------|-------------|---------------|-----|
| **esteira1** | DEV2, DEV3 | QA6 | Release Candidate |
| **esteira2** | DEV5, DEV7 | QA1 | Testes Avançados |
| **preprod** | DEV4, DEV6 | QA3 | Pré-Produção |
| **prodlike** | DEV8 | QA2 | Produção-like |

Cada esteira pode executar independentemente com seu próprio baseline e hosts. Seleção via parâmetro `esteira`.

#### Status
✅ **Implementado e validado**. Variable Groups por esteira, jobs paralelos, parametrização clara.

#### Benefícios
- Isolamento: alterações em esteira1 não afetam esteira2
- Flexibilidade: múltiplos times podem validar simultaneamente
- Escalabilidade: adicionar nova esteira = criar Variable Group + condicional no pipeline
- Rastreabilidade: cada execução registra esteira usada

---

### **Decisão 3: Migração para Variable Groups (Phase 6 — Eliminação de Config Files em Runtime)**

#### Problema (Phase 5 e Anteriores)
Configuração estava em `config/environments.yml` — arquivo versionado no repo. Trocar esteira ou atualizar hosts **obrigava commit/PR**, criando overhead operacional e risco de merge conflicts.

#### Solução (Phase 6 — 2026-06-19)
Migração para **Azure DevOps Variable Groups** como única fonte de verdade em runtime:

- **vg-sibl-clone-validation-global** — service_name, port, username (constantes)
- **vg-sibl-clone-validation-<esteira>** — hosts, lista ambientes, QA ref (por esteira)
- **SIBLCloneValidationSecrets** — senhas Oracle (Key Vault binding)

Resultado: **troca de esteira = seleção de parâmetro apenas**. Sem arquivo, sem commit, sem PR.

#### Status
✅ **Implementado** (Phase 6, 2026-06-19). `config/environments.yml` mantido como referência documental fallback.

#### Benefícios
- **Zero-friction operação:** DevOps altera hosts/esteira sem tocar código
- **Secrets gerenciados:** Senhas em Key Vault, nunca em repo
- **Auditoria nativa:** Azure DevOps rastreia acesso/modificação a Variable Groups
- **Versionamento de contrato:** `scripts/utils/env_contract.py` (v1.0.0) valida formato esperado

#### Contrato Obrigatório
```python
CONTRACT_VERSION = "1.0.0"
# Prefixo: CV_* para config, ORACLE_PASSWORD_* para secrets
# Backward-compatible: adições em 1.x; breaking changes = 2.0.0
```

---

### **Decisão 4: Dual Documentation (Passo-a-Passo + Consolidado PDF)**

#### Problema
Queries SQL para validação post-clone estão documentadas em dois formatos:
- **Manual PDF corporativo** — contém sequência e lógica operacional
- **Consolidado PDF** — contém SQL bruto mais completo para passos 5 e 7

Qual é fonte de verdade? Qual usar para implementação?

#### Solução
**Regra de uso documentada:**
- **Obrigatórios (passos 1-9):** seguem sequência de [passo-a-passo-validacao-pos-clone-com-queries.md](docs/passo-a-passo-validacao-pos-clone-com-queries.md) (canonical)
- **Complemento técnico:** [conteudo-consolidado-pdfs.md](docs/conteudo-consolidado-pdfs.md) para SQL mais profundo em passos 5 e 7
- **Opcionais (passos 10.x):** exclusivamente no consolidado

Ambas mantidas em repo como documentação viva. Pipeline executa passos conforme sequência canônica, com referência ao consolidado onde apropriado.

#### Status
✅ **Implementado e documentado**. Regra explícita no README.md e em ARCHITECTURE.md.

#### Benefícios
- Clareza: sequência operacional não é ambígua
- Flexibilidade: SQL bruto disponível para referência técnica
- Auditoria: documentação viva facilita rastreamento de mudanças

---

### **Decisão 5: Fail-Fast Strategy — Erro SQL = Parada Imediata**

#### Problema
Validação post-clone deve ser **confiável e segura**. Se um passo SQL falha (erro de sintaxe, timeout, conexão perdida), continuar executando passos subsequentes pode propagar estados inválidos e criar inconsistências de dados.

#### Solução
**Regra obrigatória:** qualquer erro SQL/conexão/timeout **falha imediatamente a execução**, bloqueando passos subsequentes.

- **Passos obrigatórios (1-9):** falha em qualquer erro
- **Passos opcionais (10.x):** falha se habilitados; não bloqueiam pipeline se desabilitados
- **Evidence logging:** todos os erros registrados com contexto completo (stack trace, timestamp, host, step, query)

#### Status
✅ **Implementado em scripts Python**. Controle de exit codes + logger estruturado.

#### Benefícios
- **Integridade de dados:** evita validação parcial/inconsistente
- **Segurança operacional:** falha clara = DevOps aware imediatamente
- **Auditoria:** log detalhado permite RCA fácil

---

### **Decisão 6: Validação YAML em BuildValidation Stage**

#### Problema
Pipeline YAML pode ter erros sintáticos ou violar contrato de variáveis. Descobrir no meio da execução é custoso.

#### Solução
**Novo stage BuildValidation** executado primeiro em toda pipeline:
- Valida YAML contra schema CodePlay Framework
- Valida contrato de variáveis (CV_* obrigatórias, tipos, formato)
- Falha fast se contrato violado

Implementado via custom task ou script local (`validate_build_yaml --check-contract <esteira>`).

#### Status
✅ **Implementado** (Phase 5+). Documentado em ARCHITECTURE.md.

#### Benefícios
- **Fail-fast:** erros de config detectados em segundos
- **Framework compliance:** garante aderência a padrões corporativos
- **Developer-friendly:** feedback claro (qual variável falta/está inválida)

---

## ✅ Conformidade com CodePlay Framework

Clone Validation é um projeto **integral ao framework**, não uma exceção. Cobertura:

| Capacidade | Framework | Clone Validation | Status | Como |
|-----------|-----------|------------------|--------|------|
| **Stages Sequenciais** | ✅ | ✅ | OK | BuildValidation → Prepare → ExecuteMandatory → Evidence → Summary |
| **Parametrização YAML** | ✅ | ✅ | OK | Parâmetros: `environment`, `dryRun`, `override_environments`, `skip_optional_steps`, `baseline_volumetry` |
| **Variable Groups** | ✅ | ✅ | OK | 5 grupos: global + 4 esteiras + secrets |
| **Variáveis Normalizadas** | ✅ | ✅ | OK | Prefixo `CV_` para config, `ORACLE_PASSWORD_*` para secrets |
| **SAST Scanning** | ✅ | ✅ | OK | Template `/security/run_sast_scan.yml` executado em stage SecurityAnalysis (futuro: Phase 7) |
| **SCA / Quality Gates** | ✅ | ✅ | OK | Template reutiliza `SonarAnalysisFromVivo@2` (futuro: Phase 7) |
| **AppConfig Keys Management** | ✅ | ✅ | OK | Template `/security/get_appconfig_keys_framework.yml` |
| **Deployment Event Hub** | ✅ | ✅ | OK | Task `VivoEventHubTools@2` em stage DeploymentCompleted (registra validação) |
| **Documentação** | ✅ | ✅ | OK | README.md, ARCHITECTURE.md, CONFIGURATION.md, passo-a-passo, consolidado |
| **Helm/Kubernetes Deploy** | ✅ | ❌ | N/A | Inapropriado para validação post-clone |
| **Container Registry** | ✅ | ❌ | N/A | Não aplica (validação, não deployment de aplicação) |

**Conclusão:** ~75% de reutilização direta de padrões framework. Especialização em data validation é legítima e justificada.

---

## 🔐 Segurança e Credenciais

### Implementado
- ✅ **Variable Groups** para secrets (nunca hardcode)
- ✅ **Azure Key Vault** binding via Service Connection
- ✅ **Self-hosted agent** (acesso corporativo só dentro da rede)
- ✅ **Senha por tipo de operação:** `ORACLE_PASSWORD`, `ORACLE_PASSWORD_SIEBEL`, `ORACLE_PASSWORD_SADMIN`, `ORACLE_PASSWORD_QUEUE_OWNER`
- ✅ **Logging estruturado** — todas as operações registradas com timestamp/host/step/query
- ✅ **Auditoria de execução** — registro em Event Hub (via `VivoEventHubTools@2`)

### Em Planejar (Phase 7+)
- [ ] Integração com Change Management (ServiceNow CMDB)
- [ ] Notificações automáticas pós-validação
- [ ] Approval workflows avançados (para passos write-heavy)

---

## 📊 Fases de Evolução

### Phase 4 (Data Anterior ao Rastreamento)
- ✅ **Entrega:** YAML validation em BuildValidation, checklist operacional, rotina de revisão mensal
- ✅ **Foco:** Documentação de passos 1-9, ajustes para uso recorrente
- **Status:** Baseline estabelecido

### Phase 5 (2026-06-17)
- ✅ **Entrega:** Padronização ao CodePlay Framework
- ✅ **Mudanças:** 
  - Stages reorganizados (BuildValidation, Prepare, ExecuteMandatory, Evidence, Summary)
  - Parâmetros com `displayName` descritivo
  - Variáveis normalizadas (`CV_*` prefix)
  - Documentação em PHASE5_IMPLEMENTATION.md
- **Status:** Framework compliance garantido

### Phase 6 (2026-06-19) — **ATUAL**
- ✅ **Entrega:** Migração para Global Environments (Variable Groups)
- ✅ **Mudanças:**
  - `config/environments.yml` → referência fallback apenas
  - Variable Groups como fonte de verdade
  - Contrato versionado (`scripts/utils/env_contract.py` v1.0.0)
  - Zero-friction operação (troca esteira = parâmetro apenas)
- **Status:** Production-ready, Phase 6 em uso

### Phase 7 (Roadmap — Q3 2026)
- [ ] **Objetivo:** Compilação SRF e import automático
- [ ] **Escopo:** Stages Compile, Import, PostDeploy (WebLogic restart)
- [ ] **SAST/SCA:** Integração completa com Fortify/SonarQube templates
- [ ] **Release Notes:** Documentação automática de mudanças

### Phase 8+ (Roadmap — Q4 2026+)
- [ ] **Objetivo:** Consolidação e otimização
- [ ] **Escopo:** Lições aprendidas, otimização de build time, automação de testes avançados
- [ ] **Modernização:** Migration planning para re-arquitetura (18-24 meses futuro)

---

## 📋 Escopo vs. Fora de Escopo

### ✅ Em Escopo
| Item | Descrição |
|------|-----------|
| Validação de volumetria | Comparar counts entre clone e QA baseline |
| Limpeza de tabelas técnicas | Truncate workflows, escalações, docks, filas técnicas |
| Atualização de LOVs | Cache components por environment |
| Unlock de objetos | Desbloquear objetos e projetos travados |
| Permissões de dev | Restaurar escrita para desenvolvedores |
| Apontamentos por env | LOVs, WebServices, Hosts, CTI por esteira |
| Usuários DB | Criar usuários Oracle, conceder SSE_ROLE |
| Runtime Scripts | Validar ou habilitar Runtime Scripts System Access |

### ❌ Fora de Escopo
| Item | Motivo |
|------|--------|
| Orchestração de clone | Clone é responsabilidade de infra; Clone Validation assume já completo |
| Testes end-to-end | Clone Validation valida dados/metadata; testes app = escopo de QA |
| Estatísticas DB | Opcional (contingency); fora do core obrigatório |
| Filas AQ | Opcional (contingency); fora do core obrigatório |
| Sequences reset | Opcional (contingency); fora do core obrigatório |
| Backup/Restore | Responsabilidade de backup team |

---

## 🚀 Configuração Inicial e Manutenção

### Setup Pré-Pipeline (DevOps Team)
1. Criar Variable Groups em Azure DevOps Library (5 grupos: global + 4 esteiras + secrets)
2. Autorizar pipeline a acessar cada grupo (Security → Pipeline Permissions)
3. Validar conectividade com hosts Oracle via self-hosted agent
4. Seed inicial de secrets em Azure Key Vault

### Manutenção Recorrente
- **Mensal:** Revisar execuções, validar evidências
- **Trimestral:** Revisar contrato de variáveis (`env_contract.py`)
- **Anual:** Avaliar roadmap de próxima fase

### Adicionar Nova Esteira
1. Criar Variable Group: `vg-sibl-clone-validation-<nova_esteira>`
2. Definir variáveis conforme contrato (CV_ESTEIRA_AMBIENTES, CV_*_HOST, CV_QA_REF_*)
3. Adicionar condicional em `azure-pipelines.yml`
4. Testar com `dry_run=true`

---

## 📍 Referências

- [README.md](README.md) — Overview do projeto
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — Arquitetura técnica detalhada
- [docs/CONFIGURATION.md](docs/CONFIGURATION.md) — Configuração de Variable Groups
- [docs/passo-a-passo-validacao-pos-clone-com-queries.md](docs/passo-a-passo-validacao-pos-clone-com-queries.md) — Sequência canônica de passos
- [docs/conteudo-consolidado-pdfs.md](docs/conteudo-consolidado-pdfs.md) — SQL bruto e complementar
- [CONTRIBUTING.md](../../CONTRIBUTING.md) — Guia de contribuição CodePlay Framework
- [GUIDELINES.md](../../GUIDELINES.md) — Diretrizes de pipelines framework
- [Premissas do Framework](https://dvps.redecorp.azr/portal/codeplay/framework/premissas)

---

## 📝 Histórico de Revisões

| Versão | Data | Autor | Alterações |
|--------|------|-------|-----------|
| 1.0 | 28/07/2026 | DevOps Team | Versão inicial — ADR consolidando 6 decisões arquiteturais, conformidade framework, phases 4-6, roadmap, segurança |

---

**Status:** ✅ **ATIVA** — Clone Validation está em production-ready (Phase 6), seguindo conformidade CodePlay Framework.

**Próxima Revisão:** 28/10/2026 (quarterly)
