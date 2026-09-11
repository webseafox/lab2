# RPA .NET V2 template

## Template

- `pipeline_dotnet.yml`: fluxo de build, análise e publicação para componentes .NET no padrão RPA V2.

## Parâmetros principais

- `PUBLISH_REPOSITORY`: destino de publicação.
- `PUBLISH_ARTIFACT_ID`: identificador do componente.
- `SONARQUBE_CONNECTION_NAME` / `SONARQUBE_PROJECT_NAME`: integração SonarQube.
- `BUILD_VERSION`: configuração de build.
- `agentPool`: pool usado nos estágios de build/publish.

## Requisitos de agente

- Stage de versionamento roda em Linux (`GeneralPurposeLinuxAgentsCI`).
- Jobs com `VSBuild@1` e PowerShell legado exigem agente Windows.
- Confirme que o `agentPool` informado no consumo está compatível com as tasks do job.

## Pré-requisitos

- Service connections (SonarQube, repositórios de artefato) configuradas.
- Grupo de variáveis esperado pelo template disponível no projeto.
- Permissões de push no branch quando o fluxo automático de versionamento estiver ativo.
- Para deploy remoto: WinRM habilitado, conectividade com os hosts e permissões para cópia/extração remota.

## Script de deploy usado

- `tech_products/rpa/V2/Deploy_Csharp_v2.ps1` (consumido por `pipeline_dotnet.yml`)

### Segurança de credenciais

- Preferir `-Credential` (`PSCredential`) ou `-Password` (`SecureString`).
- `-senha` em texto plano é mantido apenas por compatibilidade retroativa.
- Para uso de `-senha` é obrigatório informar `-AllowPlainPassword`.

### Exemplo de execução do script

```powershell
.\tech_products\rpa\V2\Deploy_Csharp_v2.ps1 `
  -listDestination "VM01,VM02" `
  -PathFile "C:\artifacts\bin" `
  -ArquivoProjeto "MeuProjeto" `
  -Credential $credencial
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
  template: /tech_products/rpa/V2/pipeline_dotnet.yml@CodePlay
  parameters:
    PUBLISH_REPOSITORY: rpa-componentes-raw
    PUBLISH_ARTIFACT_ID: Meu.Componente.Legado
    SONARQUBE_CONNECTION_NAME: VIVO_SONARQUBE
    SONARQUBE_PROJECT_NAME: $(System.TeamProject)-$(Build.Repository.Name)
```
