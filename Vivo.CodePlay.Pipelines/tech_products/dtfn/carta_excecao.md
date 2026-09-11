## Carta de Exceção ao Fluxo de DevOps — Produto DTFN (Databricks)

data: 05 de Agosto de 2026.

Eu como Edgar De Rosis Da Silva, DevOps da equipe GoData, estou solicitando uma exceção ao fluxo de DevOps padrão do CodePlay para o produto DTFN, referente às pipelines `app-dtfn-ci.yml`, `app-dtfn-cd.yml`, `app-dtfn-rollback-qa.yml` e `app-dtfn-rollback-prod.yml`.

O motivo desta solicitação é que os templates genéricos do repositório `Vivo.CodePlay.Pipelines` (`ci-python.yml` — CI Build Python Library — e `cd-databricks.yml` — Deploy Databricks Data Products) foram desenhados para um paradigma de entrega diferente do que o produto DTFN precisa: empacotamento e publicação de uma biblioteca Python versionada, implantada via Databricks Asset Bundles. O DTFN não distribui uma biblioteca Python nem usa bundles — ele promove o **estado de Jobs e Notebooks de um workspace Databricks entre ambientes** (DEV → QA → PROD), com backup e rollback. Por isso a GoData (nosso time de DevOps, atuando junto à Vivo) criou templates de produto próprios em `tech_products/dtfn/` (`ci-pipeline.yaml`, `cd-pipeline.yaml`, `rollback-pipeline.yaml`), reaproveitando a mesma base de governança do CodePlay (stage `SecurityAnalysis` com Fortify/SCA via `/security/*.yml@CodePlay`, App Config Keys, Key Vault), porém com stages e steps específicos para esse fluxo.

**Estou ciente dos riscos associados a esta exceção e comprometo-me a respeitar o SLA da equipe de DevOps para casos fora do padrão e implementar planos de ação para mitigar esses riscos conforme detalhado abaixo.**

### Descrição do Projeto

O DTFN é um produto de dados em Databricks cujo ciclo de vida gira em torno de **Jobs** (definições JSON de pipelines de dados) e **Notebooks**, versionados e promovidos entre os ambientes DEV, QA e PROD. Diferente de um produto de software convencional, não há um artefato de biblioteca (wheel/tar.gz) a ser construído e publicado: o "artefato" de cada entrega é a exportação (snapshot) da configuração de Jobs/Notebooks do ambiente de origem, consumida pelas etapas seguintes.

### Solução Proposta por DevOps

Como time de DevOps (GoData/Compass Uol), a solução que propomos para atender à necessidade da Vivo (nossa cliente, dona do produto DTFN) é uma esteira de **promoção de estado de Jobs e Notebooks entre ambientes Databricks**, e não um fluxo de build/publicação de biblioteca:

- **CI (`ci-pipeline.yaml`)**: conecta no workspace Databricks de DEV e **exporta** Jobs e Notebooks como artefatos de pipeline (`DatabricksJobs`, `DatabricksNotebooks`), que servem de fonte para a promoção nos ambientes seguintes.
- **CD (`cd-pipeline.yaml`)**: promove esses artefatos primeiro para QA (com backup prévio em `Backup_QA` e deploy real testado via job temporário) e depois para PROD, sempre com um **snapshot de segurança** (`Backup_Prod`) antes de qualquer escrita, e com o deploy em PROD dividido em `PlanProd` (validação, somente leitura) e `ApplyProd` (escrita), cada um sob um Variable Group/gate de aprovação próprio.
- **Rollback (`rollback-pipeline.yaml`)**: template único e ambiente-agnóstico, servido por dois wrappers (`app-dtfn-rollback-qa.yml`, `app-dtfn-rollback-prod.yml`); em caso de problema após um deploy, restaura Jobs e Notebooks do ambiente correspondente a partir do snapshot mais recente publicado pelo `Backup_QA` ou `Backup_Prod` da CD.

Essa solução resolve a necessidade real da Vivo — promover mudanças de Jobs/Notebooks entre ambientes de forma auditável, com aprovação em duas etapas (plan/apply) e capacidade de reverter uma mudança ruim em PROD rapidamente — o que os templates genéricos do CodePlay, pensados para outro tipo de artefato, não cobrem.

### Motivo da Exceção

Os templates padrão do CodePlay para este tipo de carga de trabalho são:

- **`ci-python.yml` — CI Build Python Library**: assume que o repositório contém um pacote Python (`pyproject.toml`), builda com Poetry/UV, roda testes com Pytest, análise Sonar/Fortify/SCA e publica o pacote (`.whl`/`.tar.gz`) em um feed do Azure Artifacts, versionando via `VersionManagerVivo`.
- **`cd-databricks.yml` — Deploy Databricks Data Products**: assume que existe um pacote publicado no feed (o artefato gerado pelo template acima), baixa esse pacote, executa `databricks bundle validate` / `databricks bundle deploy` a partir de um `databricks.yml` de Databricks Asset Bundles, e opcionalmente aplica contratos de dados via Data Assets Engine.

Ambos pressupõem o par CI (build de biblioteca) + CD (deploy de bundle) como unidade de entrega — o que não corresponde ao fluxo do DTFN, pelos seguintes motivos:

1. **Não há biblioteca Python a construir/publicar.** O CI do DTFN não gera um pacote versionado; ele exporta o estado de Jobs/Notebooks do workspace DEV — um mecanismo sem equivalente em `ci-python.yml`.
2. **Deploy não é via Databricks Asset Bundles.** O CD do DTFN implanta Jobs chamando a API do Databricks diretamente por scripts Python próprios (`cd-importarjobs_sp_qa_v10_cluster.py`, `cd-importarjobs_sp_prod_v9_cluster.py`), com autenticação via Service Principal (`client-secret`) e um **manifesto de mapeamento por ambiente** (`config/job-mappings/qa.json`, `prod.json`). Os Notebooks são promovidos via sincronização de branch no Databricks Repos (PATCH `/api/2.0/repos/{repo_id}`), não via `databricks bundle deploy`. Não existe `databricks.yml` de bundle no produto.
3. **Separação Plan/Apply com approvals distintos em PROD.** O deploy em PROD é dividido em dois jobs — `PlanProd` (`--mode plan`) e `ApplyProd` (`--mode apply`) — cada um vinculado a um Variable Group diferente (`vg-dtfn-cd-prod-plan` / `vg-dtfn-cd-prod-apply`). Esse padrão de plan/apply não existe no template `cd-databricks.yml`.
4. **Backup obrigatório antes de qualquer alteração, com rollback dedicado por ambiente.** Os stages `Backup_QA` e `Backup_Prod` tiram um snapshot do ambiente antes do deploy sobrescrever o estado atual; o stage `PROD` é executado após `Backup_Prod` ter concluído (`dependsOn: [QA, Backup_Prod]`). A pipeline `rollback-pipeline.yaml` consome justamente os artefatos `DatabricksJobsQA`/`DatabricksNotebooksQA` (via `app-dtfn-rollback-qa.yml`) ou `DatabricksJobsPROD`/`DatabricksNotebooksPROD` (via `app-dtfn-rollback-prod.yml`) publicados pelos respectivos stages de Backup da CD. Não há capacidade de backup/rollback nos templates genéricos.
5. **Promoção multi-ambiente com portas de qualidade intermediárias.** O fluxo passa por QA antes de PROD (deploy real em QA, com teste de job temporário via `test-implantajobs-temp_sp_qa_v2.py`), o que foge do escopo do `cd-databricks.yml`, pensado para deploy de um único ambiente por execução via parâmetro `environment`.

Em resumo: os templates genéricos cobrem o caso "construir uma lib Python e implantar um bundle Databricks"; o DTFN precisa de "promover e versionar a configuração operacional (Jobs/Notebooks) de um workspace Databricks entre ambientes, com backup e rollback" — um problema estrutural diferente, que motivou a criação da família de templates `tech_products/dtfn/*.yaml`, mantendo-se, porém, alinhado à governança do CodePlay (stage `SecurityAnalysis` idêntico em estrutura, uso de `AppSecConfigKeys`, Key Vault, Variable Groups com approvals configurados na própria Library).

### Riscos Identificados

1. **Risco de divergência de padrão**: por não seguir os templates genéricos, mudanças futuras de governança (ex.: novas exigências de segurança) aplicadas a `cd-databricks.yml`/`ci-python.yml` não chegam automaticamente ao DTFN, exigindo replicação manual nos templates `tech_products/dtfn/*.yaml`.
2. **Risco de manutenção**: os scripts de importação/exportação de Jobs (`cd-importarjobs_sp_*_v*.py`, `ci-exportarjobs_dev_v1.py`) são específicos do produto e não são cobertos por nenhuma capacidade padrão do CodePlay, concentrando conhecimento na equipe do DTFN.
3. **Risco operacional em PROD**: como o deploy escreve diretamente via API (sem bundle), erros de mapeamento no manifesto (`prod.json`) podem impactar jobs de produção; mitigado pela separação Plan/Apply e pelo backup prévio.

### Planos de Ação

1. Os templates `tech_products/dtfn/ci-pipeline.yaml`, `cd-pipeline.yaml` e `rollback-pipeline.yaml` continuarão hospedados no repositório `Vivo.CodePlay.Pipelines`, seguindo o mesmo processo de revisão/PR das demais capacidades do CodePlay, e reaproveitando os templates compartilhados de segurança (`/security/*.yml@CodePlay`) sempre que aplicável.
2. Qualquer atualização de governança nos templates genéricos (`ci-python.yml`, `cd-databricks.yml`) será avaliada pela equipe do DTFN para replicação manual nos templates do produto, quando pertinente.
3. A documentação dos modelos de pipeline criados (CI, CD e Rollback) e o motivo de `ci-python.yml`/`cd-databricks.yml` não atenderem à necessidade do produto serão registrados também no README do repositório `DTFN - DATAFIN`, conforme solicitado na revisão da PR.

### RACI

| Atividade                                                     | Time De DevOps GoData | Area Cliente |
|-----------------------------------------------------------------|-----------------------------------------|------------------------|
| Criação do pipeline personalizado  | A                                       | R                    |
| Debug em casos de falhas              | C                                     | R                      |
| Funcionamento da infraestrutura                    | R                                       | I                      |
| Seguir Diretrizes de DevOps | A                                      | R                      |

- Responsável (R): Executa a atividade e garante a entrega conforme critérios definidos.
- Aprovador (A): Autoridade final; valida o resultado e assume a accountability.
- Consultado (C): Contribui com conhecimento antes ou durante a execução; seu parecer é considerado antes da decisão.
- Informado (I): Mantido a par de decisões e status; não participa da decisão nem da execução.

### Aprovação
- Rafael Adamo Viviani - rafael.viviani@telefonica.com - Gerente de Projetos
- Wesley Costa Silveira - wesley.silveira@telefonica.com - Arquiteto de Soluções

### Revisões Futuras
Esta carta será revisada sempre que os templates genéricos `cd-databricks.yml`/`ci-python.yml` sofrerem mudanças relevantes de governança, ou quando o fluxo de CI/CD do DTFN (`tech_products/dtfn/*.yaml`) for alterado de forma significativa (ex.: adoção futura de Databricks Asset Bundles).
