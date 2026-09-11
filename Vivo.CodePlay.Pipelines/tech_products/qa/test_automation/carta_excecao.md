# 📋 Carta de Exceção - QA Test Automation (QA)

> **Versão:** 1.0 | **Data:** 30/06/2026 | **Status:** Em Aprovação

---

## 📋 Informações Gerais

| Campo | Valor |
|-------|-------|
| **Tech Product** | QA Test Automation |
| **Sigla** | `qa` |
| **Caminho** | `tech_products/qa/test_automation/pipeline.yaml` |
| **Área Responsável** | Engenharia de Software / Automação B2X |
| **Data de Submissão** | 30/06/2026 |
| **Status da Aprovação** | ⏳ Em Aprovação |

---

## 🎯 Executive Summary

Este documento justifica a manutenção de um pipeline **específico e customizado** em
`/tech_products/qa/test_automation/`, ao invés da adoção de um dos modelos padronizados do
**CodePlay Framework**.

**Razão Principal:** Este pipeline **não é um pipeline de build/deploy de aplicação**. Ele é um
**executor de cenários de teste automatizados** (Selenium/Maven) que roda *suites* de teste
sob demanda dentro de um container dedicado (`selenium-junit/oraclient`), publica os relatórios
de execução (`RunResults`) e, opcionalmente, atualiza a ferramenta de ALM (Octane).

**Conclusão:** Não existe, no catálogo atual do CodePlay Framework, um modelo de CI cujo objetivo
seja a **execução de cenários de teste QA**. Todos os modelos de CI disponíveis destinam-se a
**construir** artefatos deployáveis (imagem Docker, biblioteca, chart Helm, etc.). Forçar a
adequação a esses modelos descaracterizaria a finalidade do pipeline. Por isso, a estruturação
como `tech_product` customizado é justificada.

---

## ❌ Por Que o Framework Não Atende

### 1. **Natureza do pipeline: executor de testes, não build de aplicação**

| Aspecto | Modelos CI do Framework | QA Test Automation |
|---------|--------------------------|--------------------|
| Objetivo | Compilar/empacotar app | Executar cenários de teste |
| Saída | Artefato deployável (imagem/lib/chart) | Relatórios de execução (`RunResults`) |
| Versionamento | Commit/tag semântico | Não aplicável |
| Registro de deploy | Obrigatório (Event Hub) | Não aplicável (não há deploy) |

**Framework oferece:** `build-java-docker`, `build-java-lib`, `build-helm`, etc. — todos
voltados a **construir** e publicar artefatos.
**QA requer:** apenas **rodar** *suites* de teste (E2E, BRM, Salesforce, RGC, etc.) e coletar
evidências.

### 2. **Lógica de despacho de cenários por parâmetros**

O pipeline monta dinamicamente o comando Maven (`maven_command`) a partir de uma extensa árvore
de condicionais de tempo de compilação (`${{ if }}`), baseada em:

- `scenariosType` (e2e, brm, salesforce, rgc-b2b, ...)
- `inputs` (pod, test, estado, cnpj, ep_cucumber, dayWeek, ...)
- `suit`, `maven` e demais objetos de configuração

Essa lógica de seleção de cenário **não tem equivalente** em nenhum parâmetro dos modelos do
Framework. Migrar implicaria **descartar** todo esse mecanismo, quebrando a regra do Framework de
"não inventar parâmetros".

### 3. **Imagem de execução e dependências proprietárias**

A execução ocorre em imagem dedicada de QA
(`acrsharedservices01.azurecr.io/base/qa/selenium-junit/oraclient/runtime`), com Selenium, JUnit e
*Oracle client*, além de integração opcional com a ferramenta de **ALM/Octane**. Os modelos do
Framework assumem *runtimes* de build padrão, não o ambiente de execução de testes funcionais.

### 4. **Ausência de estágio de deploy (somente CI)**

O pipeline **não possui** estágio de CD: não publica imagem de aplicação, não versiona, não
registra deploy. Logo, não se enquadra no fluxo CI→CD esperado pelos modelos do Framework.

---

## ✅ Cobertura do Framework vs Requisitos QA

| Capacidade | Framework | QA Test Automation | Status | Observação |
|-----------|-----------|--------------------|--------|------------|
| **Parametrização YAML** | ✅ | ✅ | OK | Nativo |
| **Stages/Jobs/Steps padrão** | ✅ | ✅ | OK | Nativo |
| **Agent Pool CI** (`GeneralPurposeLinuxAgentsCI`) | ✅ | ✅ | OK | Aderente |
| **Secrets via Key Vault / Variable Groups** | ✅ | ✅ | OK | `AzureKeyVault@2`, Variable Groups |
| **Publicação de artefatos** | ✅ | ✅ | OK | `PublishPipelineArtifact@1` |
| **Build de aplicação / imagem Docker** | ✅ | ❌ | N/A | Inaplicável (não há app) |
| **Versionamento semântico** | ✅ | ❌ | N/A | Inaplicável |
| **Registro de deploy (Event Hub)** | ✅ | ❌ | N/A | Não há deploy (CI apenas) |
| **Execução de cenários de teste QA** | ❌ | ✅ | **EXCEÇÃO** | Sem modelo equivalente no Framework |
| **Despacho de cenários por parâmetros** | ❌ | ✅ | **EXCEÇÃO** | Árvore condicional `maven_command` |
| **Integração ALM/Octane** | ❌ | ✅ | **EXCEÇÃO** | `update_alm_tool` |

**Conclusão:** O Framework não cobre o caso de uso central (execução de testes). A estruturação
como `tech_product` é justificada.

---

## 🏗️ Implementação da Solução

### Estrutura de Diretórios

```
tech_products/qa/test_automation/
├── pipeline.yaml        # Pipeline de execução de cenários de teste (CI)
└── carta_excecao.md     # Este documento
```

### Decisões técnicas registradas

1. **Absorção do template do Vivo Core Pipelines** — o template
   `/provisioners/qa/trunkbased/java/scenarios_default/stages/scenarios_exec.yml` foi
   **incorporado inline** ao `pipeline.yaml` (stage `scenarios_exec`), eliminando a dependência
   externa do repositório `Vivo.Core.Pipelines`.
2. **`maven_command` como parâmetro de topo** — o comando Maven é recebido do componente que
   invoca o pipeline (`${{ parameters.maven_command }}`), permitindo parâmetros customizados; a
   árvore condicional foi mantida como `variables:` do stage.
3. **Não migração para o CodePlay Framework** — por inexistência de modelo de CI compatível com
   execução de cenários de teste QA (decisão desta carta).

---

## 🔒 Aderência aos Padrões CodePlay Framework

### Padrões seguidos

- ✅ **Agent Pool de CI padrão** (`GeneralPurposeLinuxAgentsCI`)
- ✅ **Secrets em Key Vault / Variable Groups** — nunca *hardcoded*
- ✅ **Publicação de artefatos** padrão do Azure DevOps
- ✅ **`displayName` descritivo** em stages e steps
- ✅ **Validação** via `pipeline-validator` (sem erros de parse)

### Pontos não aplicáveis (por natureza do pipeline)

- ⚠️ **Custom Tasks de build/qualidade** (`VersionManagerVivo`, `SonarAnalysisFromVivo`,
  `VivoEventHubTools`) — não se aplicam a um *test-runner* sem build/deploy.
- ⚠️ **SAST/SCA** — o repositório executado não é o código-fonte de uma aplicação deployável;
  a análise de segurança ocorre nos pipelines das aplicações sob teste.

---

## ⚠️ Riscos Identificados

- **Risco de Manutenção:** pipeline customizado fora do padrão exige manutenção dedicada da squad
  de QA.
- **Risco de Divergência:** evolução do Framework pode introduzir um modelo de execução de testes
  que torne esta exceção obsoleta.
- **Risco de Segurança:** uso de credenciais (Nexus/ACR) na execução dos testes.

## 🛠️ Planos de Ação (Mitigação)

- Segredos e credenciais geridos exclusivamente via **Key Vault / Variable Groups**.
- Revisão periódica desta exceção (ver "Revisões Futuras").
- Reavaliar migração caso o CodePlay Framework passe a oferecer um modelo de execução de testes QA.

---

## 👥 RACI

| Atividade | Time de DevOps | Área Cliente (QA) |
|-----------|----------------|-------------------|
| Criação/manutenção do pipeline customizado | C | R |
| Manutenção da lógica de cenários de teste | C | R |
| Debug em casos de falha de execução | C | R |
| Funcionamento da infraestrutura de agents | R | I |
| Governança e diretrizes DevOps | A | C |
| Revisão de segurança e acessos | A | R |

**R – Responsável** · **A – Aprovador** · **C – Consultado** · **I – Informado**

---

## ✅ Aprovação

_Listar os stakeholders que devem aprovar esta carta antes de prosseguir:_

- _Nome – Papel – Área – e-mail_ **(preencher)**
- _Nome – Papel – Área – e-mail_ **(preencher)**

---

## 📍 Referências

- [CodePlay Framework - Documentação](https://dvps.redecorp.azr/portal/codeplay/)
- [Guia de Migração: Vivo Core → CodePlay Framework](https://dvps.redecorp.azr/portal/code/casos-de-uso/migracao-core-para-framework)
- [CONTRIBUTING.md](../../../CONTRIBUTING.md)
- [GUIDELINES.md](../../../GUIDELINES.md)

---

## 🔄 Revisões Futuras

Esta carta de exceção deverá ser revisada periodicamente ou sempre que houver:

- Mudanças significativas no pipeline de execução de testes
- Alterações nas diretrizes corporativas de DevOps/Segurança
- Disponibilização de um modelo de CI de execução de testes QA no CodePlay Framework

---

## 📝 Histórico de Revisões

| Versão | Data | Autor | Alterações |
|--------|------|-------|------------|
| 1.0 | 30/06/2026 | QA / Test Automation Squad | Versão inicial — justificativa da exceção (não migração para o Framework) e registro da absorção do template do Vivo Core Pipelines |

---

**Status:** ⏳ **EM APROVAÇÃO** — aguardando assinatura dos stakeholders.

**Próxima Revisão:** 30/09/2026 _(trimestral)_
