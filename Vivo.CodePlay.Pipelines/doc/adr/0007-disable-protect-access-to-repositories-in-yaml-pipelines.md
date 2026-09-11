# 7. Desabilitação da Opção "Protect access to repositories in YAML pipelines"

Date: 2026-03-06

## Status

Accepted

## Context

O Azure DevOps oferece uma configuração de segurança chamada **"Protect access to repositories in YAML pipelines"** que, quando habilitada, exige que todos os repositórios acessados por um pipeline sejam explicitamente declarados no arquivo YAML ou aprovados manualmente através da interface web. Esta funcionalidade foi introduzida pela Microsoft para aumentar a segurança e controle sobre quais repositórios podem ser acessados durante a execução dos pipelines.

### Funcionalidade Atual

Quando a opção está **habilitada** (comportamento padrão recomendado pela Microsoft):
- Qualquer acesso a repositórios além do repositório principal requer declaração explícita no YAML através da seção `resources: repositories:`
- A primeira execução de um pipeline que acessa novos repositórios requer aprovação manual
- Personal Access Tokens (PATs) são frequentemente necessários para acessar repositórios privados
- Checkout de submódulos Git requer declaração explícita de cada submódulo como recurso

### Problemas Identificados

Nossa organização enfrenta desafios específicos com esta configuração habilitada:

#### 1. **Dependências em Projetos Flutter/Dart**
Projetos que utilizam dependências privadas hospedadas no Azure Repos enfrentam dificuldades significativas:
- `flutter pub get` falha ao tentar clonar dependências privadas de outros repositórios
- Workarounds são necessários, como manipulação direta do arquivo `.gitconfig` nos agentes
- Uso de PATs aumenta riscos de segurança (tokens com escopo amplo, expiração, rotação manual)
- Pipeline se torna frágil e difícil de manter

#### 2. **Submódulos Git**
Repositórios que utilizam submódulos Git enfrentam barreiras operacionais:
- Cada submódulo precisa ser declarado explicitamente no YAML
- Em projetos com múltiplos submódulos, o YAML fica extenso e difícil de manter
- Alterações na estrutura de submódulos requerem atualização manual dos pipelines
- Dificulta a adoção de padrões de modularização de código
- Uso de PATs aumenta riscos de segurança (tokens com escopo amplo, expiração, rotação manual)

### Hipóteses Testadas

Realizamos testes práticos para validar se desabilitar esta opção atenderia nossas necessidades sem comprometer a segurança:

#### **Hipótese 1: Acesso a Dependências Flutter/Dart**

**Objetivo:** Viabilizar `git clone` de dependências privadas sem uso de PAT

**Requisitos:**
1. System Access Token (`$(System.AccessToken)`) utilizado explicitamente na configuração do Git via variáveis de ambiente
2. Build Service User do projeto deve ter permissão de **Reader** nos projetos que hospedam os repositórios das dependências

**Implementação Validada:**

```yaml
- script: |
    export PUB_CACHE=$(Agent.ToolsDirectory)/.pub-cache
    
    # Usa System.CollectionUri para extrair a organização
    COLLECTION_URI="$(System.CollectionUri)"
    # Remove 'https://' e trailing '/'
    ORG_PATH=${COLLECTION_URI#https://}
    ORG_PATH=${ORG_PATH%/}
    
    # Extrai apenas o nome da organização
    ORG_NAME=$(echo "$ORG_PATH" | cut -d'/' -f2)
    
    echo "Collection: $COLLECTION_URI"
    echo "Organização: $ORG_NAME"
    
    # Configura Git com autenticação via System Access Token
    export GIT_CONFIG_COUNT=1
    export GIT_CONFIG_KEY_0="url.https://$(System.AccessToken)@dev.azure.com/${ORG_NAME}/.insteadOf"
    export GIT_CONFIG_VALUE_0="https://${ORG_NAME}@dev.azure.com/${ORG_NAME}/"
    
    flutter pub get --no-example
  displayName: 'Flutter Get Dependencies'
```

**Resultado:** ✅ Sucesso - Dependências clonadas sem necessidade de PAT ou modificação de `.gitconfig`

#### **Hipótese 2: Checkout de Submódulos Git**

**Objetivo:** Viabilizar checkout automático de repositórios com submódulos sem declaração explícita

**Requisitos:**
- Step de checkout com parâmetro `submodules: true`
- Build Service User com permissão de **Reader** nos repositórios dos submódulos

**Implementação Validada:**

```yaml
- checkout: self
  submodules: true
  persistCredentials: true
```

**Resultado:** ✅ Sucesso - Submódulos clonados automaticamente usando System Access Token

### Alternativas Consideradas

1. **Manter configuração atual com uso de PATs**
   - ❌ Complexidade operacional elevada
   - ❌ Riscos de segurança com gerenciamento manual de tokens
   - ❌ Quebra de pipelines por tokens expirados

2. **Declaração explícita de todos os recursos**
   - ❌ YAML extenso e difícil de manter
   - ❌ Impacto na Developer Experience
   - ❌ Dificulta automação e self-service

3. **Desabilitar a opção "Protect access to repositories in YAML pipelines"**
   - ✅ Simplifica drasticamente os pipelines
   - ✅ Remove dependência de PATs
   - ✅ Mantém segurança através de permissionamento RBAC (opção "Limit job authorization scope to current project for non-release pipelines" mantida ligada)
   - ✅ Melhora Developer Experience
   - ⚠️ Remove camada adicional de aprovação explícita

## Decision

**Decidimos desabilitar a opção "Protect access to repositories in YAML pipelines" na organização do Azure DevOps.**

### Justificativa

1. **Segurança Mantida Através de RBAC:** O controle de acesso será gerenciado através das permissões do Build Service User, que são mais granulares e auditáveis que declarações no YAML

2. **Simplicidade e Manutenibilidade:** Pipelines se tornam mais simples e fáceis de manter, alinhados com os princípios "Plug and Play" e "AI First/AI Friendly" do CodePlay Framework

3. **Eliminação de PATs:** Remove a necessidade de Personal Access Tokens para acesso a repositórios, reduzindo riscos de segurança relacionados a tokens com escopo amplo ou mal gerenciados e impacto entre pipelines que manipulam o arquivo `.gitconfig` diretamente nos agentes do Azure DevOps.

4. **Developer Experience:** Melhora a experiência dos desenvolvedores ao configurar e manter pipelines

5. **Validação Prática:** As hipóteses testadas demonstraram que a abordagem funciona adequadamente para nossos casos de uso principais

### Implementação

**Nível de Organização:**
- Desabilitar em: `Organization Settings > Pipelines > Settings > Protect access to repositories in YAML pipelines`
- Desabilitar em: `Project Settings > Pipelines > Settings > Protect access to repositories in YAML pipelines`

**Permissionamento:**
- Build Service Users devem ter permissão de **Reader** explícita nos repositórios que precisam acessar (solicitação via DevSupport no VivoNow)
- Permissões devem ser concedidas seguindo princípio de menor privilégio
- Documentar permissões necessárias nos READMEs dos pipelines que acessam múltiplos repositórios (idealmente)

**Monitoramento:**
- Implementar auditoria de acessos do Build Service via Azure DevOps API
- Criar dashboards de visualização de permissões do Build Service

## Consequences

### Impactos Positivos

1. **Simplificação de Pipelines**
   - YAMLs mais enxutos e legíveis
   - Facilita onboarding de novos desenvolvedores

2. **Eliminação de PATs**
   - Remove risco de exposição de tokens em logs ou código
   - Elimina problemas de expiração de tokens
   - Reduz overhead de gerenciamento de secrets

3. **Melhoria na Developer Experience**
   - Menos fricção no dia a dia dos desenvolvedores
   - Redução de tickets de suporte relacionados a problemas de autenticação

4. **Suporte a Submódulos Git**
   - Permite uso nativo de submódulos sem workarounds
   - Facilita modularização de código e reuso entre projetos
   - Alinha com melhores práticas de arquitetura de software

5. **Simplificação do pipeline de Dart/Flutter**
   - `flutter pub get` funciona nativamente com dependências privadas

6. **Alinhamento com Princípios do CodePlay**
   - Maior aderência ao princípio "Plug and Play"
   - Pipelines mais "AI Friendly" (menos configuração verbosa necessária)
   - Facilita automação e self-service

### Impactos Negativos / Trade-offs

1. **Remoção de Camada de Aprovação Explícita**
   - Não haverá mais prompt de aprovação para acesso a novos repositórios

2. **Dependência de Permissionamento RBAC Correto**
   - Times precisam garantir que Build Service tenha permissões apropriadas

3. **Risco de Acesso Inadvertido**
   - Build Service com permissões muito amplas pode acessar repositórios não intencionais
   - **Mitigação:** Princípio de menor privilégio estritamente aplicado
   - **Mitigação:** Revisão periódica de permissões do Build Service

4. **Mudança de Paradigma de Segurança**
   - Shift de "explicit allow no YAML" para "RBAC-based access control"
   - **Mitigação:** Comunicação clara da mudança para todos os times

5. **Auditoria Mais Complexa**
   - Acesso a repositórios não fica explícito no código do pipeline

### Reversibilidade

Se necessário, a decisão pode ser aplicada desabilitando a opção nas configurações dos projetos individualmente (para cenários necessários).

**Recomendação:** Manter desabilitado e investir em melhorias de monitoramento e auditoria.


