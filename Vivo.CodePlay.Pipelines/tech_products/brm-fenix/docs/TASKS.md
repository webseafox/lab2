# Referência de Tasks - BRM Fenix

> **Documentação completa de todas as tasks e task groups do framework BRM Fenix**

## 📋 Índice

- [Task Groups](#task-groups)
- [Atomic Tasks](#atomic-tasks)
- [Build Tasks](#build-tasks)
- [Deploy Tasks](#deploy-tasks)
- [OCI Tasks](#oci-tasks)
- [SSH Tasks](#ssh-tasks)
- [Validation Tasks](#validation-tasks)
- [Referência Rápida](#referência-rápida)

---

## 📦 Task Groups

Task Groups são conjuntos reutilizáveis de tasks que implementam funcionalidades complexas.

### OCI Configuration

**Arquivo:** `task_groups/oci_configuration.yml`

**Propósito:** Configura OCI CLI com secure files (config + API key) e valida conexão.

#### Tasks Incluídas

```yaml
- task: DownloadSecureFile@1  # Download oci_config_brm_fenix
- task: DownloadSecureFile@1  # Download oci_api_key_brm_fenix.pem
- template: tasks/oci/configure_oci_cli.yml
- script: oci --version  # Validate installation
```

#### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `ociConfigSecureFileName` | string | ✅ | Nome do secure file do config (ex: `oci_config_brm_fenix`) |
| `ociKeySecureFileName` | string | ✅ | Nome do secure file da API key (ex: `oci_api_key_brm_fenix.pem`) |
| `ociConfigPath` | string | ❌ | Caminho de destino do config (default: `~/.oci_fenix/config`) |

#### Variáveis de Saída

- `OCI_CLI_CONFIG_FILE` - Caminho completo do arquivo de config
- `OCI_CLI_KEY_FILE` - Caminho completo da API key

#### Exemplo de Uso

```yaml
- template: task_groups/oci_configuration.yml
  parameters:
    ociConfigSecureFileName: 'oci_config_brm_fenix'
    ociKeySecureFileName: 'oci_api_key_brm_fenix.pem'
```

#### Estrutura de Arquivos

```bash
~/.oci_fenix/
├── config              # OCI CLI config file
└── api_key.pem         # Private API key (chmod 600)
```

#### Conteúdo do Config File

```ini
[DEFAULT]
user=ocid1.user.oc1..xxx
fingerprint=xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx
tenancy=ocid1.tenancy.oc1..xxx
region=sa-saopaulo-1
key_file=/home/vsts/.oci_fenix/api_key.pem
oci_version=3.71.0
```

---

## ⚙️ Atomic Tasks

### Build Tasks

#### Maven Build

**Arquivo:** `tasks/build/maven_build.yml`

**Propósito:** Compila projeto Java com Maven.

##### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `mavenPomFile` | string | ✅ | Caminho do `pom.xml` |
| `mavenGoals` | string | ❌ | Goals Maven (default: `clean package`) |
| `mavenOptions` | string | ❌ | Opções adicionais (ex: `-DskipTests`) |

##### Exemplo

```yaml
- template: tasks/build/maven_build.yml
  parameters:
    mavenPomFile: 'pom.xml'
    mavenGoals: 'clean package'
    mavenOptions: '-DskipTests -Drevision=$(VERSION)'
```

---

### Deploy Tasks

#### Helm Deploy

**Arquivo:** `tasks/deploy/helm_deploy.yml`

**Propósito:** Deploy de aplicação via Helm no Kubernetes.

##### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `helmChartPath` | string | ✅ | Caminho do Helm Chart |
| `releaseName` | string | ✅ | Nome do release Helm |
| `namespace` | string | ✅ | Namespace Kubernetes |
| `values` | string | ❌ | Values adicionais (--set) |
| `valuesFile` | string | ❌ | Arquivo values.yaml customizado |

##### Exemplo

```yaml
- template: tasks/deploy/helm_deploy.yml
  parameters:
    helmChartPath: './helm/brm-app'
    releaseName: 'brm-hml'
    namespace: 'brm'
    values: 'image.tag=$(DOCKER_IMAGE_TAG)'
```

#### SSH Deploy

**Arquivo:** `tasks/ssh/deploy.yml`

**Propósito:** Deploy via SSH em bastion host.

##### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `sshHost` | string | ✅ | Host do bastion |
| `sshUser` | string | ✅ | Usuário SSH |
| `sshKey` | string | ✅ | Nome do secure file da chave SSH |
| `commands` | string | ✅ | Comandos a executar (multiline) |
| `workingDirectory` | string | ❌ | Diretório de trabalho remoto |

##### Exemplo

```yaml
- template: tasks/ssh/deploy.yml
  parameters:
    sshHost: '$(BASTION_HOST)'
    sshUser: 'opc'
    sshKey: 'ssh_key_bastion_brm_fenix'
    commands: |
      kubectl get pods -n brm
      kubectl apply -f deployment.yaml
```

---

### OCI Tasks

#### Get Cluster Info

**Arquivo:** `tasks/oci/get_cluster_info.yml`

**Propósito:** Obtém informações do cluster OKE via OCI CLI.

##### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `clusterId` | string | ✅ | OCID do cluster OKE |
| `outputVariable` | string | ❌ | Nome da variável de saída (default: `CLUSTER_INFO`) |

##### Variáveis de Saída

- `CLUSTER_NAME` - Nome do cluster
- `CLUSTER_STATE` - Estado do cluster (ACTIVE, INACTIVE, etc.)
- `KUBERNETES_VERSION` - Versão do Kubernetes
- `ENDPOINT` - Endpoint do API Server

##### Exemplo

```yaml
- template: tasks/oci/get_cluster_info.yml
  parameters:
    clusterId: '$(OKE_CLUSTER_ID)'
```

#### Get Node Pool Info

**Arquivo:** `tasks/oci/get_node_pool_info.yml`

**Propósito:** Obtém informações do node pool via OCI CLI.

##### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `nodePoolId` | string | ✅ | OCID do node pool |

##### Variáveis de Saída

- `NODE_POOL_NAME` - Nome do node pool
- `NODE_POOL_STATE` - Estado do node pool
- `NODE_COUNT` - Quantidade de nodes
- `NODE_SHAPE` - Shape dos nodes (ex: `VM.Standard.E4.Flex`)

##### Exemplo

```yaml
- template: tasks/oci/get_node_pool_info.yml
  parameters:
    nodePoolId: '$(OKE_NODE_POOL_ID)'
```

#### Get Nodes

**Arquivo:** `tasks/oci/get_nodes.yml`

**Propósito:** Lista todos os nodes do compartment e filtra por node pool.

##### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `compartmentId` | string | ✅ | OCID do compartment |
| `nodePoolName` | string | ✅ | Nome do node pool para filtrar |

##### Variáveis de Saída

- `NODES_JSON` - JSON com lista de nodes
- `NODES_RUNNING` - IDs dos nodes em estado RUNNING
- `NODES_STOPPED` - IDs dos nodes em estado STOPPED
- `TOTAL_NODES` - Total de nodes encontrados

##### Exemplo

```yaml
- template: tasks/oci/get_nodes.yml
  parameters:
    compartmentId: '$(OCI_COMPARTMENT_ID)'
    nodePoolName: 'oke-node-pool-brm-hml'
```

#### Configure OCI CLI

**Arquivo:** `tasks/oci/configure_oci_cli.yml`

**Propósito:** Configura OCI CLI com arquivos de config e API key.

##### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `ociConfigFile` | string | ✅ | Caminho do arquivo de config baixado |
| `ociKeyFile` | string | ✅ | Caminho da API key baixada |
| `ociConfigDestination` | string | ❌ | Destino final (default: `~/.oci_fenix/config`) |

##### Ações Executadas

1. Cria diretório `~/.oci_fenix/`
2. Move arquivos para destino
3. Atualiza `key_file` no config com caminho absoluto
4. Define `oci_version=3.71.0`
5. Executa `oci setup repair-file-permissions` (chmod 600 na key)

##### Exemplo

```yaml
- template: tasks/oci/configure_oci_cli.yml
  parameters:
    ociConfigFile: '$(ociConfig.secureFilePath)'
    ociKeyFile: '$(ociKey.secureFilePath)'
```

---

### SSH Tasks

#### SSH Execute

**Arquivo:** `tasks/ssh/execute.yml`

**Propósito:** Executa comandos via SSH em host remoto.

##### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `host` | string | ✅ | Hostname ou IP |
| `user` | string | ✅ | Usuário SSH |
| `keyFile` | string | ✅ | Caminho da chave privada |
| `commands` | string | ✅ | Comandos a executar (multiline) |
| `continueOnError` | boolean | ❌ | Continuar em caso de erro (default: `false`) |

##### Exemplo

```yaml
- template: tasks/ssh/execute.yml
  parameters:
    host: '10.0.1.5'
    user: 'opc'
    keyFile: '$(sshKey.secureFilePath)'
    commands: |
      echo "Deploying BRM..."
      cd /app/brm
      ./deploy.sh $(VERSION)
```

---

### Validation Tasks

#### Check Errors

**Arquivo:** `tasks/validation/check_errors.yml`

**Propósito:** Verifica erros no output de comandos anteriores.

##### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `logContent` | string | ✅ | Conteúdo do log a analisar |
| `errorPatterns` | string | ❌ | Padrões de erro (regex, um por linha) |
| `failOnError` | boolean | ❌ | Falhar pipeline se erro encontrado (default: `true`) |

##### Padrões de Erro Padrão

```regex
ERROR
FATAL
Exception
Failed
Error:
\[ERROR\]
```

##### Exemplo

```yaml
- script: |
    kubectl logs deployment/brm -n brm > deploy.log
  displayName: 'Get Deployment Logs'

- template: tasks/validation/check_errors.yml
  parameters:
    logContent: '$(cat deploy.log)'
    errorPatterns: |
      ORA-\d+
      java.lang.OutOfMemoryError
      Connection refused
```

#### Validate Version

**Arquivo:** `tasks/validation/validate_version.yml`

**Propósito:** Valida que a versão deployada corresponde à esperada.

##### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `expectedVersion` | string | ✅ | Versão esperada (ex: `1.2.3`) |
| `versionCheckCommand` | string | ✅ | Comando para obter versão deployada |
| `versionRegex` | string | ❌ | Regex para extrair versão do output |

##### Exemplo

```yaml
- template: tasks/validation/validate_version.yml
  parameters:
    expectedVersion: '$(VERSION)'
    versionCheckCommand: 'curl http://brm-hml.vivo.com/version'
    versionRegex: '"version":\s*"([^"]+)"'
```

#### Verify BRM Apps

**Arquivo:** `tasks/validation/verify_brm_apps.yml`

**Propósito:** Verifica health de todas as aplicações BRM deployadas.

##### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `namespace` | string | ✅ | Namespace Kubernetes |
| `applications` | string | ✅ | Lista de aplicações (yaml list) |
| `timeout` | string | ❌ | Timeout por aplicação (default: `5m`) |

##### Exemplo

```yaml
- template: tasks/validation/verify_brm_apps.yml
  parameters:
    namespace: 'brm'
    applications: |
      - brm-cm
      - brm-dm
      - brm-gateway
      - brm-batch
    timeout: '10m'
```

##### Validações Executadas

1. ✅ Deployment existe
2. ✅ Pods estão em estado `Running`
3. ✅ Réplicas desejadas == réplicas prontas
4. ✅ Health check endpoint responde 200
5. ✅ Versão deployada corresponde à esperada

---

## 📊 Referência Rápida

### Task Groups

| Task Group | Arquivo | Propósito | Tempo Médio |
|------------|---------|-----------|-------------|
| OCI Configuration | `task_groups/oci_configuration.yml` | Setup OCI CLI | 10-15s |

### Build Tasks

| Task | Arquivo | Propósito | Tempo Médio |
|------|---------|-----------|-------------|
| Maven Build | `tasks/build/maven_build.yml` | Compilação Java | 2-5 min |

### Deploy Tasks

| Task | Arquivo | Propósito | Tempo Médio |
|------|---------|-----------|-------------|
| Helm Deploy | `tasks/deploy/helm_deploy.yml` | Deploy via Helm | 30s-2 min |
| SSH Deploy | `tasks/ssh/deploy.yml` | Deploy via SSH | 1-5 min |

### OCI Tasks

| Task | Arquivo | Propósito | Tempo Médio |
|------|---------|-----------|-------------|
| Get Cluster Info | `tasks/oci/get_cluster_info.yml` | Informações do OKE | 5-10s |
| Get Node Pool Info | `tasks/oci/get_node_pool_info.yml` | Informações do Node Pool | 5-10s |
| Get Nodes | `tasks/oci/get_nodes.yml` | Lista nodes do compartment | 10-20s |
| Configure OCI CLI | `tasks/oci/configure_oci_cli.yml` | Setup OCI CLI | 5s |

### SSH Tasks

| Task | Arquivo | Propósito | Tempo Médio |
|------|---------|-----------|-------------|
| SSH Execute | `tasks/ssh/execute.yml` | Execução remota via SSH | Variável |

### Validation Tasks

| Task | Arquivo | Propósito | Tempo Médio |
|------|---------|-----------|-------------|
| Check Errors | `tasks/validation/check_errors.yml` | Análise de logs | 5-10s |
| Validate Version | `tasks/validation/validate_version.yml` | Validação de versão | 10-30s |
| Verify BRM Apps | `tasks/validation/verify_brm_apps.yml` | Health check de apps | 1-5 min |

---

## 🔗 Dependências Entre Tasks

```
┌──────────────────────────────────────────────────────────────────────┐
│                   PRÉ-REQUISITOS GLOBAIS                             │
│                                                                       │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │
│  │ Variable Groups  │  │ Secure Files     │  │ Service          │  │
│  │ Configurados     │  │ Baixados         │  │ Connections      │  │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘  │
└───────────┼──────────────────────┼──────────────────────┼────────────┘
            │                      │                      │
            └──────────┬───────────┴──────────────────────┘
                       ↓
┌──────────────────────────────────────────────────────────────────────┐
│                   OCI CONFIGURATION FLOW                             │
│                                                                       │
│  1. Download Secure Files                                           │
│          ↓                                                            │
│  2. Configure OCI CLI                                               │
│          ↓                                                            │
│  3. Get Cluster Info                                                │
│          ↓                                                            │
│  4. Get Node Pool Info                                              │
│          ↓                                                            │
│  5. Get Nodes                                                        │
│                                                                       │
└───────────────────────────────┬───────────────────────────────────────┘
                                │
            ┌───────────────────┴────────────────┐
            │                                    │
            ↓                                    ↓
┌────────────────────────────┐      ┌────────────────────────────────┐
│      BUILD FLOW            │      │      DEPLOY FLOW               │
│                            │      │                                │
│  1. Maven Build            │      │  1. Helm Deploy / SSH Deploy   │
│          ↓                 │      │          ↓                     │
│  2. Bundle Artifacts       │      │  2. Validate Version           │
│                            │      │          ↓                     │
└────────────┬───────────────┘      │  3. Verify BRM Apps            │
             │                      │                                │
             │                      │                                │
             └──────────────────────┴────────────────────────────────┘
```

---

## 📝 Convenções de Nomenclatura

### Parâmetros

- **CamelCase** para parâmetros de template: `helmChartPath`, `releaseName`
- **UPPERCASE_SNAKE_CASE** para variáveis de ambiente: `OCI_COMPARTMENT_ID`, `ENV_NAME_UPPER`

### Variáveis de Saída

- **UPPERCASE_SNAKE_CASE** para outputs globais: `CLUSTER_NAME`, `NODES_RUNNING`
- Prefixar com escopo quando necessário: `PIPELINE_RESULT`, `DEPLOY_APPROVAL_STATUS`

### Display Names

- **Emoji + Descrição Clara**: `🚀 Deploy via Helm`, `✅ Validate Version`
- Verbos de ação: `Configure`, `Deploy`, `Validate`, `Execute`

---

## 🛠️ Desenvolvimento de Novas Tasks

### Template de Task Básica

```yaml
# tasks/categoria/nome_da_task.yml
parameters:
  - name: parametroObrigatorio
    type: string
  
  - name: parametroOpcional
    type: string
    default: 'valor_padrao'

steps:
  - script: |
      echo "##[section]🚀 Nome da Task"
      echo "##[group]📋 Parâmetros Recebidos"
      echo "Parâmetro Obrigatório: ${{ parameters.parametroObrigatorio }}"
      echo "Parâmetro Opcional: ${{ parameters.parametroOpcional }}"
      echo "##[endgroup]"
      
      echo "##[group]⚙️ Executando Tarefa"
      # Lógica principal aqui
      echo "##[endgroup]"
      
      echo "##[group]✅ Resultado"
      echo "Task concluída com sucesso"
      echo "##[endgroup]"
    displayName: '🚀 Nome da Task'
    env:
      VAR_AMBIENTE: ${{ parameters.parametroObrigatorio }}
```

### Checklist para Nova Task

- [ ] **Documentação clara** nos parâmetros
- [ ] **Validação de inputs** obrigatórios
- [ ] **Logs estruturados** com emojis e grupos
- [ ] **Error handling** adequado
- [ ] **Variáveis de saída** documentadas
- [ ] **Exemplo de uso** incluído
- [ ] **Testada** em pipeline real
- [ ] **Adicionada** neste documento de referência

---

## 📚 Recursos Adicionais

- [Azure DevOps Task Reference](https://learn.microsoft.com/azure/devops/pipelines/tasks/reference/)
- [OCI CLI Command Reference](https://docs.oracle.com/iaas/tools/oci-cli/latest/oci_cli_docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes API Reference](https://kubernetes.io/docs/reference/)

---

**Última Atualização:** 2 de Janeiro de 2026  
**Versão:** 1.1.0  
**Mantido por:** BRM Fenix DevOps Team
