# RPA .NET V3 templates

## Templates

- `pipeline_dotnet.yml`: build/test/publish/deploy de componente .NET para fluxo RPA.
- `pipeline_dotnet_nuget.yml`: build e publicação de pacote NuGet em feeds configurados.
- `python-artifacts.yml`: versionamento, build, publicação e deploy de artefatos Python para fluxo RPA.

## Parâmetros principais

### `pipeline_dotnet.yml`

- `PUBLISH_REPOSITORY`: repositório de publicação.
- `PUBLISH_ARTIFACT_ID`: identificador do artefato.
- `SONARQUBE_CONNECTION_NAME` / `SONARQUBE_PROJECT_NAME`: integração SonarQube.
- `BUILD_VERSION`: configuração de build (`Release`/`Debug`).
- `agentPool`: pool para estágios de build/publish.
- `allowAutomatedVersionPush`: habilita commit/push automático de versionamento.

### `pipeline_dotnet_nuget.yml`

- `PUBLISH_ARTIFACT_ID`: package id do NuGet.
- `SONARQUBE_CONNECTION_NAME` / `SONARQUBE_PROJECT_NAME`: integração SonarQube.
- `forcePublish`: força publicação fora do fluxo padrão.
- `allowAutomatedVersionPush`: habilita commit e tag do arquivo de versão após a publicação bem-sucedida em `master`.
- `versionFile`: caminho do arquivo usado pelo `VersionManagerVivo@8`; o padrão é `VERSION`.
- `branchingStrategy`: estratégia de versionamento semântico; o padrão é `trunkbased`.

O template executa restore e build antes do `pack`. O empacotamento aplica
`PackageVersion` e `PackageId` por `buildProperties` e permite que o target de
pack gere arquivos adicionais exigidos por alguns tipos de projeto .NET.

O build do `pack` é intencional para projetos com `EnableComHosting`, que podem
precisar gerar arquivos como `runtimeconfig.json` durante o empacotamento. Isso
evita o erro `NU5026`. Como o projeto pode ser recompilado nessa etapa, o template
também reaplica `Version`, `AssemblyVersion` e `FileVersion`, mantendo a versão
dos binários igual à versão do pacote NuGet.

### `python-artifacts.yml`

- `PUBLISH_ARTIFACT_ID`: identificador do artefato Python publicado e implantado.
- `versionFile`: caminho do arquivo usado pelo versionamento; o padrão é `pyproject.toml`.
- `twinePublishPattern`: padrão dos artefatos publicados com Twine; o padrão publica wheel e sdist em `python-package`.
- `resourcesPath`: diretório que contém o arquivo `resources` com a lista de VMs; o padrão é `.azuredevops/resources`.
- `pythonVersion`: versão usada pelo ASDF e pelo `uv sync`; o padrão é `3.13.15`, versão disponível nos agentes self-hosted RPA.
- `rpaScriptsRef`: branch, tag ou SHA dos scripts de deploy RPA; o padrão é `master`.

O template configura Python via ASDF, no padrão dos agentes self-hosted RPA. Se
o repositório possuir `.tool-versions` com uma entrada `python`, essa versão tem
precedência. Se o arquivo não existir, o template cria uma entrada usando
`pythonVersion`/`ASDF_PYTHON_VERSION`. Use uma versão compatível com o código e
com o `requires-python` do projeto.

Exemplo para um projeto compatível com Python 3.12:

```yaml
extends:
  template: /tech_products/rpa/V3/python-artifacts.yml@CodePlay
  parameters:
    PUBLISH_ARTIFACT_ID: app-faturamento-automatico-terra
    pythonVersion: '3.12'
    versionFile: pyproject.toml
    resourcesPath: .azuredevops/resources
```

## Resolução de dependências e feeds

O step `Sincronizar dependências com uv` configura dois índices PyPI:

- `UV_INDEX_URL` → feed `DevOps`, escopado à **organização**, usado como proxy do
  PyPI público.
- `UV_EXTRA_INDEX_URL` → feed interno definido por `DEFAULT_FEED_NAME` (ex.: `RPAT`),
  escopado ao **projeto**, onde ficam as bibliotecas internas.

Como o feed interno é escopado ao projeto, a URL precisa incluir o segmento do
projeto, montado com `$(System.TeamProjectId)`:

```
https://pkgs.dev.azure.com/telefonica-vivo-brasil/$(System.TeamProjectId)/_packaging/$(DEFAULT_FEED_NAME)/pypi/simple/
```

Usa-se o **ID** do projeto (e não `$(System.TeamProject)`) porque o nome pode
conter espaços e caracteres que quebram a URL. É o mesmo identificador já usado
nos steps de download de artefato deste template.

Se o segmento do projeto for omitido, a URL resolve para o escopo de organização —
onde o feed do projeto não existe. O índice responde como vazio e o `uv` falha com
`<pacote> was not found in the package registry` / `No solution found when
resolving dependencies` para qualquer dependência interna.

A autenticação usa `$(System.AccessToken)` como senha do usuário `AzureDevOps`.
Garanta que a identidade de build do projeto tenha permissão de leitura no feed
interno; caso contrário o índice também responde vazio e o sintoma é idêntico ao
de URL incorreta.

## Requisitos de agente

- Os jobs de `VersionUpdate` usam Linux (`GeneralPurposeLinuxAgentsCI`).
- Jobs com `VSBuild@1`, `NuGetCommand@2` e scripts PowerShell legados exigem agente Windows.
- Garanta que os pools referenciados (`RPAAgents`, `agentPool`) estejam alinhados com as tasks do job.

## Pré-requisitos

- Service connections para feeds NuGet/Nexus e SonarQube já cadastradas.
- Permissão de push para o repositório caso `allowAutomatedVersionPush` esteja habilitado.
- Variáveis/grupos usados nos templates (ex.: `RPADEVOPS`) configurados no projeto.
- Para deploy remoto: WinRM habilitado nos destinos, conectividade de rede e permissões para cópia/extração remota.

## Scripts de deploy usados

- `tech_products/rpa/V3/Deploy_Csharp_v3.ps1` (consumido por `pipeline_dotnet.yml`)
- `Deploy_Python_v1.ps1` (consumido por `python-artifacts.yml`)

### Segurança de credenciais

- Preferir `-Credential` (`PSCredential`) ou `-Password` (`SecureString`).
- O parâmetro legado `-senha` segue disponível apenas por compatibilidade e deve ser evitado em novas integrações.
- Para uso de `-senha` é obrigatório informar `-AllowPlainPassword`.
- Em Azure DevOps, sempre usar variáveis secretas/Key Vault para credenciais.

### Exemplo de execução do script Python

```powershell
.\tech_products\rpa\V3\Deploy_Python_v1.ps1 `
  -listDestination "VM01,VM02" `
  -PathFile "C:\artifacts\bin" `
  -ArquivoProjeto "MeuPacote" `
  -Credential $credencial `
  -ExtractAfterCopy
```

## Exemplo de uso

```yaml
resources:
  repositories:
    - repository: CodePlay
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: master
      endpoint: CodePlay

extends:
  template: /tech_products/rpa/V3/pipeline_dotnet.yml@CodePlay
  parameters:
    PUBLISH_REPOSITORY: rpa-componentes-raw
    PUBLISH_ARTIFACT_ID: Meu.Componente
    SONARQUBE_CONNECTION_NAME: VIVO_SONARQUBE
    SONARQUBE_PROJECT_NAME: $(System.TeamProject)-$(Build.Repository.Name)
```
