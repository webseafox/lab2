# 4. Artifacts Registry

Date: 2025-12-16

## Status

Draft

## Context

Como parte do Ciclo de Vida de Desenvolvimento de Software (SDLC), é essencial garantir que todos os artefatos produzidos durante o desenvolvimento sejam armazenados, versionados e acessíveis de maneira eficiente.

Esse ADR propõe uma matriz de decisão sobre qual Registro de artefatos utilizar dependendo do tipo de artefato.

Atualmente temos diversas soluções na empresa, e essa diversidade pode levar a inconsistências, dificuldades de acesso e problemas de versionamento.

### Objetivos

1. **Governança e padronização**
   - Definir processos padronizados para publicação, versionamento e distribuição
   - Estabelecer taxonomia consistente e naming conventions para classificação de artefatos
   - Implementar quality gates obrigatórios no ciclo de desenvolvimento

2. **Segurança**
   - Implementar controles de acesso adequados e rastreabilidade completa
   - Assegurar que todos os artefatos de software atendam aos requisitos de segurança corporativos
   - Garantir compliance com regulamentações aplicáveis e políticas internas de segurança da informação

3. **Eficiência operacional**
   - Otimizar o uso de recursos de armazenamento através de políticas de expurgo assertivas
   - Reduzir riscos operacionais por meio de processos automatizados e bem definidos
   - Facilitar a descoberta e reutilização de componentes de software

4. **Visibilidade e controle**
   - Proporcionar inventário completo e atualizado de todos os artefatos (SBOM - Software Bill of Materials)
   - Implementar monitoramento contínuo de vulnerabilidades e dependências
   - Estabelecer métricas e KPIs para acompanhamento da maturidade da governança

### Escopo

Esta política aplica-se a todos os artefatos de software gerados e utilizados pelos times de desenvolvimento e sustentação na plataforma DevOps, incluindo:

- Bibliotecas e componentes reutilizáveis
- Artefatos de build (binários, pacotes e Helm Charts)
- Imagens de container (Docker)

Lista dos Artifacts Registries disponíveis:
- Nexus Corporativo
- ACR telefonicati (Corporativo)
- Azure Artifacts (Corporativo)
- Nexus 4P (Ver ADR 0005-obsolescencia-nexus-4p)
- ACRs telefonicabigdata (4P)
  - TODO: Listar quais
- Google Container Registry (GCR)
- Azure Artifacts Aura

## Decision


### Dependências para a migração

:::warning
A migração das imagens docker só serão realizadas após a conclusão da politica de expurgo e retenção de artefatos.
:::

- Definição e implementação da política de expurgo e retenção de artefatos.
  - Configuração do registro de deploy para rastreamento de implantações.
- Casos de uso de como realizar a migração dos artefatos existentes.
- Criação de um registro de artefatos, onde será possível correlacionar os artefatos ao SDLC.

> **OBS**: O expurgo no Azure Artifacts é algo ainda em aberto, pois as versões dos artefatos lá são imutáveis, isto é, ao serem excluídos não podem ser recuperados

### Sobre os artifacts registries

Decidimos padronizar o uso dos seguintes registros de artefatos:

| Artifact Registry        | Decisão                                      |
|-------------------------|------------------------------------------|
| Nexus Corporativo      | ⬆️ Será migrado para uma versão atualizada  |
| Azure Artifacts        | ✅ Artifact Registry Corporativo    |
| ACR telefonicati      | ✅ Docker Registry Corporativo       |
| Nexus 4P               | ❌ Obsolescência (Deverá ser desligado)      |
| ACRs telefonicabigdata | ❌ Obsolescência (Deverão ser desligados) |
| Azure Artifacts Aura   | ❌ Obsolescência (Deverá ser desligado)      |
| Google Container Registry (GCR) | Avaliar se realmente é necessário   |

### Detalhes dos Registros de Artefatos

#### Azure Artifacts
Gerenciador de pacotes integrado ao serviço do Azure DevOps.

**Quando utilizar:**
- Gerenciador de pacotes padrão e preferencial dos pipelines para artefatos de software (bibliotecas e pacotes).
- Consumo de pacotes de repositórios públicos através do feed "DevOps" (Upstream Sources): Maven Central, Gradle Plugins, npmjs, PyPI, NuGet Gallery.
- Publicação de pacotes via pipeline (feed `<sigla>`).

**Tecnologias atendidas:**
- Java
- Node.js
- Python
- .Net
- Universal Packages

**Solicitação de uso:**
- Cada projeto/sigla possuirá o seu próprio feed.
- Todos os projetos do Azure DevOps podem utilizar o Azure Artifacts por padrão.

**Taxonomia:**
- Utilizar taxonomia padrão: Bibliotecas/binários conforme padrão de nomenclatura.

#### Nexus
Gerenciador de pacotes da empresa Sonatype complementar ao Azure Artifacts para artefatos de software.

**Quando utilizar:**
- Consumo de pacotes/bibliotecas via pipelines em tecnologias não suportadas pelo Azure Artifacts.
- Publicação de pacotes/bibliotecas via pipelines em tecnologias não suportadas pelo Azure Artifacts.

**Tecnologias atendidas:**
- Rubygems
- Flutter
- Composer (PHP)
- Go
- Raw
- Proxy (Upstreams não atendidos pelo Azure Artifacts)

**Solicitação de uso:**
- Via chamado no VivoNow.
- Os repositórios serão criados tendo a sigla do projeto como nome e a tecnologia como sufixo (exemplo: "hbpo-ruby").

**Taxonomia:**
- Utilizar taxonomia padrão: Bibliotecas/binários conforme padrão de nomenclatura.

#### Azure Container Registry (ACR)
Serviço de registry para armazenamento de imagens Docker e outros artefatos no formato OCI (Open Container Initiative).

**Quando utilizar:**
- Registry padrão e preferencial de imagens Docker e Helm Charts.
- Consumo de imagens de repositórios públicos via Cache ou fluxo de internalização: Docker Hub, Microsoft Container Registry, Amazon Elastic Container Registry, Google Container Registry, registry.k8s.io, GitHub Container Registry.
- Publicação de imagens Docker e Helm Charts via pipeline.

**Tecnologias atendidas:**
- Imagens Docker
- Helm Charts

**Solicitação de uso:**
- Todos os pipelines projetos do Azure DevOps podem utilizar o ACR por padrão, utilizando sua própria Service Connection para acesso ao ACR via pipeline.
- Os membros dos projetos podem solicitar token de acesso por sigla ao ACR para operações locais (pull) com Docker.

> **OBS**: Hoje ainda existe uma credencial global, a adequação para o modelo de sigla está em desenvolvimento.

**Taxonomia:**
- `<sigla>/*`: Imagens Docker dos componentes do projeto/sigla
- `base/<sigla>/*`: Imagens Docker base do projeto/sigla
- `<registry-externo>/*`: Cache de imagens Docker oficiais de registries externos
- `external/*`: Imagens Docker internalizadas de registries externos
- `helm/<sigla>/*`: Helm Charts dos projetos/siglas

### Sobre os tipos de artefatos

| Tipo de Artefato | Registro Preferencial | Justificativa |
|------------------|----------------------|---------------|
| **Pacotes NuGet** (.NET) | **Azure Artifacts** | Suportado nativamente. |
| **Pacotes NPM** (Node.js) | **Azure Artifacts** | Suportado nativamente. |
| **Pacotes Maven** (Java) | **Azure Artifacts** | Suportado nativamente. |
| **Pacotes Gradle** (Java/Kotlin) | **Azure Artifacts** | Utiliza o protocolo Maven, suportado nativamente. |
| **Pacotes Python** (PyPI) | **Azure Artifacts** | Suportado nativamente. |
| **Pacotes Go** (Golang) | **Nexus** | Azure Artifacts não possui feed Go nativo. Nexus atua como GOPROXY. |
| **Pacotes Cargo** (Rust) | **Azure Artifacts** | Suportado nativamente. |
| **Universal Packages** (Genéricos/Zips) | **Azure Artifacts** | Suportado nativamente (para grandes binários). |
| **Imagens Docker** | **ACR** (Azure Container Registry) | Suportado nativamente. |
| **Helm Charts** (Kubernetes) | **ACR** (Azure Container Registry) | Suportado nativamente (via OCI). |
| **Módulos Terraform** | Git | Suportado via repositórios git. |
| **Pacotes PHP** (Composer) | **Nexus** | Não há suporte nativo no Azure Artifacts/ACR. |
| **Pacotes Ruby** (Gems) | **Nexus** | Não há suporte nativo de feed no Azure Artifacts. |
| **Pacotes C/C++** (Conan) | **Nexus** | Não há suporte nativo no Azure Artifacts. |
| **Pacotes Linux** (YUM/APT/RPM/Debian) | **Nexus** | Azure Artifacts não atua como repositório de OS. |
| **Pacotes iOS/Mac** (CocoaPods) | **Nexus** | Não há suporte nativo no Azure Artifacts. |
| **Plugins Jenkins/Outros** | **Nexus** | Repositório "Raw" ou específico não suportado no Azure. |
| **Pacotes Dart (Flutter)** | **Nexus** | Não há suporte nativo no Azure Artifacts. |

#### Lógica de decisão

1. **Azure Artifacts:** Usado para dependências de código (bibliotecas) das linguagens mais modernas (C#, JS, Java, Python e external packages (.tar, .zip...)).
2. **Azure Container Registry (ACR):** Usado para tudo que é "empacotamento de implantação" baseado em contêineres ou padrões OCI (Docker, Helm, Terraform).
3. **Nexus:** Usado como *fallback* para tecnologias legadas, linguagens específicas não cobertas pela Microsoft (PHP, Ruby) ou repositórios de sistema operacional (Linux packages).

### Política de Expurgo e Retenção

Implantação de políticas padrões de expurgo aplicáveis aos artefatos de todos os projetos, considerando possibilidade de customizações e listas de exceção (perfis de expurgo), para garantir a organização e uso racional e sustentável do ecossistema DevOps.

- Abrir chamado na MS perguntando sobre políticas de expurgo customizadas no Azure Artifacts (imutabilidade)
- Bibliotecas e componentes: "Sem inventário não há governança" -> SBOM + Dependency-Track DevOps
- Artefatos de build: Registro de deploy + SBOM
- Imagens Docker: Registro de deploy + Governança de artefatos

### Monitoramento e Auditoria

Acompanhamento em tempo real e análise histórica de eventos, proporcionando visibilidade completa sobre o ecossistema de artefatos.

**Métricas:**
- Uso de storage
- Consumo de espaço por feed/repositório (sigla), crescimento histórico e projeções de capacidade.
- Quantidade de artefatos
- Quantidade de artefatos e versões publicados por cada sigla e crescimento histórico.
- Execução de expurgos
- Expurgo ativas, exceções configuradas, artefatos fora do alcance das políticas, quantidade de artefatos excluídos e espaço recuperado.
- Compliance de taxonomia
- Lista e percentual de artefatos fora da taxonomia padrão definida.

**Logs:**
- Operações realizadas, picos de utilização e identificação de anomalias
- Atividades dos usuários e acessos suspeitos

### Verificações de Segurança e Qualidade

Todos os artefatos produzidos na Vivo devem ser submetidos a scan de qualidade e de segurança (SAST e SCA) durante a fase de Build, utilizando as respectivas ferramentas corporativas.

Todos os artefatos internalizados na Vivo devem ser submetidos a scan de segurança (SCA).

**Ferramentas:**
- **SAST:** Fortify, Conviso, Checkmarx
- **SCA:** syft, Dependency-Track
- **Análise estática de código:** SonarQube

## Consequences

### Benefícios
- **Governança e padronização:** Processos padronizados para publicação, versionamento e distribuição, com taxonomia consistente e quality gates obrigatórios.
- **Segurança:** Controles de acesso adequados, rastreabilidade completa e compliance com regulamentações de segurança.
- **Eficiência operacional:** Otimização de armazenamento via políticas de expurgo, processos automatizados e facilitação da reutilização de componentes.
- **Visibilidade e controle:** Inventário completo via SBOM, monitoramento contínuo de vulnerabilidades e métricas/KPIs para maturidade da governança.

### Riscos e Mitigações
- **Migração de registros obsoletos:** Risco de perda de dados ou interrupção durante migração. Mitigação: Planejamento detalhado e testes antes da migração.
- **Treinamento de equipes:** Necessidade de capacitação para uso dos novos registros. Mitigação: Documentação e treinamentos obrigatórios.
- **Dependências não suportadas:** Tecnologias legadas podem não ser totalmente suportadas. Mitigação: Uso do Nexus como fallback e avaliação de alternativas.
- **Custos de armazenamento:** Aumento potencial com novos artefatos. Mitigação: Políticas de expurgo assertivas e monitoramento de uso.
- **Compliance de segurança:** Artefatos devem passar por scans obrigatórios. Mitigação: Integração automática nos pipelines e auditorias regulares.
