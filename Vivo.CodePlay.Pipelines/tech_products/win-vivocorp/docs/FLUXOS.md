# Diagramas de Fluxo - Pipeline Win-VivoCore

## Fluxo Principal de Deploy

```mermaid
flowchart TD
    A[entrypoint.yml] --> B{model parameter}
    
    B -->|deploy| C[provisioner_entry.yml]
    B -->|backup| D[provisioner_entry_backup.yml]
    
    C --> E[Load Variables]
    E --> F[Prepare Stage]
    F --> G[Import Stage]
    G --> H[Build Stage]
    H --> I[Upload Stage]
    I --> J[Restart Stage]
    J --> K[ADM Stage]
    K --> L[Active Stage]
    L --> M[Security Gates]
    M --> N[Quality Gates]
    N --> O[Deploy Complete]
    
    D --> P[Load Variables]
    P --> Q[Identification Stage]
    Q --> R[Register Stage]
    R --> S[Export ADM Stage]
    S --> T[Backup Complete]
    
    style A fill:#e1f5fe
    style C fill:#f3e5f5
    style D fill:#fff3e0
    style M fill:#ffebee
    style N fill:#e8f5e8
```

## Fluxo de Variáveis por Ambiente

```mermaid
flowchart LR
    A[parameters.environment] --> B{Environment Switch}
    
    B -->|dev1| C[DEV1_VARIABLES]
    B -->|qa1| D[QA1_VARIABLES]
    B -->|qa2| E[QA2_VARIABLES]
    B -->|pp| F[PP_VARIABLES]
    B -->|ppl| G[PPL_VARIABLES]
    B -->|prod_new| H[PROD_NEW_VARIABLES]
    B -->|prd| I[PRD_VARIABLES]
    
    J[Global Variables] --> K[All Environments]
    
    C --> K
    D --> K
    E --> K
    F --> K
    G --> K
    H --> K
    I --> K
    
    K --> L[Pipeline Execution]
    
    style J fill:#e3f2fd
    style K fill:#f1f8e9
```

## Arquitetura de Security Gates

```mermaid
flowchart TD
    A[Code Ready] --> B[Security Gates Stage]
    
    B --> C[Fortify Scan]
    C --> D{Fortify Results}
    
    D -->|Pass| E[Continue Pipeline]
    D -->|Fail| F[Block Pipeline]
    D -->|Exclusion| G[Check FortifyExclusion Repository]
    
    G --> H{Exclusion Valid?}
    H -->|Yes| E
    H -->|No| F
    
    E --> I[Quality Gates]
    I --> J[SonarQube Analysis]
    J --> K{Quality Results}
    
    K -->|Pass| L[Deploy Approved]
    K -->|Fail| M[Block Deploy]
    
    style C fill:#ffebee
    style J fill:#e8f5e8
    style F fill:#ffcdd2
    style M fill:#ffcdd2
    style L fill:#c8e6c9
```

## Estrutura de Templates e Dependências

```mermaid
graph TD
    A[entrypoint.yml] --> B[provisioner_entry.yml]
    
    B --> C[variables/load.yml]
    C --> D[Global Variables]
    C --> E[Environment-Specific Variables]
    
    B --> F[stages/default/]
    F --> F1[prepare.yml]
    F --> F2[import.yml]
    F --> F3[build.yml]
    F --> F4[upload.yml]
    F --> F5[restart.yml]
    F --> F6[adm.yml]
    F --> F7[active.yml]
    F --> F8[security.yml]
    F --> F9[quality_gates.yml]
    
    A --> G[provisioner_entry_backup.yml]
    G --> H[stages/backup/]
    H --> H1[identification.yml]
    H --> H2[register.yml]
    H --> H3[export_adm.yml]
    
    style A fill:#e1f5fe
    style B fill:#f3e5f5
    style G fill:#fff3e0
    style F fill:#f9fbe7
    style H fill:#fce4ec
```

## Fluxo de Execução Temporal

```mermaid
gantt
    title Pipeline Win-VivoCore - Execução Deploy
    dateFormat X
    axisFormat %M:%S
    
    section Preparation
    Load Variables    :0, 30s
    Prepare Environment :30s, 60s
    
    section Build Process
    Import Dependencies :60s, 120s
    Build Application  :120s, 300s
    Upload Artifacts   :300s, 360s
    
    section Deployment
    Restart Services   :360s, 420s
    ADM Configuration  :420s, 480s
    Activate Environment :480s, 540s
    
    section Gates
    Security Scan      :540s, 900s
    Quality Analysis   :900s, 1080s
    
    section Completion
    Final Validation   :1080s, 1140s
```

## Matriz de Responsabilidades

| Stage | Responsável | Tempo Estimado | Crítico | Rollback |
|-------|-------------|----------------|---------|----------|
| Prepare | DevOps | 30s | ⚠️ | ❌ |
| Import | DevOps | 1min | ⚠️ | ❌ |
| Build | DevOps | 3min | 🔴 | ❌ |
| Upload | DevOps | 1min | 🔴 | ❌ |
| Restart | SysAdmin | 1min | 🔴 | ❌ |
| ADM | SysAdmin | 1min | 🔴 | ❌ |
| Active | SysAdmin | 1min | 🔴 | ❌ |
| Security | SecOps | 6min | 🔴 | ❌ |
| Quality | DevOps | 3min | ⚠️ | ❌ |

**Legenda:**

- 🔴 Crítico - Falha bloqueia pipeline
- ⚠️ Warning - Falha gera alerta mas permite continuidade
- ✅ Suporta rollback automático
- ❌ Não suporta rollback automático

---

> Documentação de fluxos atualizada em: 30/06/2025
