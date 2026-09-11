# Book de Diretrizes para Pipelines (v1.1)


## 1) Objetivo e Escopo

Garantir que todas os times de projetos/produtos entreguem software com qualidade, segurança e rastreabilidade dentro da Vivo, seguindo padrões mínimos obrigatórios através do **Azure DevOps (pipelines YAML).**

**Escopo:** todos os repositórios e pipelines de CI/CD do Azure DevOps.

## 2) Princípios

* **Pipeline as Code:** tudo versionado em YAML ou extensões e revisado por Pull Requests por Arquitetura DevOps.
* **Centralização:** todos os modelos de pipeline armazenados no repositório central do Framework CodePlay (`Vivo.CodePlay.Pipelines`).
* **Inner Source:** contribuições de times são bem-vindas (modelos customizados ou padrões).
* **Fair Use:** proibição de explorar brechas; devem ser reportadas ao time de DevOps.
* **Reuso e simplicidade:** uso de templates, tasks compartilhadas, convenções de nomenclatura dentro do Framework CodePlay.
* **Segurança por padrão:** secrets fora do repositório; scanners de segurança desde o início.
* **Qualidade por padrão:** testes unitários e análise estática desde o início.
* **Deploy em Produção:** aprovação obrigatória via `Environment prod` com grupo PCP.
* **Deploy em QA:** aprovação obrigatória via *Environment QA* com grupo QA.
* **Auditável:** trilha e evidências diretas na plataforma.
* **Agent Pools:** pools hospedados na Vivo para segurança e agilidade.


## 3) Nomenclatura e Estrutura

### Pastas

Arquivos devem estar no diretório `.azuredevops`.

### Pipelines

* **CI:** `app-<nome>-ci.yml`
* **CD:** `app-<nome>-cd.yml`
* **CI+CD:** `azure-pipelines.yml`

### Stages padrões

* Pipeline Initialization
* Build & Unit Test
* Quality Gates
* Security
* Quality Test
* Package & Publish
* Deploy Environments (dev, QA, prod)

### Artefatos

| Tipo                                  | Registry  | Nomenclatura                      |
| ------------------------------------- | --------- | --------------------------------- |
| Container                             | ACR       | `<sigla>/<nome-componente>`       |
| NPM                                   | Artifacts | `@<sigla>/<nome-componente>`      |
| Python                                | Artifacts | `<sigla>-<nome-componente>`       |
| dotnet                                | Artifacts | `<Sigla>.<Nome-Componente>`       |
| Maven                                 | Artifacts | `br.com.tlf.<sigla>:<componente>` |
| Gradle                                | Artifacts | —                                 |
| Cargo                                 | Artifacts | TBD                               |
| Universal Packages (zip, tar, txt...) | Artifacts | `<sigla>-<nome-artefato>`         |
| Helm                                  | ACR Helm  | `<sigla>/<nome-chart>`            |
| Go                                    | Nexus     | TBD                               |
| Dart                                  | Nexus     | TBD                               |
| Raw                                   | Nexus     | `<sigla>-<nome-artefato>`         |

### Branches

* **Trunk-based:** `master` ou `main` (+ branches curtas)
* **VivoFlow:** `main`, `homologation/*`, `release/*`
* **GitLabFlow:** `main`, `homolog`, `qa1`, `develop`
* **ReleaseFlow:** `release/M.m`

## 4) Gestão de Secrets e Acessos

* **Secrets:** via Azure Key Vault ou Variable Groups (proibido em YAML).
* **Service connections:** princípio do menor privilégio + Managed Identity.

### Grupos de acesso (Microsoft Entra ID)

* `CLOUDTI_SIGLA_READER` → apenas leitura.
* `CLOUDTI_SIGLA_DEVELOPER` → desenvolvimento, pipelines, logs.
* `CLOUDTI_SIGLA_MAINTAINER` → aprovar PRs, administrar pipelines.
* `CLOUDTI_SIGLA_PCP` → aprovar produção.
* `CLOUDTI_SIGLA_QA` → aprovar homologação.

OBS: no SailPoint os grupos são mapeados para `GOV_CORP_SIGLA_PAPEL`.


## 5) Qualidade, Segurança e Conformidade

* **Testes unitários:** ≥80% de cobertura (time define).
* **Scans de segurança:** SAST, SCA, IaC Scan.

  * Falhas Críticas/Altas → bloqueiam pipeline.
* **Pull Request policies:** 2 aprovadores, build obrigatório, associação de Work Item.
* **Change validation:** variável `CHG_ID` validada no Service Now (quando aplicável).
* **Governança:** execução avaliada em runtime → alertas ou interrupção.


## 6) Deploy & Ambientes

## Estratégias

* Preferir **blue/green, canary, feature flags.**

## Rollback

* Plano documentado e testado.
* Possibilidade de rollback automatizado.

### Tabela de Ambientes (resumida)

| Nome                                 | Fluxo         | Aprovação               | Descrição             |
| ------------------------------------ | ------------- | ----------------------- | --------------------- |
| `deploy-dev`                         | Trunk         | Sem aprovação           | Deploy em Dev         |
| `deploy-esteira1/2/preprod/prodlike` | Trunk         | Opcional                | Deploy em QA          |
| `deploy-producao`                    | Trunk         | PCP                     | Produção              |
| `deploy-lib`                         | Deploy libs   | Sem aprovação           | Publicar libs         |
| `deploy-homologation`                | Vivoflow      | Opcional                | QA                    |
| `deploy-production`                  | Vivoflow      | PCP                     | Produção              |
| `deploy-*-promote/rollback`          | Blue/Green    | Devs+Maintainers ou PCP | Estratégia Blue/Green |
| `terraform-approval-*`               | IaC Terraform | Cloud Eng.              | Execução terraform    |


## 7) Gate de Produção (Obrigatório)

* Todo deploy em produção deve passar por **Environment Prod com Approvals & Checks**.
* Aprovador obrigatório: **PCP**.
* Configuração automática em novos projetos.

**Gates opcionais:**

* Horário comercial
* Work item/CHG\_ID
* Controle de branch
* Lock exclusivo

⚠️ Proibido usar `manualValidation` como substituto.


## 8) RACI (Resumo)

* **Squads:** build/test, deploy dev/QA, PR, evidências.
* **AppSec:** ferramentas e suporte a segurança.
* **QA:** ambiente QA, testes, evidências.
* **PCP:** aprova gate, estabilidade em produção.
* **Cloud/SRE/SO/Middleware:** manutenção de ambientes, observabilidade.
* **Identidades:** concessão/revogação de acessos.
* **Frameworks de dev:** padrões, aceleradores, governança.
* **Governança DevOps:** políticas mínimas, auditoria.
* **Arquitetura DevOps:** aprova PRs, garante pipelines e agentes.
* **DevSupport:** suporte ao ecossistema Tech.IA.


## 9) Exceções

* Devem ser alinhadas com DevOps e responsáveis.
* Toda exceção deve:

  1. Ser documentada e formalizada
  2. Ter prazo e plano de remediação
  3. Ser aprovada por Gerência Sr. + times impactados


---

:::warning[Importante]
As informações desse documento devem ser atualizadas no [documento original](https://telefonicacorp-my.sharepoint.com/:w:/r/personal/mateus_casabona_telefonica_com/Documents/01%20-%20DevSecOps/Diretrizes%20Corporativas%20DevOps.docx?d=wa8852328ce3f40e68fe269cc9ae2764b&csf=1&web=1&e=sb7scr).
:::
