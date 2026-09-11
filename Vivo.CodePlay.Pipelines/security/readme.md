# Propósito
Guia para integrar e configurar os templates de segurança nas pipelines.

# Template de geração de chaves de configuração para controle dos scans (app_config_keys.yml e app_config_keys_framework.yml)
## Como usar o Template

Esse template deve ser executado antes dos templates de SAST - Fortify e de SCA - Dependency-Track. Esse template tem como objetivo gerar as keys de configuração que permitem ao time de AppSec realizar o controle de execução sobre os scans e os gates.
Esse template gerará as seguintes variáveis e as mesmas devem ser usadas como validação para execução das tasks de segurança e seus respectivos gates.

* `USE_FORTIFY`: Controla a execução do scan de SAST - Fortify. Valor padrão: true.
* `USE_DEPENDENCY_TRACK`: Controla execução do scan de SCA - Dependency-Track (Artefatos). Valor padrão: true.
* `USE_DT_DOCKER`: Controle a execução do scan de SCA - Dependency-Track (Docker). Valor padrão: false (para o framework, o valor padrão será true).
* `USE_CONVISO`: Controla a sincronização dos resultado dos scans com a Conviso. Valor padrão: true.
* `USE_CHECKMARX`: Controla a execução do scan do Checkmarx (SAST e SCA). Valor padrão: false.
* `SKIP_SECURITY_GATE`: Controla a execução do gate de segurança de SAST. Valor padrão: false (false nesse contexto realiza a execução do gate, com true o step seria pulado).
* `SKIP_SECURITY_GATE_SCA`: Controla a execução do gate de segurança de SCA. Valor padrão: false (false nesse contexto realiza a execução do gate, com true o step seria pulado).

Obs: Uso no framework de Devops. No framework de Devops será utilizado o template app_config_keys_framework.yml por conta de uma particularidade do modelo de pipeline do framework versus modelos de pipelines legado (Corepipelines e Codeplay pré-framework). Essa inclusão foi realizada para garantir o funcionamento do scan em ambos o cenário e a execução do scan de imagens docker como padrão.

# Integração do Template de SAST - Fortify
## Como usar o Template
```yml
jobs:
	- job: fortify_scan
	variables:
		# Flags
		USE_FORTIFY:
		USE_CONVISO:
		SKIP_SECURITY_GATE:
	#Exemplo de condition
	condition: and(
		succeeded(),
		eq(variables.USE_FORTIFY, true)
	)
	displayName: "Fortify Scan"
	steps:
		- template: /security/run_fortify_scan.yml
		parameters:
			fortifyExclusionRepository:
			appVersion:
```

### Parâmetros do Template

* `fortifyExclusionRepository`: Parâmetro obrigatório e especifica o repositório com arquivos Regex para excluir artefatos (como pastas de teste) da análise de segurança.
* `appVersion`: Parâmetro opcional que define a versão da aplicação para os scans. Se omitido, o valor padrão será `DevSecOps`. Este parâmetro afeta a identificação da aplicação na Conviso, que segue o formato: `{SIGLA}-{Nome do repositório} {appVersion}`. IMPORTANTE: Se o seu projeto for no formato Gitflow ao invés de trunkbased, a task define_appsec_app_version.yml deverá ser executada antes das tasks do SAST e do SCA e no mesmo job. Após isso, a variável `$(FORTIFY_APP_VERSION)` deverá ser enviada como o parâmetro `appVersion` nas tasks run_sca_scan.yaml, run_sca_scan_docker.yml e run_fortify_scan.yml.
* `convisoCompany`: Parâmetro opcional que define o ID da Companhia na Conviso. Se omitido, o valor padrão será `430`.


### Integração (Hands-on)
#### Integração `fortifyExclusionRepository`
Referencie o repositório na seção `resources` do seu pipeline:
```yml
resources:
	repositories: 
		- repository: FortifyExclusion
		- name: DevOps/Vivo.Fortify.Exclusions 
		- type: git ref: refs/heads/master
		- endpoint: CorePipelines 
```
Passe o alias (`FortifyExclusion`) ao chamar o template:
```yml
- template: /tech_products/example/templates/ci/ci_security_example.yml
  parameters: 
	fortifyExclusionRepository: FortifyExclusion
```

---
# Integração do Template de SCA - Dependency Track
A análise de composição de software (SCA) verifica as dependências do seu projeto em busca de vulnerabilidades conhecidas. Oferecemos dois templates para essa finalidade:
* run_sca_scan.yml: Para análise de projetos baseados em artefatos de build (ex: .jar, .nupkg).
* run_sca_scan_docker.yml: Para análise específica de imagens Docker.
## Como usar o template 
Para utilizar o scanner de SCA para imagens Docker, configure o seu job da seguinte forma, garantindo que a variável USE_DT_DOCKER esteja definida como true
```yml
jobs:
  - job: sca_scan_docker
    displayName: "SCA Scan (Docker)"
    variables:
      # Flags de ativação
      USE_DEPENDENCY_TRACK: 
      USE_DT_DOCKER:  
      USE_CONVISO: 
      SKIP_SECURITY_GATE_SCA: 
    
    # Condição para executar apenas o scan Docker
    condition: and(
                  succeeded(),
                  eq(variables.USE_DEPENDENCY_TRACK, true),
                  eq(variables.USE_DT_DOCKER, true)
                )
    steps:
      - template: /security/run_sca_scan_docker.yml
        parameters:
          imageSource: "$(DOCKER_REGISTRY)/$(ImageName):$(ImageTag)" # Exemplo
          appVersion: "$(FORTIFY_APP_VERSION)" # Opcional, recomendado para VivoFlow
          # convisoCompany: 430 # Opcional
          # vivoFlow: 'develop' # Opcional
```
Os templates `run_sca_scan_docker.yml` e `run_sca_scan.yml` são chamados de maneira similar. A diferença crucial é que o `run_sca_scan_docker.yml` é **específico para análises em ambientes Docker**.

Também é importante notar a condição de execução para cada um:

- O template `run_sca_scan.yml` é utilizado quando a variável `USE_DT_DOCKER` está definida como `false` (ou seja, `condition: eq(variables.USE_DT_DOCKER, false)`).
- Por outro lado, o template `run_sca_scan_docker.yml` requer que essa mesma variável `USE_DT_DOCKER` seja `true` para sua execução.
### Parâmetros do Template - Docker
**Parâmetros referente ao template `run_sca_scan_docker.yml`.**

* `appVersion`: Parâmetro opcional que define a versão da aplicação para os scans. Se omitido, o valor padrão será `DevSecOps`. Este parâmetro afeta a identificação da aplicação na Conviso, que segue o formato: `{SIGLA}-{Nome do repositório} {appVersion}`. IMPORTANTE: Se o seu projeto for no formato Gitflow ao invés de trunkbased, a task define_appsec_app_version.yml deverá ser executada antes das tasks do SAST e do SCA e no mesmo job. Após isso, a variável `$(FORTIFY_APP_VERSION)` deverá ser enviada como o parâmetro `appVersion` nas tasks run_sca_scan.yaml, run_sca_scan_docker.yml e run_fortify_scan.yml.
* `convisoCompany`: Parâmetro opcional que define o ID da Companhia na Conviso. Se omitido, o valor padrão será `430`.
* `imageSource` (Obrigatório): Especifica a imagem Docker completa (registro/nome:tag) que será analisada. Se omitido, o valor padrão será `$(DOCKER_REGISTRY)/$(docker_metadata.DOCKER_IMAGE_NAME):$(docker_metadata.DOCKER_IMAGE_TAG)`

#### Como o Template Docker Funciona?
O template run_sca_scan_docker.yml executa os seguintes passos de forma automatizada:

1. Instalação do Syft: Instala a ferramenta Syft, que é responsável por gerar o SBOM (Software Bill of Materials) da imagem.

2. Autenticação no Registro: Obtém as credenciais e se autentica no registro Docker onde a imagem está hospedada.

3. Geração do SBOM: Executa o Syft contra a imageSource especificada para gerar um relatório cyclonedx_report.json com todas as dependências encontradas na imagem.

4. Upload para o Dependency Track: Envia o SBOM gerado para a plataforma Dependency Track para análise.

5. Análise e Monitoramento: Aguarda o Dependency Track processar o SBOM e identificar as vulnerabilidades.

6. Security Gate: Verifica o resultado da análise. Se novas vulnerabilidades de severidade Crítica ou Alta forem encontradas, o passo falhará, interrompendo o pipeline.

7. Publicação de Artefatos: Publica o SBOM (cyclonedx_report.json) como um artefato do build para rastreabilidade.

### Parâmetros do Template
**Parâmetros referente ao template `run_sca_scan.yml`.**

* `appVersion`: Parâmetro opcional que define a versão da aplicação para os scans. Se omitido, o valor padrão será `DevSecOps`. Este parâmetro afeta a identificação da aplicação na Conviso, que segue o formato: `{SIGLA}-{Nome do repositório} {appVersion}`. IMPORTANTE: Se o seu projeto for no formato Gitflow ao invés de trunkbased, a task define_appsec_app_version.yml deverá ser executada antes das tasks do SAST e do SCA e no mesmo job. Após isso, a variável `$(FORTIFY_APP_VERSION)` deverá ser enviada como o parâmetro `appVersion` nas tasks run_sca_scan.yaml, run_sca_scan_docker.yml e run_fortify_scan.yml.
* `convisoCompany`: Parâmetro opcional que define o ID da Companhia na Conviso. Se omitido, o valor padrão será `430`.
* `buildArtifactName`: Este parâmetro é obrigatório e especifica o nome dado ao pacote ou arquivo resultante do build. Por padrão, o artefato será nomeado como `app`.

---

# Atualização automática de Assets na Conviso Platform

O template `run_fortify_scan.yml` conta com uma etapa nativa e automatizada de mapeamento de Tags e Teams na Conviso Platform. Não é necessária nenhuma configuração adicional por parte do Security Champion, a não ser que o time ainda não exista na Conviso.

## Como a associação funciona?

1. Logo após a sincronização inicial do projeto com a Conviso (onde o Asset é criado/identificado), a pipeline entra em ação extraindo automaticamente a sigla do projeto com base na variável `$(System.TeamProject)`. (Exemplo: Se o projeto se chama ABCD - Meu Projeto, a sigla será ABCD).

2. A pipeline realiza uma consulta via GraphQL na API da Conviso buscando o Team ID que corresponde exatamente à sigla em questão.

3. Se o Asset recém-sincronizado estiver sem Tags ou sem Teams vinculados, a pipeline disparará uma requisição de atualização inserindo a sigla como Tag e associando o projeto ao Team encontrado.

4. Resiliência (Fail-Safe): Caso o Team não seja encontrado na Conviso, a pipeline prosseguirá adicionando apenas a Tag. Falhas de rede ou na API nesta etapa específica não quebram o build, sendo registradas apenas como avisos nos logs da task.

---

# Modos de Operação
Os templates de segurança se adaptam a dois modelos de desenvolvimento para otimizar a execução dos scans: **Trunk-Based(padrão)** e **VivoFlow (condicional)**. O modo de operação é controlado pela presença ou ausência do parâmetro: `vivoFlow`.

* **Modo Padrão (Trunk-Based):** O scan de segurança é executado **incondicionalmente** em todos as branches.
* **Modo Condicional (VivoFlow):** O scan é executado **apenas** em branches que atendem a regras de validação específicas (uma "whitelist").
## Ativação e Configuração

A configuração é feita através do parâmetro `vivoFlow` na chamada do template:
- **Para ativar o Modo Padrão (Trunk-Based):** Omita o parâmetro `vivoFlow`.
    ```
    # azure-pipelines.yml (Exemplo para Trunk-Based)
    steps:
    - template: templates/security-sast-template.yml
      parameters:
        # O parâmetro 'vivoFlow' é omitido.
        # ... outros parâmetros necessários
    ```
- **Para ativar o Modo Condicional (VivoFlow):** Passe o parâmetro `vivoFlow` com uma string contendo os nomes dos branches customizados, separados por vírgula.
    ```
    # azure-pipelines.yml (Exemplo para VivoFlow)
    steps:
    - template: templates/security-sast-template.yml
      parameters:
        # A presença deste parâmetro ativa o modo condicional.
        vivoFlow: 'main,develop'
        # ... outros parâmetros necessários
    ```
## Regras de Validação (Modo VivoFlow)

Quando o modo VivoFlow está ativo, o scan executa apenas nos seguintes branches:

- **Fixos:** `main`, `master`, e qualquer branch que comece com `release/`.
    
- **Customizados:** Branches listados na string do parâmetro `vivoFlow`.
    

**Exemplo:** Com a configuração `vivoFlow: 'develop'`, um branch chamado `feature/nova-interface` **não** será escaneado.
# Suporte
* AppSec: appsec_vivo.br@telefonica.com
* Documentações Internas: https://wikicorp.telefonica.com.br/pages/viewpage.action?pageId=524036659