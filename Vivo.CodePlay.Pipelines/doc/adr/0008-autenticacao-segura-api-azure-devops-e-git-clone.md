# 8. Autenticação Segura para Acesso à API do Azure DevOps e Git Clone

Date: 2026-04-09

## Status

Accepted

## Context

Aplicações e pipelines frequentemente precisam interagir com o Azure DevOps de duas formas:

1. **API REST do Azure DevOps** — para automatizar operações como criação de work items, leitura de builds, manipulação de variáveis de pipeline, consultas de repositórios, etc.
2. **Git Clone de repositórios privados** — para clonar código, dependências ou outros repositórios hospedados no Azure Repos durante a execução de pipelines ou em runtime de aplicações.

### Métodos de Autenticação Disponíveis

O Azure DevOps suporta múltiplos métodos de autenticação. A tabela abaixo está ordenada do **mais seguro** (topo) ao **menos seguro** (base):

| # | Método | Segredos estáticos | Vinculado a usuário humano | Rotação | Isolamento |
| --- | --- | --- | --- | --- | --- |
| 1 (mais seguro) | `System.AccessToken` | Não | Não | Automática | Por job |
| 2 | AAD Workload Identity | Não | Não | Automática | Por pod (Kubernetes) |
| 3 | Managed Identity | Não | Não | Automática | Por recurso Azure |
| 4 | Workload Identity Federation (OIDC) | Não | Não | Automática | Por app |
| 5 | Service Principal + Certificate | Sim (certificado) | Não | Manual | Por app |
| 6 | Service Principal + Client Secret | Sim (senha) | Não | Manual | Por app |
| 7 (menos seguro) | PAT (Personal Access Token) | Sim (token) | Sim | Manual | Configurável |

### Problemas com Abordagens Inseguras

**PATs vinculados a usuários humanos:**
- Expiram e quebram pipelines quando o token vence
- Têm escopo frequentemente mais amplo do que o necessário
- Quando o funcionário sai, os tokens ficam órfãos ou precisam ser transferidos
- Difíceis de rastrear e auditar em escala

**Service Principal com Client Secret:**
- Segredo em texto que precisa ser armazenado e rotacionado manualmente
- Risco de exposição em logs, variáveis de ambiente ou código
- Sem rotação automática — secrets esquecidos acumulam risco

**Managed Identity em nível de nó no AKS:**
- Qualquer pod no nó pode obter um token chamando o endpoint IMDS (`169.254.169.254`)
- Não há isolamento entre diferentes aplicações rodando no mesmo nó
- Um pod comprometido pode se autenticar com a identidade de outro

### Necessidade

Precisamos definir um padrão claro que:
- Elimine segredos estáticos de código e variáveis de ambiente
- Forneça isolamento adequado de identidade por workload
- Minimize a superfície de ataque em todos os contextos de execução

## Decision

**Adotamos uma hierarquia de métodos de autenticação baseada no contexto de execução.**

A escolha do método segue a ordem de preferência abaixo. Utilize sempre o método mais alto da lista que for aplicável ao seu contexto.

---

### Nível 1 — Pipelines Azure DevOps: `System.AccessToken`

Para qualquer operação de API ou git clone que ocorra **dentro de um pipeline Azure DevOps**, use exclusivamente o `System.AccessToken`.

**Por quê:** É um token efêmero gerado automaticamente pela plataforma, scoped ao job em execução, sem necessidade de configuração ou rotação. Não é vinculado a nenhum usuário humano.

**Pré-requisito:** O Build Service User do projeto deve ter as permissões mínimas necessárias nos repositórios ou recursos acessados (ver ADR-0007).

**Exemplos de uso:**

#### Git clone via Bearer Token

```yaml
- bash: |
    git -c http.extraHeader="Authorization: Bearer $SYSTEM_ACCESSTOKEN" \
        clone https://dev.azure.com/$(System.TeamFoundationCollectionUri#*/)/<projeto>/_git/<repositorio>
  displayName: 'Clone repositório privado'
  env:
    SYSTEM_ACCESSTOKEN: $(System.AccessToken)
```

#### Git clone com rewrite de URL (para dependências de package managers)

```yaml
- bash: |
    COLLECTION_URI="$(System.CollectionUri)"
    ORG_PATH=${COLLECTION_URI#https://}
    ORG_PATH=${ORG_PATH%/}
    ORG_NAME=$(echo "$ORG_PATH" | cut -d'/' -f2)

    export GIT_CONFIG_COUNT=1
    export GIT_CONFIG_KEY_0="url.https://$(System.AccessToken)@dev.azure.com/${ORG_NAME}/.insteadOf"
    export GIT_CONFIG_VALUE_0="https://${ORG_NAME}@dev.azure.com/${ORG_NAME}/"

    # Agora qualquer git clone ou package manager (pip, npm, maven) que use Azure Repos
    # será autenticado automaticamente sem necessidade de PAT
  displayName: 'Configurar autenticação Git via System.AccessToken'
  env:
    SYSTEM_ACCESSTOKEN: $(System.AccessToken)
```

> **Nota:** Não armazene `$(System.AccessToken)` em variáveis de pipeline comuns. Passe sempre via `env:` para evitar exposição em logs.

#### Checkout com submódulos

```yaml
- checkout: self
  submodules: true
  persistCredentials: true
```

#### Chamada à API REST do Azure DevOps

```yaml
- bash: |
    curl -s \
      -H "Authorization: Bearer $SYSTEM_ACCESSTOKEN" \
      -H "Content-Type: application/json" \
      "https://dev.azure.com/$(System.TeamFoundationCollectionUri)/_apis/build/builds?api-version=7.1"
  displayName: 'Consulta à API do Azure DevOps'
  env:
    SYSTEM_ACCESSTOKEN: $(System.AccessToken)
```

---

### Nível 2 — Aplicações no AKS: AAD Workload Identity

Para aplicações rodando em **Azure Kubernetes Service (AKS)** que precisam chamar a API do Azure DevOps ou fazer git clone em runtime, use **AAD Workload Identity**.

**Por quê:** Resolve o problema de isolamento do Managed Identity em nível de nó. Apenas pods com a Kubernetes Service Account anotada corretamente recebem tokens — outros pods no mesmo nó **não têm acesso**.

**Como funciona:**

```
Pod com ServiceAccount anotada ──► OIDC token ──► Azure AD ──► token de MI
Pod sem anotação / label        ──► NEGADO
```

**Configuração:**

```yaml
# 1. Kubernetes Service Account anotada com o clientId da Managed Identity
apiVersion: v1
kind: ServiceAccount
metadata:
  name: minha-app-sa
  namespace: minha-app
  annotations:
    azure.workload.identity/client-id: "<client-id-da-managed-identity>"
---
# 2. Pod com o label de injeção e a ServiceAccount correta
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    metadata:
      labels:
        azure.workload.identity/use: "true"   # habilita injeção automática do token
    spec:
      serviceAccountName: minha-app-sa
      containers:
        - name: minha-app
          image: minha-imagem:latest
```

**Uso no código da aplicação (Python):**

```python
from azure.identity import WorkloadIdentityCredential
from azure.devops.connection import Connection
from msrest.authentication import BasicTokenAuthentication

credential = WorkloadIdentityCredential()
token = credential.get_token("499b84ac-1321-427f-aa17-267ca6975798/.default")

auth = BasicTokenAuthentication({"access_token": token.token})
connection = Connection(
    base_url="https://dev.azure.com/telefonica-vivo-brasil",
    creds=auth
)
```

**Uso no código da aplicação (git clone):**

```python
import subprocess
from azure.identity import WorkloadIdentityCredential

credential = WorkloadIdentityCredential()
token = credential.get_token("499b84ac-1321-427f-aa17-267ca6975798/.default")

subprocess.run([
    "git", "-c", f"http.extraHeader=Authorization: Bearer {token.token}",
    "clone", "https://dev.azure.com/telefonica-vivo-brasil/<projeto>/_git/<repo>"
], check=True)
```

**Pré-requisitos de infraestrutura:**
1. AKS com OIDC Issuer habilitado
2. Managed Identity criada e com as permissões necessárias no Azure DevOps
3. Federated credential configurada no Azure AD linkando o OIDC issuer do AKS com o namespace/service account do Kubernetes

---

### Nível 3 — Aplicações em Outros Recursos Azure: Managed Identity (System-assigned)

Para aplicações rodando em **VMs, App Service, Azure Functions, Container Apps** (fora do AKS), use **System-assigned Managed Identity**.

**Por quê:** Nesses ambientes o isolamento por recurso é garantido pela plataforma — cada recurso tem sua própria identidade. Não há o problema de compartilhamento de nó do AKS.

```python
from azure.identity import ManagedIdentityCredential

credential = ManagedIdentityCredential()
token = credential.get_token("499b84ac-1321-427f-aa17-267ca6975798/.default")
```

**Permissões no Azure DevOps:** A Managed Identity precisa ser adicionada como membro com permissões adequadas no projeto ou organização do Azure DevOps.

---

### Nível 4 — Aplicações Fora do Azure: Workload Identity Federation (OIDC)

Para aplicações rodando em **outras plataformas** (GitHub Actions, GitLab CI, outros clouds), use **Workload Identity Federation**.

**Por quê:** Elimina client secrets estáticos substituindo-os por tokens OIDC efêmeros emitidos pelo provedor de identidade da plataforma origem.

---

### Nível 5 — Último Recurso: Service Principal + Certificate no Key Vault

Quando nenhuma opção acima for viável, use um Service Principal autenticado por **certificado** (nunca client secret), com o certificado armazenado no **Azure Key Vault** (`kv-azdevops-shared`).

```yaml
# Recuperar certificado do Key Vault no pipeline e usá-lo para autenticar
- task: AzureKeyVault@2
  inputs:
    azureSubscription: 'DevOpsSharedResources'
    KeyVaultName: 'kv-azdevops-shared'
    SecretsFilter: 'minha-app-certificate'
```

---

### O que NUNCA fazer

| Prática proibida | Motivo |
|---|---|
| PAT em variável de pipeline ou código | Vinculado a usuário humano, expira, amplo escopo |
| Client Secret do Service Principal em código | Segredo estático, risco de exposição em logs |
| `System.AccessToken` em variável comum (não `env:`) | Pode aparecer em logs do pipeline |
| Managed Identity de nó compartilhado no AKS sem Workload Identity | Qualquer pod no nó pode obter o token |
| Hardcode de qualquer credencial em YAML ou código | Risco crítico de exposição via git history |

---

### Quadro-resumo de Decisão

| Contexto de execução | Método recomendado |
|---|---|
| Pipeline Azure DevOps | `System.AccessToken` via `env:` |
| Aplicação em AKS | AAD Workload Identity (por pod/ServiceAccount) |
| VM / App Service / Functions / Container Apps | System-assigned Managed Identity |
| GitHub Actions / GitLab / outro cloud | Workload Identity Federation (OIDC) |
| Nenhuma opção acima possível | Service Principal + Certificate no Key Vault |

## Consequences

### Impactos Positivos

1. **Eliminação de segredos estáticos**
   - Nenhum token ou senha armazenado em variáveis de pipeline, repositórios ou código
   - Remove risco de exposição via git history ou logs de pipeline

2. **Rotação automática de credenciais**
   - `System.AccessToken` é gerado a cada execução
   - Tokens de MI e Workload Identity têm TTL curto e são renovados automaticamente

3. **Princípio de menor privilégio aplicável com granularidade**
   - Workload Identity permite escopo de identidade por pod/aplicação
   - `System.AccessToken` é scoped ao projeto e ao job

4. **Sem dependência de usuários humanos**
   - Pipelines não quebram quando um funcionário sai ou troca de equipe
   - Auditoria clara de "qual serviço fez o quê" no Azure AD

5. **Conformidade e rastreabilidade**
   - Todas as autenticações são rastreáveis no Azure AD e Azure DevOps Audit Log

### Impactos Negativos / Trade-offs

1. **Complexidade inicial de configuração do Workload Identity no AKS**
   - Requer OIDC Issuer habilitado no cluster
   - Configuração de federated credentials no Azure AD
   - **Mitigação:** Configuração é feita uma vez pelo time de infraestrutura e reutilizada

2. **Permissões do Build Service precisam ser gerenciadas explicitamente**
   - Times precisam solicitar permissões de Reader para o Build Service nos repositórios necessários (via DevSupport no VivoNow)
   - **Mitigação:** Processo documentado no ADR-0007

3. **Dependência da Managed Identity ter as permissões corretas no Azure DevOps**
   - A MI precisa ser adicionada como membro no projeto do Azure DevOps com as permissões adequadas
   - **Mitigação:** Processo de onboarding documentado e automatizável via API

### Riscos Identificados

| Risco | Probabilidade | Impacto | Mitigação |
|---|---|---|---|
| MI com permissões excessivas no Azure DevOps | Média | Alto | Revisar permissões via princípio de menor privilégio |
| `System.AccessToken` exposto em log de pipeline | Baixa | Alto | Sempre passar via `env:`, nunca em `echo` ou variável comum |
| Workload Identity mal configurada (sem label no pod) | Média | Médio | Adicionar validação no processo de deploy |
| Service Principal com certificate expirado (nível 5) | Média | Alto | Alertas de expiração no Key Vault + renovação automatizada |

### Dependências

- [ ] Times de infraestrutura habilitarem OIDC Issuer no AKS para uso do Workload Identity
- [ ] Processo de solicitação de permissão para Managed Identity no Azure DevOps (via DevSupport)
- [ ] Atualização das pipelines existentes que ainda usam PAT para `System.AccessToken`

## Referências

- [ADR-0007 — Desabilitação de "Protect access to repositories in YAML pipelines"](0007-disable-protect-access-to-repositories-in-yaml-pipelines.md)
- [Microsoft: Workload Identity Federation](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation)
- [Microsoft: AAD Workload Identity no AKS](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview)
- [Azure DevOps: Autenticação com System.AccessToken](https://learn.microsoft.com/en-us/azure/devops/pipelines/build/variables?view=azure-devops#systemaccesstoken)
- [Scope do System.AccessToken — configuração de permissões](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/access-tokens)
- [Azure DevOps REST API — autenticação via OAuth](https://learn.microsoft.com/en-us/azure/devops/integrate/get-started/authentication/oauth)
- [Azure DevOps: migração de autenticação legada para Microsoft Entra ID](https://learn.microsoft.com/en-us/azure/devops/integrate/get-started/authentication/entra?view=azure-devops#migration-from-legacy-authentication)
