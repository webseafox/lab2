# Documentação da Pipeline `lite-cd.yaml`

Este documento descreve o funcionamento da pipeline YAML utilizada para o deploy automatizado de aplicações Java no WebLogic, localizada em:

`tech_products/dvps/java/trunkbased/weblogic-wslt/lite-cd.yaml`

---

## Parâmetros

- **environment**: Ambiente de destino (ex: dev, preprod, prod)
- **packageVersion**: Versão do pacote a ser implantado
- **artifact**: Nome do artefato Maven

---

## Fluxo Geral da Pipeline

### 1. Inicialização de Variáveis
- Carrega variáveis do grupo `lib-weblogic`.
- Define comandos para extrair `artifactId` e `groupId` do `pom.xml` via Docker.
- Define caminhos padrão para WebLogic, JDK e configurações.

### 2. Checkout e Extração de Dados
- Realiza checkout do repositório.
- Extrai `ARTIFACT_ID` e `GROUP_ID` do projeto Maven.

### 3. Download de Dependências
- Baixa credenciais do Nexus via Azure Key Vault.
- Define variáveis de ambiente para uso das credenciais.
- Baixa o artefato Maven do Azure Artifacts.
- Baixa pacotes do WebLogic e JDK como Universal Packages.

### 4. Extração dos Pacotes
- Descompacta os pacotes do WebLogic e JDK.
- Remove arquivos indesejados, mantendo apenas `.ear`, `.jar`, `.ejb` e arquivos `web`.

### 5. Configuração de Variáveis de Ambiente
- Define e exporta variáveis como `JAVA_HOME`, `JAVA_VENDOR`, `CLASSPATH`, `PATH`.
- Constrói dinamicamente nomes de variáveis de ambiente para conexão com o WebLogic, de acordo com o ambiente selecionado.

### 6. Download dos Scripts WLST
- Baixa scripts Python para automação do WebLogic (`codeplay-weblogic-scripts-wslt`).

### 7. Execução dos Scripts WLST
- **Obter versão ativa do pacote:** Executa `get_active_package.py` para consultar a versão atualmente implantada.
- **Undeploy:** Executa `undeploy_application.py` para remover a versão anterior da aplicação.
- **Deploy:** Executa `deploy_application.py` para implantar a nova versão.
- **Shutdown dos servidores:** Executa `shutdown_servers.py` para parar as JVMs do WebLogic.
- **Startup dos servidores:** Executa `start_servers.py` para iniciar as JVMs do WebLogic.

---

## Exemplos de Execução dos Scripts WLST

```sh
timeout "$(TIMEOUT)" "$(WL_HOME)/common/bin/wlst.sh" deploy_application.py \
  "$(VAR_WEBLOGIC_USER)" \
  "$(VAR_WEBLOGIC_PASSWORD)" \
  "$(VAR_WEBLOGIC_URL)" \
  "${{parameters.packageVersion}}" \
  "$(Build.ArtifactStagingDirectory)/downloaded-artifact/$(ARTIFACT_FILE)" \
  "$(VAR_WEBLOGIC_CLUSTER)"
```

---
## Apoio
O pipeline é reutilizavel se precisar de ajuda em alguma configuração não hesite em entrar em contato com os profissionais do DevOps soluções
---

## Observações

- O pipeline utiliza variáveis dinâmicas para adaptar-se a diferentes ambientes.
- O ciclo completo de deploy inclui a parada e o start das JVMs para garantir a atualização da aplicação.
- Todos os comandos críticos são executados via scripts Bash e WLST, garantindo automação ponta-a-ponta.

---

Arquivo original: [`tech_products/dvps/java/trunkbased/weblogic-wslt/lite-cd.yaml`](tech_products/dvps/java/trunkbased/weblogic-wslt/lite-cd.yaml)
