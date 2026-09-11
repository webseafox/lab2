# 📋 Carta de Exceção - Siebel Legacy (SIBL)

> **Versão:** 1.1 | **Data:** 03/03/2026 | **Status:** Ativa

---

## 📋 Informações Gerais

| Campo | Valor |
|-------|-------|
| **Tech Product** | Siebel Legacy (SIBL) |
| **Sigla** | `sibl` |
| **Área Responsável** | DevOps / Siebel Squad |
| **Data de Submissão** | 02/03/2026 |
| **Status da Aprovação** | ✅ Ativa |

---

## 🎯 Executive Summary

Este documento justifica a criação de um pipeline de CI/CD específico em `/tech_products/sibl/` ao invés de utilizar os pipelines padronizados do CodePlay Framework.

**Razão Principal:** O Siebel Legacy requer tratamento especial devido a arquitetura monolítica legada, processos de deployment via SSH/SFTP, e integrações específicas com infraestrutura on-premises que não se adequam aos padrões cloud-first do framework.

**Conformidade:** O pipeline segue TODOS os padrões CodePlay Framework:
- ✅ Usa Custom Tasks First (VersionManagerVivo, SonarAnalysisFromVivo, VivoEventHubTools)
- ✅ Reutiliza templates de segurança e qualidade (Fortify SAST, SonarQube)
- ✅ Implementa stages padrão (Prepare, Build, Security, Quality, Deploy)
- ✅ Suporta execução por objetivo com `pipelineObjective` (`ci`, `cd`, `cicd`)
- ✅ Documentação completa e validação de pipeline

---

## ❌ Por Que o Framework Não Atende

### 1. **Arquitetura Monolítica Legacy**

O Siebel CRM é uma aplicação monolítica Oracle com requisitos únicos:

**Framework oferece:** Pipelines modernos otimizados para container, microserviços, cloud-first  
**SIBL requer:**
- Build process customizado (SOM - Sistema de Objetos de Migração)
- Export/compile de artefatos Siebel Repository (.sif, .srf, .xml)
- Integração com ferramentas proprietárias Oracle/Siebel
- Validação de objetos em ambiente Siebel dedicado (não containerizado)

### 2. **Deployment via SSH/SFTP (On-Premises)**

SIBL deploy requer infraestrutura on-premises legada:

**Framework oferece:** Helm, Kubernetes, Azure Container Registry (cloud-first)  
**SIBL requer:**
- Transfer via SFTP para servers on-premises
- Execução remota via SSH com scripts bash/batch customizados
- Zero-downtime deployment com validação manual de healthchecks
- Restart de serviços WebLogic on-premises

### 3. **Integrações Proprietárias Oracle/Siebel**

SIBL depende de tecnologia legada não containerizável:

- **Application Servers**: Oracle WebLogic (legacy), Tomcat
- **Database**: Oracle 11g/19c sspecífica da instância Siebel
- **Load Balancing**: F5 on-premises
- **Monitoring**: Integração com ferramentas corporativas legadas
- **Gateway**: Siebel Gateway integrado com componentes proprietários

**Framework oferece:** Integração com Azure Services, Azure Monitor, padrão Kubernetes  
**Não viável para SIBL**: Decomposição em padrão cloud requer re-arquitetura completa do Siebel (~18-24 meses)

### 4. **Processos de Validação Customizados**

SIBL mantém gates corporativos específicos de legado:

- **Validação manual via email** antes de deploy em produção
- **Approval gates** integração com ServiceNow (PM/CHG/RDM/CTASK)
- **Checksum validation** de artefatos .sif/.srf
- **Release notes** documentadas em formato corporativo
- **Sincronização com Change Management** externo (Jira/ServiceNow)

**Framework oferece:** Gates automáticos SonarQube/Fortify  
**SIBL requer:** Gates manuais + SAST/SCA automático (implementado via templates)

---

## ✅ Cobertura do Framework vs Requisitos SIBL

| Capacidade | Framework | SIBL | Status | Solução |
|-----------|-----------|------|--------|---------|
| **Parametrização YAML** | ✅ | ✅ | OK | Nativo |
| **Stages Sequenciais** | ✅ | ✅ | OK | Nativo |
| **Custom Tasks** | ✅ | ✅ | OK | VersionManagerVivo, SonarAnalysisFromVivo |
| **SAST Fortify** | ✅ | ✅ | OK | Template run-sast-scan.yaml |
| **SCA/Quality Gate** | ✅ | ✅ | OK | SonarAnalysisFromVivo @2 |
| **Security AppConfig Keys** | ✅ | ✅ | OK | Template get_appconfig_keys_framework.yml |
| **Deployment Event Hub** | ✅ | ✅ | OK | VivoEventHubTools @2 |
| **CI/Build Automático** | ✅ | ✅ | OK | Padrão framework |
| **Helm/Kubernetes Deploy** | ✅ | ❌ | N/A | Inapropriado para on-prem |
| **Container Registry** | ✅ | ❌ | N/A | SFTP em local |
| **SSH/SFTP Deploy** | ❌ | ✅ | **EXCEÇÃO** | Scripts bash customizados |
| **WebLogic Integration** | ❌ | ✅ | **EXCEÇÃO** | Scripts batch Windows customizados |
| **Manual Gates** | Parcial | ✅ | **EXCEÇÃO** | Aprovações via Azure DevOps |
| **Legacy System Validation** | ❌ | ✅ | **EXCEÇÃO** | Healthcheck customizado |

**Conclusão**: ~65-70% de cobertura pelo framework. Estruturação como tech_product é justificada.

---

## 🏗️ Implementação da Solução SIBL

### Estrutura de Diretórios

```
tech_products/sibl/
├── pipeline.yaml                    # Pipeline principal de CD/CI
├── README.md                        # Documentação
├── carta_excecao.md                 # Este documento
├── docs/
│   ├── HEALTH_CHECK.md             # Validação de infraestrutura
│   ├── VARIABLE-GROUPS-STRUCTURE.md # Configuração de variáveis
│   ├── 01-VISAO-GERAL.md           # Overview do sistema
│   ├── 02-ARQUITETURA-MODULOS.md   # Arquitetura de módulos
│   └── wiki/                       # Documentação técnica
└── base-de-info-som-*              # Código fonte legado (referência)
```

### Stages do Pipeline (Implementados)

`pipelineObjective: ci` → stages de validação/segurança
`pipelineObjective: cd` → stage de registro de deployment
`pipelineObjective: cicd` → execução combinada de CI + CD

✅ **Prepare** - Validação, versionamento, checkout  
✅ **Identification** - ID automática de objetos alterados  
✅ **Export** - Export de artefatos .sif/.xml  
✅ **SecurityAnalysis** - Fortify SAST scan (obrigatório)  
✅ **QualityGates** - SonarQube analysis (obrigatório)  
✅ **SecurityGate** - Bloqueiar se gates falham  
✅ **DeploymentCompleted** - Registro Event Hub (novo)  

### Stages Customizados (Próximas Iterações)

⏳ **GitOperations** - Commit/tag (fase 2)  
⏳ **Compile** - SRF compilation (fase 2)  
⏳ **Import** - Object import (fase 2)  
⏳ **PostDeploy** - WebLogic restart, ADM validation (fase 2)  
⏳ **Activate** - Workflow/Rule activation (fase 2)  

---

## 🔒 Aderência aos Padrões CodePlay Framework

### Custom Tasks (Obrigatório "Custom Tasks First")

| Task | Propósito | Status |
|------|-----------|--------|
| `VersionManagerVivo@8` | Versionamento semântico | ✅ Implementado |
| `SonarAnalysisFromVivo@2` | Quality Gate SonarQube | ✅ Implementado |
| `VivoEventHubTools@2` | Registro de deployment | ✅ **Adicionado** |

### Templates Reutilizáveis (Obrigatório)

| Template | Propósito | Status |
|----------|-----------|--------|
| `/security/get_appconfig_keys_framework.yml` | Obter chaves AppConfig | ✅ Implementado |
| `/security/define_appsec_app_version.yml` | Definir versão AppSec | ✅ Implementado |
| `/framework/templates/run-sast-scan.yaml` | Scan Fortify SAST | ✅ Implementado |

### Padrões Seguidos

- ✅ **Parâmetros em camelCase** (environment, migrationMode, objectType, etc)
- ✅ **Variáveis em UPPER_SNAKE_CASE** (SIGLA, PIPELINE_VERSION, CI_AGENT_POOL, etc)
- ✅ **Stages bem organizados** com display names descritivos
- ✅ **Documentação completa** com README.md, arquitectura, exemplos
- ✅ **Validação** via `validate-pipelines` (make/runner local)
- ✅ **Secrets em Variable Groups**, nunca hardcoded
- ✅ **Logs estruturados** com info ao início de cada stage

---

## 📊 Plano de Evolução

### Fase 1 (ATUAL) - MVP e Conformidade
- ✅ Deploy infrastructure preparada
- ✅ Security gates (Fortify + SonarQube) funcionando
- ✅ Pipeline parametrizável e reutilizável
- ✅ Documentação técnica completa
- ✅ Conformidade com CodePlay Framework

### Fase 2 (Próximos 2-3 meses)
- [ ] Compilação SRF automática
- [ ] Import de objetos com validação
- [ ] Restart de serviços WebLogic
- [ ] Ativação de Workflows/Rules

### Fase 3 (Roadmap)
- [ ] Consolidação de lições aprendidas
- [ ] Otimização de build time
- [ ] Automação de testes avançados
- [ ] Migration planning para modernização

---

## 🔐 Segurança e Compliance

### Implementado
- ✅ Variable Groups para secrets (nunca hardcode)
- ✅ Secure Files para SSH keys
- ✅ SAST scanning obrigatório (Fortify)
- ✅ SCA/Quality gates (SonarQube)
- ✅ Auditoria de deployments (VivoEventHubTools)
- ✅ Logging estruturado de todas as operações

### Em Planejar
- [ ] Integração com ServiceNow (CMDB)
- [ ] Notificações automatizadas
- [ ] Approval workflows avançados

---

## 📍 Referências

- [CodePlay Framework - Documentação](https://dvps.redecorp.azr/portal/codeplay/)
- [CONTRIBUTING.md](../../CONTRIBUTING.md) - Guia de contribuição
- [GUIDELINES.md](../../GUIDELINES.md) - Diretrizes de pipelines
- [Premissas do Framework](https://dvps.redecorp.azr/portal/codeplay/framework/premissas)

---

## 📝 Histórico de Revisões

| Versão | Data | Autor | Alterações |
|--------|------|-------|-----------|
| 1.1 | 03/03/2026 | DevOps Team | Inclusão do modo `pipelineObjective: cicd` e atualização de conditions CI/CD |
| 1.0 | 02/03/2026 | DevOps Team | Versão inicial - Activação da exceção SIBL |

---

**Status:** ✅ **ATIVA** - Pipeline SIBL está em production-ready status, seguindo conformidade CodePlay Framework.

**Próxima Revisão:** 02/06/2026 (quarterly)
