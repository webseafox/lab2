# 5. Obsolescência Nexus 4P

Date: 2025-12-17

## Status

Proposed

## Context

A plataforma [Nexus 4P](https://nexus.telefonicabigdata.com/) está atualmente em uso para o armazenamento e gerenciamento de artefatos de software. No entanto, com a evolução das necessidades da organização e a disponibilidade de alternativas mais modernas e eficientes, tornou-se evidente que a manutenção do Nexus 4P não é mais viável.

Links:
- Web: https://nexus.telefonicabigdata.com/
- Docker: registry.telefonicabigdata.com

### Sobre a infrastrutura atual do Nexus 4P

Hoje o Nexus 4P está no cluster `pro-aks-devops-stack` na Azure telefonicabigdata e poucas pessoas do time de DevOps possuem acesso a infraestrutura para manutenção.

- Storage Account: [stackdevops](https://portal.azure.com/#@telefonicabigdata.onmicrosoft.com/resource/subscriptions/edf81567-7688-4b55-9b28-d2999d812449/resourceGroups/pro-devops-stack/providers/Microsoft.Storage/storageAccounts/stackdevops/overview)
- Fileshare: Nexus
- Backup: [devops-backup](https://portal.azure.com/#@telefonicabigdata.onmicrosoft.com/resource/subscriptions/edf81567-7688-4b55-9b28-d2999d812449/resourceGroups/pro-devops-stack/providers/Microsoft.RecoveryServices/vaults/devops-backup/overview)

### Sobre o que tem no Nexus 4P

Atualmente, o Nexus 4P armazena uma variedade de artefatos, incluindo:

- Imagens Docker
- Pacotes Maven (Java)
- Pacotes NPM (Node.js)
- Pacotes NuGet (.NET)
- Artefatos Raw (genéricos)

#### Inventário de Repositórios (Blob Stores)

O Nexus 4P possui os seguintes repositórios principais, com um total aproximado de 300.000 artefatos armazenados e tamanho total do blob store de 625.18 GB (com alguns repositórios individuais excedendo esse valor devido a imagens Docker grandes).

**Resumo por Tipo:**

- **Maven (4plataforma):**
  - Releases: 14.462 artefatos, 89.30 GB
  - Snapshots: 33.986 artefatos, 138.40 GB
  - Libraries: 53 artefatos, 249.66 KB
  - Archetypes: 1.017 artefatos, 10.16 MB
  - Git Details: 105 artefatos, 23.85 KB

- **NPM (4plataforma):**
  - Libraries: 2.656 artefatos, 3.20 GB
  - Releases: 4 artefatos, 22.66 MB
  - Snapshots: 5 artefatos, 10.04 MB

- **NuGet (4plataforma):** 0 artefatos (não utilizado)

- **Raw (4plataforma):** 9.823 artefatos, 847.65 GB

- **Docker Registries:**
  - docker-registry: 111.087 imagens, 3.02 TiB
  - docker-apps-registry: 52.945 imagens, 248.99 GB

- **Outros:**
  - data-engineering-4p: 5.186 artefatos, 61.52 GB
  - default: 85.693 artefatos, 12.01 GB
  - dev-ccc-npm e variantes: poucos artefatos
  - jenkins-jobs-build-number: 42 artefatos, 14.61 MB

Este inventário destaca a predominância de imagens Docker e artefatos Maven, representando a maior parte do armazenamento e volume de dados no Nexus 4P.

## Decision

O Nexus 4P será descontinuado e somente os artefatos utilizados atualmente serão migrados para o Azure Artifacts e Azure Container Registry (ACR), conforme apropriado para cada tipo de artefato.

## Dependências para a migração

- Inventário de Artefatos
- Inventario de utilização
- Uso do registro de Deploy para rastreamento de implantações
- Finalização da política de expurgo e retenção de artefatos

## Plano de Migração

Para facilitar a migração, migraremos cada tipo de artefato respeitando a seguinte ordem de prioridade:

1. **Imagens Docker**: Migrar somente as imagens Docker que estão sendo utilizadas para o Azure Container Registry (ACR).
2. **Pacotes de Linguagens**: Migrar pacotes de linguagens que estão sendo utilizados e são suportadas pelo Azure Artifacts (C#, Java, JavaScript, Python).
3. **Pacotes de Linguagens Não Suportadas**: Migrar pacotes de linguagens que estão sendo utilizados e não são suportadas (PHP, Ruby, C/C++) para repositórios alternativos ou mantê-los no Nexus atualizado.

Para garantir uma transição suave, implementaremos um plano de migração detalhado para cada tipo de artefato que inclui:

1. **Inventário de Artefatos**: Realizar um inventário completo dos artefatos atualmente armazenados no Nexus 4P, categorizando-os por tipo, uso e importância.
2. **Inventario de utilização**: Analisar os clusters e pipelines que estão utilizando o Nexus 4P para identificar o que está sendo utilizado e preparar a migração.
3. **Planejamento da Migração**: Desenvolver um plano de migração que minimize o impacto nas operações diárias, incluindo cronogramas, recursos necessários e etapas de validação.
4. **Guias de Migração**: Criar documentação detalhada para orientar as equipes na migração de seus artefatos para as novas plataformas.
5. **Banner de Aviso**: Implementar banners de aviso no Nexus 4P para informar os usuários sobre a descontinuação iminente e fornecer instruções para a migração.
6. **Comunicação**: Informar todas as partes interessadas sobre a descontinuação do Nexus 4P e o plano de migração, garantindo que todos estejam cientes das mudanças e prontos para se adaptar.
7. **Script de internalização de artefatos**: Desenvolver scripts que pode ser executado on-demand para facilitar a migração dos artefatos para as novas plataformas.
8. **Modo ReadOnly**: Colocar o Nexus 4P em modo somente leitura durante o período de migração para evitar alterações nos artefatos enquanto a migração está em andamento.
9. **Descomissionamento**: Após a conclusão da migração e validação, descomissionar o Nexus 4P de forma segura, garantindo que todos os dados foram transferidos e que não há mais dependências ativas.
10. **Suporte Pós-Migração**: Oferecer suporte às equipes durante o período pós-migração para resolver quaisquer problemas ou dúvidas que possam surgir.

## Atividades e Cronograma

As atividades para a migração do Nexus 4P serão realizadas conforme o seguinte cronograma:
| Atividade                         | Início       | Término      | Responsável        | Status             |
|-----------------------------------|--------------|--------------|--------------------|--------------------|
| Finalização da Política de Expurgo|              |              | Soluções                     | Fazendo            |
| Inventário de Artefatos           |              |              | Soluções                     | Pendente           |
| Inventário de Utilização          |              |              | Governança                   | Pendente           |
| Planejamento da Migração          |              |              | DevOps                       | Pendente           |
| Criação de Guias de Migração      |              |              | Soluções                     | Pendente           |
| Implementação de Banner de Aviso   |              |              | DevSupport                  | Pendente           |
| Comunicação com Partes Interessadas|             |              | DevOps                       | Pendente           |
| Configuração do Modo Read-Only    |              |              | DevSupport                   | Pendente           |
| Desenvolvimento de Scripts de Internalização |   |              | Soluções                     | Pendente           |
| Migração de Imagens Docker        |              |              | Soluções                     | Pendente           |
| Migração de Pacotes de Linguagens |              |              | Soluções                     | Pendente           |
| Migração de Pacotes Não Suportados|              |              | Soluções                     | Pendente           |
| Descomissionamento do Nexus 4P    |              |              | DevSupport                   | Pendente           |
| Suporte Pós-Migração              |              |              | DevSupport                   | Pendente           |



## Consequences

A descontinuação do Nexus 4P e a migração para o Azure Artifacts e ACR trarão vários benefícios, incluindo:

- **Melhoria na Integração**: Melhor integração com as ferramentas e serviços da Azure DevOps, facilitando o gerenciamento de artefatos.
- **Redução de Custos**: Potencial redução de custos operacionais ao eliminar a necessidade de manter o Nexus 4P.
- **Aumento da Eficiência**: Processos de CI/CD mais eficientes com o uso de plataformas modernas e integradas.
- **Suporte e Atualizações**: Acesso a suporte contínuo e atualizações regulares das plataformas Azure.
