# QA test automation pipeline

This folder contains the QA pipeline that executes automated test scenarios
with Maven inside a Docker runtime and then runs AppSec checks (SCA and
Fortify).

## What this pipeline does

The file `pipeline.yaml` currently defines:

1. One stage: `scenarios_exec`.
2. Four jobs in this order:
   1. `scenarios_exec`
   2. `AppSecConfigKeys`
   3. `ScaScan`
   4. `FortifyScan`
3. Scenario command routing based on compile-time conditions (`${{ if ... }}`)
   that build `maven_command`.
4. Security integration through templates in `/security`.

## Structure

```text
tech_products/qa/test_automation/
├── pipeline.yaml
├── README.md
└── carta_excecao.md
```

## Stage and jobs

### Stage `scenarios_exec`

- `displayName`: `${{ parameters.config.params.description }} ${{ parameters.config.params.scenariosType }}`
- `pool`: `GeneralPurposeLinuxAgentsCI`

### Job `scenarios_exec`

- `timeoutInMinutes`: `180`
- `cancelTimeoutInMinutes`: `3`
- Main steps:
  - `AzureKeyVault@2` (loads `NEXUS-DEPS-USR`, `NEXUS-DEPS-PSW`)
  - `Docker@2` login (`ACR-DEVOPS`)
  - `bash` debug for `maven_command`
  - `bash` runtime execution:
    `acrsharedservices01.azurecr.io/base/qa/selenium-junit/oraclient/runtime:1.0.1`
  - `CopyFiles@2` (stages sources to `$(Build.ArtifactStagingDirectory)`)
  - `PublishBuildArtifacts@1` with `ArtifactName: app`
  - `PublishPipelineArtifact@1` for `RunResults/`
  - `DeleteFiles@1` cleanup for `RunResults/**`

### Job `AppSecConfigKeys`

- `dependsOn`: `scenarios_exec`
- Template:
  - `/security/get_appconfig_keys.yml`

### Job `ScaScan`

- `dependsOn`: `AppSecConfigKeys`
- `condition`: `and(succeeded(), eq(variables.USE_DEPENDENCY_TRACK, true))`
- Templates:
  - `/security/define_appsec_app_version.yml`
  - `/security/run_sca_scan.yml`
- Parameters passed to SCA template:
  - `appVersion: "$(FORTIFY_APP_VERSION)"`
  - `buildArtifactName: "app"`

### Job `FortifyScan`

- `dependsOn`: `AppSecConfigKeys`
- `condition`: `and(succeeded(), eq(variables.USE_FORTIFY, 'true'))`
- Templates:
  - `/security/define_appsec_app_version.yml`
  - `/security/run_fortify_scan.yml`
- Parameters passed to Fortify template:
  - `fortifyExclusionRepository: "FortifyExclusion"`
  - `enableFortifyExclusions: false`
  - `appLanguage: "other"`
  - `appVersion: "$(FORTIFY_APP_VERSION)"`

## Parameters in `pipeline.yaml`

| Name | Type | Default | Notes |
|---|---|---|---|
| `description` | `string` | `"Execução cenário"` | Scenario description |
| `docker_image` | `string` | `selenium` | Allowed value: `selenium` |
| `branch` | `string` | `master` | Branch context |
| `update_alm_tool` | `boolean` | `False` | Octane update flag |
| `scenariosType` | `string` | `""` | Scenario family |
| `suit` | `string` | `""` | Test suite |
| `config` | `object` | `{}` | Primary runtime object (`config.params.*`) |
| `inputs` | `object` | `{}` | Additional object parameter |
| `maven` | `object` | `{}` | Additional object parameter |
| `general` | `object` | `"{}"` | General configuration |
| `maven_command` | `string` | `""` | Command override/input |

## Scenario routing in the file

The YAML contains compile-time branches for these `scenariosType` values:

- `brm`
- `e2e`
- `equipamentos`
- `rgc-b2b`
- `salesforce`
- `sanity-ongoing`
- `sanity-osp`
- `sanity-sf`
- `sanity-vc`
- `vivo-mais-b2b`

For BRM daily/regression flows, `inputs.dayWeek` supports:

- `BRM_Execucao_Diaria_Segunda`
- `BRM_Execucao_Diaria_Terca`
- `BRM_Execucao_Diaria_Quarta`
- `BRM_Execucao_Diaria_Quinta`
- `BRM_Execucao_Diaria_Sexta`
- `BRM_Execucao_Diaria_Segunda_Esteira1`
- `BRM_Execucao_Diaria_Terca_Esteira1`
- `BRM_Execucao_Diaria_Quarta_Esteira1`
- `BRM_Execucao_Diaria_Quinta_Esteira1`
- `BRM_Execucao_Diaria_Sexta_Esteira1`
- `BRM_Regressao`

The file also contains:

- `298` conditional mappings for `inputs.ep_cucumber`.
- `68` conditional mappings for `inputs.test`.

## Variables and variable groups

The pipeline includes a large variable catalog (`193` named variables), with
sections for agents, Maven, Docker, Helm, Kubernetes, security tools, and
integration endpoints.

Variable groups defined:

- `azdo-team-project-variables`
- `SANITY-PRODUCAO-VC`
- `SANITY-PRODUCAO-SF`
- `BRM-LIBRARY-SUITE-REGRESSAO`
- `BRM-LIBRARY-POD-SUITE-REGRESSAO`
- `SALESFORCE-CN0023-FENIX-DOWN-RAMAIS`
- `alm`

## Artifacts

This pipeline now publishes both artifact types used by downstream checks:

1. Build artifact for SCA download:
   - Task: `PublishBuildArtifacts@1`
   - Name: `app`
2. Pipeline artifact for test evidence:
   - Task: `PublishPipelineArtifact@1`
   - Path: `$(System.DefaultWorkingDirectory)/RunResults/`

## How to consume this template

Use this template from another pipeline and pass `config.params` with the
fields consumed by conditions in this file:

```yaml
extends:
  template: /tech_products/qa/test_automation/pipeline.yaml
  parameters:
    config:
      params:
        description: "Execução E2E"
        scenariosType: "e2e"
        maven:
          command: "test"
          suit: "suite.xml"
          ambiente: "preprod"
          pathFilePom: "pom.xml"
          pathFileSettings: ".azuredevops/settings.xml"
          repoLocal: ".m2/repository"
          remoteServer: "nexus"
          testeType: "funcional"
          monitor: "false"
        inputs:
          pod: "POD01"
          test: "MeuTeste.java"
          cnpj: "00000000000100"
```

## Validation

```bash
make validate-custom PIPELINE=tech_products/qa/test_automation/pipeline.yaml
```

## References

- [Exception letter](./carta_excecao.md)
- [Repository contribution guide](../../../CONTRIBUTING.md)
- [General guidelines](../../../GUIDELINES.md)
