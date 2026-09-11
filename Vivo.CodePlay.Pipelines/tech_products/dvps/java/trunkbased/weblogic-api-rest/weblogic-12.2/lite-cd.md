# Documentação da Pipeline `lite-cd.yaml` - WebLogic API REST

## Visão Geral

Esta pipeline automatiza o processo de deploy contínuo (CD) simplificado para aplicações WebLogic API REST, focando em deploys rápidos e eficientes através de APIs REST do WebLogic 12.2. O pipeline utiliza uma abordagem "lite" eliminando a necessidade de SSH e transferência de arquivos, realizando todo o processo via APIs do WebLogic Server.

---

## Parâmetros

- `environment`: Ambiente de destino para deploy (ex: dev, qa, producao).
- `packageVersion`: Versão específica do pacote Maven a ser implantado.
- `packageName`: Nome do pacote Maven.
- `appName`: Nome da aplicação no WebLogic. Este nome será usado para identificar a aplicação durante operações de undeploy e deploy.

---

## Estrutura de Stages e Jobs

### Stage: `cd_deploy`

Responsável por todo o fluxo de deploy simplificado, executado em um único job de deployment:

#### 1. Job: `deploy`

- **Checkout do código-fonte**.
- **Download do artefato Maven** do Azure Artifacts usando nome do pacote.
- **Limpeza e preparação do artefato**:
  - Remoção de arquivos desnecessários.
  - Identificação do arquivo principal de deploy (.ear, .jar, .ejb).
- **Configuração do ambiente WebLogic**:
  - Leitura de configurações específicas do ambiente.
  - Validação de credenciais e conectividade.
- **Execução do fluxo de deploy**:
  - Inicialização dos servidores WebLogic.
  - Undeploy de versões antigas da aplicação.
  - Deploy da nova versão.

---

## Principais Tarefas e Templates

- **DownloadPackage@1**: Download de artefatos Maven do Azure Artifacts feed 'DevOps' usando nome do pacote.
- **CmdLine@2**: Limpeza de arquivos desnecessários, mantendo apenas extensões válidas (.ear, .jar, .ejb, *web).
- **Bash@3**: Identificação dinâmica do arquivo principal de artefato.
- **YamlParseFromVivo@4**: Parsing de configurações WebLogic específicas do ambiente.
- **StartServers.yml**: Template para inicialização de servidores WebLogic.
- **UndeployAppRetired.yml**: Template para remoção de aplicações.
- **HotDeployApp.yml**: Template para deploy da nova versão da aplicação.

---

## Variáveis Importantes

### Variáveis de Grupo
- `lib-weblogic`: Grupo de variáveis contendo configurações globais do WebLogic.

### Variáveis do Ambiente (weblogic.yml)
- `WEBLOGIC_ADMIN_SERVER_URL`: URL do servidor de administração WebLogic.
- `WEBLOGIC_USER`: Usuário administrativo do WebLogic.
- `WEBLOGIC_PASS`: Senha do usuário administrativo (tratada como secret).
- `WEBLOGIC_CLUSTER`: Nome do cluster WebLogic de destino.
- `WEBLOGIC_TIMEOUT`: Timeout para operações WebLogic.

### Variáveis Dinâmicas
- `ARTIFACT_FILE`: Nome do arquivo principal identificado dinamicamente.

---

## Configuração de Ambiente

O pipeline requer um arquivo de configuração específico por ambiente:
```
.azuredevops/config/{environment}/weblogic.yml
```

Estrutura esperada:
```yaml
weblogic:
  WEBLOGIC_ADMIN_SERVER_URL: "http://server:port"
  WEBLOGIC_USER: "$(WEBLOGIC_USER)" # Pega o valor da variable group
  WEBLOGIC_PASS: "$(WEBLOGIC_PASSWORD)$" # Pega o valor da variable group
  WEBLOGIC_CLUSTER: "cluster_name"
  WEBLOGIC_TIMEOUT: "300"
```

---

## Fluxo Resumido

1. **Preparação**: Checkout do código-fonte.
2. **Download**: Obtenção do artefato Maven do Azure Artifacts usando nome do pacote.
3. **Limpeza**: Remoção de arquivos desnecessários e identificação do artefato principal.
4. **Configuração**: Carregamento das configurações específicas do ambiente.
5. **Inicialização**: Start dos servidores WebLogic necessários.
6. **Undeploy**: Remoção de versões antigas da aplicação.
7. **Deploy**: Hot deploy da nova versão.

---

## Características Técnicas

### Otimizações
- **Checkout otimizado**: `fetchDepth: 1` para clone rápido.
- **Download seletivo**: `download: none` para evitar downloads desnecessários.
- **Limpeza automática**: Remoção de arquivos que não são artefatos válidos.

### Segurança
- Variáveis sensíveis tratadas como secrets.
- Configurações isoladas por ambiente.
- Validação de artefatos antes do deploy.

---

## Diferenças da Pipeline SSH

Esta versão "lite" difere da pipeline SSH tradicional por:

- **Sem transferência SSH**: Utiliza apenas APIs REST do WebLogic.
- **Deploy direto**: Artefatos são deployados diretamente do Azure DevOps.
- **Menor complexidade**: Menos etapas e dependências.
- **Mais rápida**: Eliminação de overhead de transferência de arquivos.

---

## Apoio

O pipeline é reutilizável e segue padrões estabelecidos. Se precisar de ajuda em alguma configuração, não hesite em entrar em contato com os profissionais do DevOps Soluções.

---

## Referências

- [Documentação Azure Pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/?view=azure-devops)
- [WebLogic REST API](https://www.oracle.com/webfolder/technetwork/tutorials/obe/fmw/wls/12c/12_2_1/01-30-001-ManageWLSREST1221/Manage_WLS_REST1221.html)
- [Azure Artifacts Maven Packages](https://learn.microsoft.com/en-us/azure/devops/artifacts/get-started-maven?view=azure-devops)

---
