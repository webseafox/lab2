# Update K8s Docker Secret Pipeline

## Descrição

Pipeline para atualizar secrets do Docker Registry em clusters Kubernetes. Este template automatiza a criação/atualização de secrets do tipo `docker-registry` necessários para o pull de imagens de registries privados (ACR ou Nexus).

Funcionalidades:

- **Criar ou atualizar** secrets de autenticação do Docker Registry em namespaces Kubernetes
- **Suporta múltiplos registries**: Azure Container Registry (ACR) ou Nexus
- **Flexibilidade de conexão**: Via kubeconfig ou Service Connection do Azure

## Parâmetros

| Parâmetro | Tipo | Padrão | Valores | Descrição |
|-----------|------|--------|---------|-----------|
| `dockerRegistry` | string | `ACR` | `ACR`, `Nexus` | Registry de origem das credenciais |
| `connectionType` | string | `kubeconfig` | `kubeconfig`, `serviceConnection` | Tipo de conexão com o cluster K8s |
| `kubeconfig` | string | `none` | `kube-dev`, `kube-esteira1`, `kube-esteira2`, etc. | Nome do arquivo kubeconfig (quando connectionType = kubeconfig) |
| `namespace` | string | - | - | Namespace do Kubernetes onde criar o secret |
| `environment` | string | `dev` | `dev`, `esteira1`, `esteira2`, `preprod`, `prodlike`, `producao` | Ambiente de destino |

## Como Usar

### 1. Via Kubeconfig

```yaml
- template: tech_products/dvps/update-k8s-docker-secret/entrypoint.yaml
  parameters:
    dockerRegistry: 'ACR'  # ou 'Nexus'
    connectionType: 'kubeconfig'
    kubeconfig: 'meu-cluster-kubeconfig'  # nome do secure file
    namespace: 'meu-namespace'
    environment: 'dev'
```

### 2. Via Service Connection (Azure)

```yaml
- template: tech_products/dvps/update-k8s-docker-secret/entrypoint.yaml
  parameters:
    dockerRegistry: 'ACR'
    connectionType: 'serviceConnection'
    namespace: 'meu-namespace'
    environment: 'dev'
```

## Pré-requisitos

### Para connectionType: 'kubeconfig'
- Arquivo kubeconfig configurado como **Secure File** no Azure DevOps

### Para connectionType: 'serviceConnection'
- Service Connection do Azure configurado
- Variáveis obrigatórias definidas:
  - `azureKubernetesClusterPrefix`
  - `azureResourceGroupPrefix`
  - `azureServiceConnectionPrefix`

## Funcionamento

1. **Validação**: Verifica se os parâmetros de conexão estão corretos
3. **Conexão**: Estabelece conexão com o cluster K8s
4. **Secret**: Cria/atualiza o secret do tipo `docker-registry`

## Exemplo Prático

```yaml
trigger: none

parameters:
  - name: dockerRegistry
    displayName: 'Docker Registry'
    type: string
    default: 'ACR'
    values:
      - 'ACR'
      - 'Nexus'
  - name: connectionType
    displayName: "Connection type"
    type: string
    default: 'kubeconfig'
    values:
      - 'kubeconfig'
      - 'serviceConnection'
  - name: kubeconfig
    displayName: "Kubeconfig"
    type: string
    default: none
    values:
      - none
      - kube-dev
      - kube-esteira1
      - kube-esteira2
      - kube-preprod
      - kube-preprod-devops
      - kube-prodlike
      - kube-producao
      - kube-development
      - kube-homologation
      - kube-production
  - name: namespace
    displayName: "Namespace K8s"
    type: string
  - name: environment
    displayName: "Environment"
    type: string
    default: dev
    values:
      - dev
      - esteira1
      - esteira2
      - preprod
      - prodlike
      - producao

resources:
  repositories:
    - repository: VivoCodePlay
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: refs/heads/master
      endpoint: CodePlay

extends:
  template: /tech_products/dvps/update-k8s-docker-secret/entrypoint.yaml@VivoCodePlay
  parameters:
    dockerRegistry: ${{ parameters.dockerRegistry }}
    connectionType: ${{ parameters.connectionType }}
    kubeconfig: ${{ parameters.kubeconfig }}
    namespace: ${{ parameters.namespace }}
    environment: ${{ parameters.environment }}
```
