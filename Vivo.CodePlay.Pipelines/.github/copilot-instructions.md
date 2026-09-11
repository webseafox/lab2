# Copilot Instructions - CodePlay Framework

> Este arquivo contém instruções para o GitHub Copilot ao trabalhar com o repositório CodePlay Framework.

---

## 📖 Sobre Este Repositório

O **Vivo.CodePlay.Pipelines** é o repositório central do CodePlay Framework, contendo:

- **Pipelines prontos para uso** em `/framework/pipelines/`
- **Templates reutilizáveis** em `/framework/templates/`
- **Pipelines de tech products** em `/tech_products/`
- **Documentação e exemplos** em `/doc/` e `/examples/`
- **Templates de segurança** em `/security/`

---

## 🚀 Princípios de Design (CRÍTICO)

### 1. Plug and Play
- **80% dos casos** devem funcionar **SEM configurar nenhum parâmetro**
- Defaults inteligentes derivam valores do contexto (SIGLA, nome do repo, etc.)

### 2. AI First / AI Friendly
- Pipelines devem ser **fáceis para IA entender, editar e configurar**
- Comentários descritivos em todas as seções
- `displayName` obrigatório em todos os parâmetros
- Lista `values` quando há opções válidas

### 3. Custom Tasks First
- **SEMPRE** use as Custom Tasks internas ao invés de scripts manuais
- Tasks principais: `VersionManagerVivo@8`, `SonarAnalysisFromVivo@2`, `K8sUtilsFromVivo@2`, `VivoAppSecTools@1`

### 4. DRY - Evitar Duplicação
- **ANTES de criar novo pipeline**, verifique se já existe similar
- Use **parâmetros** para atender variações, não novos pipelines

### 5. Consistência de Parâmetros
- Nomes de parâmetros **IDÊNTICOS** entre pipelines similares
- Ex: `agentPool`, `prValidationOnly`, `enableTest`, `runQualityGate`
- Ao incluir um novo parâmetro, execute o validator com `MATRIX=true` para comparar visualmente se o nome, tipo e default seguem o mesmo padrão dos outros pipelines CI ou CD:
  ```bash
  make validate-custom PIPELINE=<caminho/do/pipeline.yaml> MATRIX=true
  ```

---

## 🎯 Instruções Específicas

### Para Criação/Modificação de Pipelines do Framework

Ao criar ou modificar pipelines na pasta `/framework/`, siga as instruções detalhadas em:

📄 **[framework/.github/copilot-instructions-pipelines.md](../framework/.github/copilot-instructions-pipelines.md)**

Este documento contém:
- **Custom Tasks obrigatórias** e como usá-las
- Estrutura de diretórios obrigatória
- Padrões de nomenclatura
- **Consistência de parâmetros** entre pipelines
- Formato do arquivo `pipeline.yaml`
- Organização de parâmetros e variáveis
- Estrutura de stages e steps
- Templates de segurança obrigatórios
- **Anti-patterns** a evitar
- Checklist de validação

---

## 🔧 Custom Tasks Principais

| Task | Propósito | Documentação |
|------|-----------|--------------|
| `VersionManagerVivo@8` | Versionamento semântico | Calcular/commitar versões |
| `SonarAnalysisFromVivo@2` | Quality Gate SonarQube | Análise de qualidade |
| `K8sUtilsFromVivo@2` | Deploy Kubernetes/Helm | Operações K8s |
| `VivoAppSecTools@1` | Segurança SAST/SCA | Análises de segurança |
| `VivoUtilsFromVivo@1` | Utilitários diversos | Debug, validações |
| `VivoEventHubTools@2` | Registro de deploy | **OBRIGATÓRIO em CD** |

**⚠️ NUNCA reimplemente funcionalidade que existe em custom task!**

**⚠️ Todo pipeline de CD DEVE incluir `VivoEventHubTools@2` para registro de deploy!**

---

## 🏗️ Estrutura do Repositório

```plaintext
Vivo.CodePlay.Pipelines/
├── framework/                    # Framework de pipelines prontos para uso
│   ├── pipelines/
│   │   ├── ci/                   # Pipelines de Integração Contínua
│   │   │   ├── build-java-docker/
│   │   │   ├── build-nodejs-docker/
│   │   │   ├── build-python-docker/
│   │   │   ├── build-java-lib/
│   │   │   ├── build-nodejs-lib/
│   │   │   ├── build-python-lib/
│   │   │   ├── build-helm/
│   │   │   └── ...
│   │   └── cd/                   # Pipelines de Entrega Contínua
│   │       ├── deploy-helm/
│   │       ├── deploy-ssh/
│   │       ├── deploy-liquibase/
│   │       └── ...
│   ├── templates/                # Templates compartilhados
│   │   ├── docker-build-and-push.yaml
│   │   ├── run-sast-scan.yaml
│   │   └── run-sca-scan.yaml
│   └── docs/                     # Documentação do framework
├── tech_products/                # Pipelines específicos de produtos
├── security/                     # Templates de segurança (AppSec)
├── examples/                     # Exemplos de uso
├── config/                       # Configurações e políticas
└── doc/                          # Documentação geral e ADRs
```

---

## 📐 Convenções Gerais

### Nomenclatura de Arquivos

| Tipo | Padrão |
|------|--------|
| Pipeline CI | `azure-pipeline-ci.yml` |
| Pipeline CD | `azure-pipeline-cd.yml` |
| Diretório de config | `.azuredevops/` |

### Agent Pools

| Tipo | Pool | Uso |
|------|------|-----|
| CI | `GeneralPurposeLinuxAgentsCI` | Builds, testes, análises |
| CD | `GeneralPurposeLinuxAgentsCD` | Deploys |

### Variáveis Padrão

```yaml
variables:
  # Sigla do projeto (extraída do nome do Team Project)
  SIGLA: $[ lower(split(variables['System.TeamProject'],' ')[0]) ]
```

### Service Connections

| Serviço | Connection | Uso |
|---------|------------|-----|
| Azure Container Registry | `ACR-DEVOPS` | Push de imagens Docker |
| Azure Key Vault | `DevOpsSharedResources` | Acesso a secrets |
| SonarQube | `VIVO_SONARQUBE` | Análise de qualidade |

---

## 🔒 Segurança

### Regras Obrigatórias

1. **Nunca hardcode secrets** - Use Azure Key Vault
2. **Nunca exponha tokens em logs** - Use `isSecret: true`
3. **Sempre inclua SAST/SCA** - Templates em `/security/` ou `/framework/templates/`

### Templates de Segurança

```yaml
# SAST - Análise estática de código
- template: /framework/templates/run-sast-scan.yaml

# SCA - Análise de composição de software (incluído no docker-build-and-push)
- template: /framework/templates/docker-build-and-push.yaml

# Obter chaves de configuração do AppSec
- template: /security/get_appconfig_keys_framework.yml
```

---

## 📋 Boas Práticas

### Ao Criar Pipelines

1. **Sempre incluir README.md** com documentação completa
2. **Organizar parâmetros** em seções lógicas com comentários
3. **Usar VersionManagerVivo** para versionamento semântico
4. **Incluir flag `prValidationOnly`** para validação em PRs
5. **Usar cache** para melhorar performance

### Ao Modificar Pipelines Existentes

1. **Manter retrocompatibilidade** quando possível
2. **Atualizar README.md** se houver mudança em parâmetros
3. **Executar `make validate-pipelines`** antes do PR
4. **Ao adicionar novos parâmetros**, verificar consistência com os demais pipelines do mesmo tipo (CI ou CD) usando a Matriz de Parâmetros:
   ```bash
   make validate-custom PIPELINE=<caminho/do/pipeline.yaml> ARGS="--matrix"
   ```
   A matriz exibe quais parâmetros existem em cada pipeline — se um novo parâmetro aparecer apenas na coluna do pipeline editado, avaliar se o nome e tipo estão alinhados com o padrão existente.

### Ao Criar Tech Products

1. **Seguir padrões do framework** mesmo em customizações
2. **Documentar diferenças** em relação ao framework
3. **Assinar carta de exceção** se necessário

---

## ✅ Validação

Antes de qualquer PR, execute:

```bash
# Setup inicial (primeira vez)
make setup-complete

# Validar pipeline editado/criado
ake validate-custom PIPELINE=<caminho/do/pipeline.yaml>

# Validar todos os pipelines
make validate-pipelines

# Validar apenas CI
make validate-ci

# Validar apenas CD
make validate-cd
```

---

## 🔗 Referências

- [Guidelines de Pipelines](../GUIDELINES.md)
- [README do Framework](../framework/README.md)
- [Documentação de Validação](../framework/docs/validate.md)
- [ADRs do Framework](../framework/docs/adr/)
- [Portal CodePlay](https://dvps.redecorp.azr/portal/codeplay/framework/)
