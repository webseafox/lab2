# Documentação da Pipeline `lite-cd.yaml`

## Visão Geral

Esta pipeline automatiza o processo de deploy contínuo (CD) de aplicações Weblogic, incluindo etapas de preparação de ambiente, transferência de artefatos e execução de scripts. O pipeline é altamente parametrizável e utiliza tarefas Bash, SSH e integrações com Azure DevOps.

---

## Parâmetros

- `environment`: Ambiente de destino (ex: dev, qa, producao).
- `packageVersion`: Versão do pacote a ser implantado.
- `artifact`: Nome do artefato Maven a ser utilizado.
- `appName`: Nome lógico da aplicação no WebLogic utilizado para identificar a aplicação durante o processo de deploy e undeploy. Não é necessário que seja exatamente igual ao nome exibido na console do WebLogic, mas deve ser suficiente para que a aplicação seja corretamente localizada (por exemplo, pode ser um prefixo ou parte do nome).
---

## Estrutura de Stages e Jobs

### Stage: `cd_deploy`

Responsável por todo o fluxo de deploy, dividido em jobs:

#### 1. Job: `deploy`

- **Checkout do código-fonte**.
- **Extração de variáveis** do projeto (artifactId, groupId) via comandos Docker.
- **Obtenção de credenciais** do Azure Key Vault.
- **Download do artefato Maven** e scripts necessários.
- **Limpeza de arquivos indesejados** no artefato baixado.
- **Descompactação de scripts**.
- **Configuração do ambiente Weblogic**:
  - Leitura de variáveis do arquivo `weblogic.yml`.
  - Definição de variáveis de ambiente e credenciais.
- **Preparação do ambiente SSH**:
  - Criação de diretórios no servidor de destino.
  - Criação de arquivos necessários.
- **Transferência de arquivos**:
  - Envio do pacote e scripts via SSH.
- **Ajuste de permissões** dos diretórios.
- **Validação dos arquivos transferidos**.
- **Execução de scripts de readiness** (start dos servidores).
- **Undeploy de pacotes antigos**.
- **Hot deploy do novo pacote**.

---

## Principais Tarefas e Scripts

- **Bash@3**: Utilizado para manipulação de variáveis, processamento de arquivos e execução de comandos shell.
- **LegacySSH@0 / SSH@0**: Utilizado para executar comandos remotos no servidor Weblogic, incluindo criação de diretórios, execução de scripts Python (WLST), validação e limpeza.
- **LegacyCopyFilesOverSSH@0**: Transferência de arquivos (artefatos e scripts) para o servidor de destino.
- **CmdLine@2**: Execução de comandos shell para extração de informações do projeto e manipulação de arquivos.
- **AzureKeyVault@2**: Obtenção de segredos e credenciais do Azure Key Vault.
- **UniversalPackages@0**: Download de pacotes universais (scripts) do Azure Artifacts.

---

## Variáveis Importantes

- `WEBLOGIC_USER`, `WEBLOGIC_PASS`: Credenciais do Weblogic.
- `WEBLOGIC_SSH_USER`, `WEBLOGIC_SSH_PASS`: Credenciais SSH para acesso ao servidor.
- `WEBLOGIC_APPLICATIONS_SERVER_PATH`, `WEBLOGIC_SCRIPTS_SERVER_PATH`: Caminhos de destino para artefatos e scripts.
- `ALL_AVAILABLE_PROPERTIES`: Lista de arquivos de propriedades disponíveis.
- `WEBLOGIC_ADMIN_SERVER_URL`, `WEBLOGIC_ADMIN_SERVER_IP`: Endereço do servidor de administração Weblogic.

---


## Fluxo Resumido

1. Prepara variáveis e credenciais.
2. Baixa e prepara artefatos e scripts.
3. Configura ambiente remoto via SSH.
4. Transfere arquivos necessários.
5. Valida e executa scripts de deploy.

---

## Segurança

- Variáveis sensíveis são marcadas como secret.
- Remoção de diretórios é validada por padrão de caminho e nome.
- Acesso SSH é controlado por variáveis de ambiente e credenciais seguras.

---
## Apoio
O pipeline é reutilizavel se precisar de ajuda em alguma configuração não hesite em entrar em contato com os profissionais do DevOps soluções
---
## Referências

- [Documentação Azure Pipelines](https://docs.microsoft.com/azure/devops/pipelines/)
- [Weblogic Scripting Tool (WLST)](https://docs.oracle.com/middleware/12213/wls/WLSTG/index.html)

---

