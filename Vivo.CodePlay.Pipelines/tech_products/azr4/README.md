# 4P Core Pipelines

Esse framework foi desenvolvido para facilitar a migração **DevOps 4p -> DevOps Corp**, padronizando a execução de esteiras CI/CD e garantindo conformidade com as políticas corporativas de AppSec (CodePlay).

> **Nota:** Os arquivos deste repositório foram migrados do repositório original.
> **Origem:** [4p-core-pipelines](https://dev.azure.com/telefonica-vivo-brasil/AZR4%20-%204P%20AZURE/_git/4p-core-pipelines) — utilize apenas para consulta do histórico.

---

## 📁 Estrutura de diretórios

* **`pipelines/`**: Diretório onde ficam os arquivos de entrypoint (orquestradores). Funciona como uma casca (Maestro) que implementa as receitas e garante que a execução dos estágios (Build, Security, Tests, Publish) seja feita na ordem padronizada.
* **`recipes/`**: Diretório das receitas de execução. Cada arquivo é responsável por implementar um pipeline para tecnologias específicas e de naturezas diferentes (ex: `maven_docker`, `nodejs_libs`, `python_docker`).
* **`templates/`**: Diretório de templates reutilizáveis.
  * **`steps/`**: Templates de passos (ex: `execute_sca.yaml`) que podem ser chamados como funções dentro de diferentes jobs.
  * **`branch_variables/`**: Utilizados na estratégia `gitlabflow` para definir variáveis de ambiente dinâmicas com base na branch em execução.

---

## Criando um novo pipeline

1. Defina se o pipeline será do tipo **build** ou **deploy**. O tipo `merge_validation` importa as receitas de build, mas exclui alguns estágios pesados (como o publish).
2. Copie a receita base de `recipes/<tipo>/example` para o diretório `recipes/<tipo>/<nome_da_tecnologia>`.
3. Edite os estágios e jobs do pipeline conforme a necessidade da nova linguagem ou framework.

---

## Executando um pipeline

Para utilizar este core no seu repositório de aplicação, você deve usar a sintaxe `extends` apontando para o template principal deste repositório, passando os parâmetros necessários e declarando as variáveis de ambiente no bloco `envs`.

## Pré-condição para recipes Java

As recipes Java que usam o step `templates/steps/set_java_version.yaml` exigem `asdf` disponível no agente.
Quando `asdf` não está instalado, a pipeline falha imediatamente com `##[error]` orientando o provisionamento do agente (ex.: via Ansible).

**Exemplo de uso no repositório da aplicação (ex: `azure-pipelines.yml`):**

```yaml
resources:
  repositories:
    - repository: CodePlay
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: master
      endpoint: CodePlay

trigger:
  - develop
  - master

extends:
  template: /tech_products/azr4/pipelines/build.yaml@CodePlay #Referência ao Core
  parameters:
    recipe: maven_docker  #Nome da receita em /tech_products/azr4/recipes/build/
    branching_strategy: gitlabflow
    envs:
      IMAGE_NAME: 4thplatform/minha-api-legal
      # Declare outras variáveis do projeto aqui

```

**Exemplo de configuração no build.yaml do repositório da sigla**

```
name: build
trigger:
  branches:
    include:
      - master
      - main
      - develop
      - homolog
  paths:
    include:
      - '*'
    exclude:
      - .azuredevops/*
      - docs/*
      - catalog-info.yaml
      - .dockerignore
 
pr: none

resources:
  repositories:
    - repository: CodePlay
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: master
      endpoint: CodePlay
     

extends:
  template: /tech_products/azr4/pipelines/build.yaml@CodePlay
  parameters:
    recipe: maven_docker
    branching_strategy: gitlabflow
    envs:
      IMAGE_NAME: 4thplatform/consulta-segmento-cnpj-api
```
---

## Azure Artifacts nas recipes Maven (`maven_libs_v2` e `maven_docker_v2`)

Por padrão as recipes Maven usam o **Nexus**, através dos Secure Files `settings.xml` e
`settings-security.xml`. As recipes `maven_libs_v2` e `maven_docker_v2` também suportam o
**Azure Artifacts**, ativado pela variável `envs.ARTIFACT_REPOSITORY`.

| Recipe | Papel no Azure Artifacts |
| --- | --- |
| `maven_libs_v2` | **Publica** (`mvn deploy`) e resolve dependências |
| `maven_docker_v2` | Apenas **resolve** dependências (não publica artefatos Maven; entrega uma imagem Docker) |

> As recipes `maven_libs` e `maven_docker` (v1) permanecem como legado e suportam apenas o Nexus.
> Como as `condition` do template testam somente `azure_artifacts`, uma recipe que não declara
> `ARTIFACT_REPOSITORY` continua caindo no caminho legado dos Secure Files.

### Variáveis disponíveis

| `envs` | Default | Recipes | Descrição |
| --- | --- | --- | --- |
| `ARTIFACT_REPOSITORY` | `nexus` | ambas | `nexus` (Secure Files) ou `azure_artifacts` (settings.xml do repositório) |
| `MAVEN_CUSTOM_SETTINGS_PATH` | `.azuredevops/settings.xml` | ambas | Caminho do `settings.xml` versionado no repositório |
| `MAVEN_GLOBAL_SETTINGS_PATH` | `/home/svc_devopscorp/.m2/settings.xml` | ambas | Global settings do agente (`-gs`); ignorado se o arquivo não existir |
| `ARTIFACT_FEED_URL` | *(vazio)* | `maven_libs_v2` | Se preenchido, publica via `-DaltDeploymentRepository` em vez do `<distributionManagement>` do `pom.xml` |
| `ARTIFACT_FEED_SERVER_ID` | `DevOps` | `maven_libs_v2` | `id` do `<server>` usado no `altDeploymentRepository`; precisa existir no `settings.xml` |

### 1. Permissões no feed

Em `telefonica-vivo-brasil > DevOps > Artifacts > Permissions`, adicione o **Build Service** do
seu projeto como **Feed Publisher (Contributor)** para publicar (`maven_libs_v2`) ou, no mínimo,
como **Feed Reader** para apenas consumir (`maven_docker_v2`). Sem isso o Maven falha com `401`.

### 2. `pom.xml`

O bloco `<repositories>` vale para as duas recipes. O `<distributionManagement>` só é necessário
em quem **publica** (`maven_libs_v2`).

```xml
<repositories>
  <repository>
    <id>DevOps</id>
    <url>https://pkgs.dev.azure.com/telefonica-vivo-brasil/_packaging/DevOps/maven/v1</url>
    <releases><enabled>true</enabled></releases>
    <snapshots><enabled>true</enabled></snapshots>
  </repository>
</repositories>
<!-- apenas em maven_libs_v2 -->
<distributionManagement>
  <repository>
    <id>DevOps</id>
    <url>https://pkgs.dev.azure.com/telefonica-vivo-brasil/_packaging/DevOps/maven/v1</url>
  </repository>
</distributionManagement>
```

> Se o projeto herda de um **parent POM** publicado no feed, declarar o repositório apenas no
> `pom.xml` não basta: o parent é resolvido antes desse bloco ser lido. Nesse caso o feed precisa
> estar também no `<profile><repositories>` do `settings.xml` (ver abaixo).

### 3. `.azuredevops/settings.xml`

> **Atenção:** esta recipe injeta o token do pipeline na variável **`AZURE_DEVOPS_PAT`**
> (padrão do `framework/pipelines/ci/build-java-lib`). A documentação corporativa geral usa
> `${SYSTEM_ACCESSTOKEN}` — se você copiar aquele exemplo sem ajustar, a autenticação falha.
> O mesmo nome também facilita o build local, bastando exportar um PAT pessoal.

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <!-- Opcional: roteia o Maven Central pelo upstream do feed. Como o mirrorOf e 'central'
       (e nao '*'), o feed interno continua sendo resolvido pelo <repository> abaixo. -->
  <mirrors>
    <mirror>
      <id>DevOps</id>
      <name>Mirror Maven Central</name>
      <url>https://pkgs.dev.azure.com/telefonica-vivo-brasil/_packaging/DevOps/maven/v1</url>
      <mirrorOf>central</mirrorOf>
    </mirror>
  </mirrors>
  <!-- Necessario para resolver parent POMs vindos do feed -->
  <profiles>
    <profile>
      <id>devops</id>
      <repositories>
        <repository>
          <id>DevOps</id>
          <url>https://pkgs.dev.azure.com/telefonica-vivo-brasil/_packaging/DevOps/maven/v1</url>
          <releases><enabled>true</enabled></releases>
          <snapshots><enabled>true</enabled></snapshots>
        </repository>
      </repositories>
    </profile>
  </profiles>
  <activeProfiles>
    <activeProfile>devops</activeProfile>
  </activeProfiles>
  <servers>
    <server>
      <id>DevOps</id>
      <username>telefonica-vivo-brasil</username>
      <password>${AZURE_DEVOPS_PAT}</password>
    </server>
  </servers>
</settings>
```

### 4. Pipeline da aplicação

**Publicando uma lib (`maven_libs_v2`):**

```yaml
extends:
  template: /tech_products/azr4/pipelines/build.yaml@CodePlay
  parameters:
    recipe: maven_libs_v2
    branching_strategy: releaseflow
    envs:
      ARTIFACT_REPOSITORY: azure_artifacts
      # MAVEN_CUSTOM_SETTINGS_PATH: .azuredevops/artifacts-settings.xml
      # ARTIFACT_FEED_URL: https://pkgs.dev.azure.com/telefonica-vivo-brasil/_packaging/DevOps/maven/v1
```

**Consumindo em uma aplicação containerizada (`maven_docker_v2`):**

```yaml
extends:
  template: /tech_products/azr4/pipelines/build.yaml@CodePlay
  parameters:
    recipe: maven_docker_v2
    branching_strategy: gitlabflow
    envs:
      IMAGE_NAME: 4thplatform/minha-aplicacao
      ARTIFACT_REPOSITORY: azure_artifacts
```

### 5. `Dockerfile` — não rode Maven dentro da imagem

Este é o ponto mais fácil de passar despercebido no `maven_docker_v2`. As imagens base
`maven-settings-java-*` trazem um `settings.xml` **embutido apontando para o Nexus**. Se o
`Dockerfile` executar `mvn` no estágio de build, ele resolve pelo Nexus independentemente do
`ARTIFACT_REPOSITORY` da pipeline — e quebra quando o Nexus for desligado.

A recipe já publica o workspace inteiro (incluindo `target/`) como artefato `build` e o restaura
antes do `docker build`, então o `Dockerfile` deve apenas consumir o jar pronto:

```dockerfile
FROM <imagem-base> as build
WORKDIR /workspace/app
COPY target/*.jar app.jar
RUN java -Djarmode=layertools -jar app.jar extract --destination target/
```

Além de resolver a questão do repositório, isso elimina uma compilação Maven redundante (o build
já roda em `build.yaml` e `tests.yaml`). Atenção: se o repositório tiver `.dockerignore`,
`target/` **não** pode estar ignorado.

O modo escolhido vale para todas as etapas Maven (`prep`, `build`, `tests`, `publish` e o
`versions:set` do commit de versão) — a resolução do `settings.xml` é centralizada em
`templates/steps/setup_maven_settings.yaml`, que exporta `MAVEN_SETTINGS`,
`MAVEN_SETTINGS_SECURITY` e `MAVEN_SETTINGS_ARGS`. No modo `azure_artifacts` o template ainda
valida que `AZURE_DEVOPS_PAT` está preenchido, falhando cedo em vez de deixar o Maven enviar a
string literal `${AZURE_DEVOPS_PAT}` ao feed e receber um `401` confuso.
