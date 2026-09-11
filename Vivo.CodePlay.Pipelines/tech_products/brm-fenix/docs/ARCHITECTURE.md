# Arquitetura Detalhada - BRM Fenix

> **Documentação técnica completa da arquitetura do framework BRM Fenix**

## 📋 Índice

- [Visão Geral da Arquitetura](#visão-geral-da-arquitetura)
- [Arquitetura de Provisioners](#arquitetura-de-provisioners)
- [Modelo C4](#modelo-c4)
- [Fluxos de Dados](#fluxos-de-dados)
- [Componentes Técnicos](#componentes-técnicos)
- [Segurança](#segurança)
- [Escalabilidade](#escalabilidade)
- [Alta Disponibilidade](#alta-disponibilidade)

---

## 🏛️ Visão Geral da Arquitetura

### Princípios Arquiteturais

O BRM Fenix foi projetado seguindo princípios de **Clean Architecture**, **Infrastructure as Code** e **DevOps**:

1. **Separation of Concerns** - Provisioners isolados por responsabilidade
2. **DRY (Don't Repeat Yourself)** - Task Groups e Tasks reutilizáveis
3. **Single Responsibility** - Cada task tem uma única responsabilidade
4. **Open/Closed Principle** - Extensível via novos provisioners sem modificar core
5. **Dependency Inversion** - Abstrações via templates YAML parametrizados

### Arquitetura em Camadas

```
┌─────────────────────────────────────────────────────────────────────┐
│                    LAYER 1 - PRESENTATION                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │
│  │ Azure DevOps │  │  Azure CLI   │  │  REST API Triggers       │  │
│  │      UI      │  │              │  │                          │  │
│  └──────┬───────┘  └──────┬───────┘  └────────────┬─────────────┘  │
└─────────┼──────────────────┼──────────────────────┼─────────────────┘
          │                  │                      │
          └──────────────────┴──────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────────┐
│                   LAYER 2 - ORCHESTRATION                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │
│  │  Entrypoint  │→ │  Provisioner │→ │  Parameter Validation    │  │
│  │    Router    │  │   Selector   │  │                          │  │
│  └──────────────┘  └──────────────┘  └────────────┬─────────────┘  │
└─────────────────────────────────────────────────────┼───────────────┘
                                                      ↓
┌─────────────────────────────────────────────────────────────────────┐
│                    LAYER 3 - PROVISIONERS                           │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────────┐ │
│  │    API     │  │    IaC     │  │ Monitoring │  │ Oracle Base  │ │
│  │  Default   │  │            │  │            │  │    Image     │ │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  └──────┬───────┘ │
└────────┼───────────────┼───────────────┼────────────────┼──────────┘
         │               │               │                │
         └───────┬───────┴───────┬───────┴────────┬───────┘
                 ↓               ↓                ↓
┌─────────────────────────────────────────────────────────────────────┐
│                    LAYER 4 - TASK GROUPS                            │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────────┐ │
│  │   Files    │  │    OCI     │  │    Helm    │  │     SSH      │ │
│  │  Checkout  │  │   Config   │  │ Deployment │  │  Operations  │ │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  └──────┬───────┘ │
└────────┼───────────────┼───────────────┼────────────────┼───────────┘
         │               │               │                │
         └───────┬───────┴───────┬───────┴────────┬───────┘
                 ↓               ↓                ↓
┌─────────────────────────────────────────────────────────────────────┐
│                   LAYER 5 - ATOMIC TASKS                            │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────────┐ │
│  │   Build    │  │    Test    │  │   Deploy   │  │   Validate   │ │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  └──────┬───────┘ │
└────────┼───────────────┼───────────────┼────────────────┼──────────┘
         │               │               │                │
         └───────┬───────┴───────┬───────┴────────┬───────┘
                 ↓               ↓                ↓
┌─────────────────────────────────────────────────────────────────────┐
│                  LAYER 6 - INFRASTRUCTURE                           │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────────┐ │
│  │  OCI/OKE   │  │   Azure    │  │    ACR     │  │   External   │ │
│  │            │  │   DevOps   │  │            │  │    Tools     │ │
│  └────────────┘  └────────────┘  └────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Arquitetura de Provisioners

### API Default Provisioner (CI/CD)

```
┌──────────────────────────────────────────────────────────────────────┐
│                        CI PIPELINE                                    │
│                                                                       │
│  1. Preparation                                                      │
│          ↓                                                            │
│  2. Files (Source + Shared)                                           │
│          ↓                                                            │
│  3. Build & Test (Maven)                                            │
│          ↓                                                            │
│  4. Static Analysis (SonarQube)                                     │
│          ↓                                                            │
│  5. Security Scan (Fortify)                                         │
│          ↓                                                            │
│  6. Bundle Artifacts                                                │
│          ↓                                                            │
│  7. Trigger CD                                                       │
│                                                                       │
└───────────────────────────────┬───────────────────────────────────────┘
                                │
                                │ Trigger CD Pipeline
                                ↓
┌──────────────────────────────────────────────────────────────────────┐
│                        CD PIPELINE                                    │
│                                                                       │
│  1. Preparation                                                      │
│          ↓                                                            │
│  2. Deploy                                                           │
│          ↓                                                            │
│  3. Smoke Test                                                       │
│          ↓                                                            │
│  4. Validate Version                                                │
│          ↓                                                            │
│  5. Update Assets (Release Tag)                                     │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘
```

#### Componentes CI

| Stage | Responsabilidade | Outputs |
|-------|------------------|---------|
| **Preparation** | Define versões, tags Docker | `DOCKER_IMAGE_TAG`, `VERSION` |
| **Files** | Checkout de source + shared files em um único artefato | `source_with_shared_files` |
| **Build & Test** | Compila código, executa testes unitários | `JAR/WAR artifacts` |
| **Static Analysis** | Análise de qualidade (SonarQube) | `Quality Gate Status` |
| **Security Scan** | Scan de vulnerabilidades (Fortify) | `Security Report` |
| **Bundle** | Build de imagem Docker e publicação no ACR | `Docker Image SHA` |
| **Trigger CD** | Dispara pipeline de CD | `CD Pipeline ID` |

#### Componentes CD

| Stage | Responsabilidade | Outputs |
|-------|------------------|---------|
| **Preparation** | Valida versão, estado do cluster | `DEPLOYMENT_READY` |
| **Deploy** | Deploy via Helm no Kubernetes, inclui Smoke Test e Validate Version | `Release Status` |
| **Update Assets** | Cria tag de release no repositório (apenas `master_15`) | `Release Tag` |

---

### IaC Provisioner

```
Pipeline ──────► Validation ──────► OCI CLI ──────► Nodes ──────► Kubernetes ──────► Monitoring
   │                │                   │              │               │                  │
   │                │                   │              │               │                  │
   ▼                ▼                   ▼              ▼               ▼                  ▼
                                                                                          
1. Validate Parameters                                                                    
   ├─ Check action (START/STOP)                                                          
   ├─ Check environment                                                                   
   └─ Check numberAffectedNodes                                                          
                                                                                          
2. Configure OCI CLI                                                                      
   ├─ Download secure files                                                              
   ├─ Setup config & key                                                                 
   └─ Set permissions                                                                     
                                                                                          
3. Get Cluster Info                                                                       
   ├─ oci ce cluster get                                                                 
   └─ Return: Cluster State ACTIVE                                                       
                                                                                          
4. Get Node Pool Info                                                                     
   ├─ oci ce node-pool get                                                               
   └─ Return: Node Pool State                                                            
                                                                                          
5. Get Nodes Info                                                                         
   ├─ oci compute instance list                                                          
   └─ Return: Nodes List (RUNNING/STOPPED)                                               
                                                                                          
6. Validate Nodes Availability                                                            
   ├─ Count nodes in expected state                                                      
   └─ Compare with requested                                                             
                                                                                          
7. Execute Action on Nodes (if sufficient)                                                
   ├─ oci compute instance action --action START/STOP                                    
   └─ Action Started                                                                      
                                                                                          
8. If Action = START:                                                                     
   ├─ Wait Pods Running                                                                  
   ├─ Wait Jobs Complete                                                                 
   └─ Validate Final State                                                               
                                                                                          
Result: ✅ Success  OR  ❌ Fail (not enough nodes)                                        
```

---

### Monitoring Provisioner

```
┌───────────────────────────────────────────────────────────────────────┐
│                    SCHEDULED EXECUTION                                │
│                  Cron Trigger: Every 30 min                           │
└────────────────────────────────┬──────────────────────────────────────┘
                                 ↓
┌───────────────────────────────────────────────────────────────────────┐
│                   FOR EACH ENVIRONMENT                                │
│                                                                       │
│  1. SSH to Bastion                                                   │
│          ↓                                                            │
│  2. kubectl get pods                                                 │
│          ↓                                                            │
│  3. kubectl get nodes                                                │
│          ↓                                                            │
│  4. Parse Status                                                     │
│                                                                       │
└────────────────────────────────┬──────────────────────────────────────┘
                                 ↓
┌───────────────────────────────────────────────────────────────────────┐
│                         ANALYSIS                                      │
│                                                                       │
│  ┌─────────────┐      ┌─────────────┐                               │
│  │  Pods OK?   │      │  Nodes OK?  │                               │
│  └──────┬──────┘      └──────┬──────┘                               │
│         └──────────────┬──────┘                                       │
│                        ↓                                              │
│              ┌──────────────────┐                                    │
│              │ Generate Report  │                                    │
│              └────────┬─────────┘                                    │
│                       │                                               │
└───────────────────────┼───────────────────────────────────────────────┘
                        ↓
┌───────────────────────────────────────────────────────────────────────┐
│                      NOTIFICATIONS                                    │
│                                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │
│  │    Teams     │  │   Update     │  │    Save History          │  │
│  │   Webhook    │  │  Dashboard   │  │                          │  │
│  └──────────────┘  └──────────────┘  └──────────────────────────┘  │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
                                 ↓
┌───────────────────────────────────────────────────────────────────────┐
│                     OBSERVABILITY                                     │
│                                                                       │
│  1. Create/Update Markdown                                           │
│          ↓                                                            │
│  2. Cleanup Old Entries                                              │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
```

---

## 🎨 Modelo C4

### Nível 1: System Context

```
                           ┌────────────────────────────────┐
                           │           USERS                │
                           │  ┌──────────────────────────┐  │
                           │  │ Developers               │  │
                           │  │ DevOps Engineers         │  │
                           │  │ Platform Team            │  │
                           │  └────────────┬─────────────┘  │
                           └───────────────┼─────────────────┘
                                           │
                  Trigger, Configure & Manage
                                           │
                                           ↓
                           ┌────────────────────────────────┐
                           │   BRM FENIX FRAMEWORK          │
                           │                                │
                           └────────┬────────────────┬──────┘
                                    │                │
          ┌─────────────────────────┼────────────────┼──────────────────────┐
          │                         │                │                      │
          ↓                         ↓                ↓                      ↓
┌──────────────────┐   ┌──────────────────┐   ┌───────────────┐   ┌──────────────┐
│ Oracle Cloud     │   │ Azure DevOps     │   │ Azure         │   │ Fortify SCA  │
│ Infrastructure   │   │                  │   │ Container     │   │              │
│                  │   │                  │   │ Registry      │   │              │
└──────────────────┘   └──────────────────┘   └───────────────┘   └──────────────┘
                                               
┌──────────────────┐   ┌──────────────────┐
│ SonarQube        │   │ Microsoft Teams  │
│                  │   │                  │
└──────────────────┘   └──────────────────┘

Provision Resources     Execute Pipelines     Store Images         Security Scan
   Code Analysis            Send Alerts
```

### Nível 2: Container

```
┌──────────────────────────────────────────────────────────────────────┐
│                     BRM FENIX FRAMEWORK                              │
│                                                                      │
│  ┌─────────────────┐                                                │
│  │ Entrypoint      │                                                │
│  │ Router          │                                                │
│  └────────┬────────┘                                                │
│           │                                                          │
│           ├───────────┬─────────────┬─────────────┬─────────────┐  │
│           │           │             │             │             │  │
│           ↓           ↓             ↓             ↓             ↓  │
│  ┌────────────┐ ┌─────────┐ ┌──────────┐ ┌─────────────────┐   │  │
│  │    API     │ │   IaC   │ │Monitor-  │ │ Oracle Base     │   │  │
│  │  Default   │ │         │ │  ing     │ │ Image           │   │  │
│  │ Provisioner│ │Provision│ │Provision-│ │ Provisioner     │   │  │
│  └─────┬──────┘ └────┬────┘ │  er      │ └─────────────────┘   │  │
│        │             │       └────┬─────┘                        │  │
│        └──────┬──────┴────────────┘                              │  │
│               │                                                   │  │
│               ↓                                                   │  │
│  ┌──────────────────────────────────────────┐                   │  │
│  │        Task Groups Library                │                   │  │
│  └───────────────────┬──────────────────────┘                   │  │
│                      │                                            │  │
│                      ↓                                            │  │
│  ┌──────────────────────────────────────────┐                   │  │
│  │        Atomic Tasks Library               │                   │  │
│  └───────────────────┬──────────────────────┘                   │  │
│                      │                                            │  │
│  ┌──────────────────────────────────────────┐                   │  │
│  │        Global Variables                   │                   │  │
│  └──────────────────────────────────────────┘                   │  │
│                                                                      │
└─────────────────────────┬────────────────────────────────────────────┘
                          │
         ┌────────────────┼─────────────┬────────────────┐
         │                │             │                │
         ↓                ↓             ↓                ↓
┌────────────────┐ ┌─────────────┐ ┌──────────────┐ ┌──────────────┐
│ Variable       │ │ Secure      │ │ Service      │ │ External     │
│ Groups         │ │ Files       │ │ Connections  │ │ Dependencies │
└────────────────┘ └─────────────┘ └──────────────┘ └──────────────┘
```

### Nível 3: Component (API Default Provisioner)

```
┌──────────────────────────────────────────────────────────────────────┐
│              API Default Provisioner (Componentes)                    │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────────┐                                                 │
│  │ Provisioner     │                                                 │
│  │ Entry Point     │                                                 │
│  └────────┬────────┘                                                 │
│           │                                                           │
│           │                                                           │
│  ┌────────┼────────┬────────────────┬────────────────┐              │
│  │        │        │                │                │              │
│  ↓        ↓        ↓                ↓                ↓              │
│ ┌──┐    ┌──┐    ┌───┐            ┌───┐          ┌─────────┐        │
│ │CI│    │CD│    │Com│            │Var│          │  Tasks  │        │
│ └┬─┘    └┬─┘    └─┬─┘            └───┘          └─────────┘        │
│  │       │        │                                                  │
│  │       │        │                                                  │
├──┼───────┼────────┼──────────────────────────────────────────────────┤
│  │       │        │                                                  │
│  │       │        └──────────────────────────┐                       │
│  │       │                                   │                       │
│  ↓       ↓                                   ↓                       │
│ ┌──────────────────────┐  ┌──────────────────────┐  ┌─────────────┐│
│ │   CI Stages          │  │   CD Stages          │  │Common Stages││
│ │                      │  │                      │  │             ││
│ │ 1. Files             │  │ 1. Deploy            │  │1. Prepare   ││
│ │ 2. Build & Test      │  │ 2. Smoke Test        │  │2. Finish    ││
│ │ 3. Static Analysis   │  │ 3. Validate Version  │  │             ││
│ │ 4. Security Analysis │  │ 4. Update Assets     │  │             ││
│ │ 5. Bundle            │  │                      │  │             ││
│ │ 6. Trigger CD        │  │                      │  │             ││
│ └──────────────────────┘  └──────────────────────┘  └─────────────┘│
└──────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Fluxos de Dados

### Fluxo de Deploy (CI/CD)

```
┌────────────────────┐         ┌──────────────────────┐
│      Source        │         │   Quality & Security │
│                    │         │                      │
│  ┌──────────────┐  │         │  ┌────────────────┐  │
│  │ Git Repo     │  │         │  │ SonarQube      │  │
│  └──────┬───────┘  │         │  │ Analysis       │  │
│         │          │         │  └────────────────┘  │
│         ↓          │         │                      │
│  ┌──────────────┐  │         │  ┌────────────────┐  │
│  │ Application  │──┼─────────┼─→│ Fortify Scan   │  │
│  │ Code         │  │         │  └────────────────┘  │
│  └──────┬───────┘  │         │                      │
└─────────┼──────────┘         │  ┌────────────────┐  │
          │                    │  │ Docker Scan    │  │
          ↓                    │  └────────────────┘  │
┌────────────────────┐         └──────────────────────┘
│      Build         │
│                    │                    │
│  ┌──────────────┐  │                    │
│  │ Maven Build  │←─┼────────────────────┘
│  └──────┬───────┘  │
│         │          │
│         ├──────────┼─────→ (Maven Artifacts)
│         │          │                ↓
│         ↓          │         ┌─────────────┐
│  ┌──────────────┐  │         │   Nexus     │
│  │ Docker Build │  │         └─────────────┘
│  └──────┬───────┘  │
│         │          │
│         ↓          │
│  ┌──────────────┐  │
│  │  Artifacts   │  │
│  └──────┬───────┘  │
└─────────┼──────────┘
          │
          ↓
┌────────────────────┐         ┌──────────────────────┐
│     Registry       │         │    Deployment        │
│                    │         │                      │
│  ┌──────────────┐  │         │  ┌────────────────┐  │
│  │ ACR Docker   │──┼─────────┼─→│ Helm Chart     │  │
│  │ Images       │  │         │  │ Update         │  │
│  └──────────────┘  │         │  └────────┬───────┘  │
│                    │         │           │          │
│  ┌──────────────┐  │         │           ↓          │
│  │ Git Helm     │──┼─────────┼─→┌────────────────┐  │
│  │ Charts       │  │         │  │ Kubernetes     │  │
│  └──────────────┘  │         │  │ Apply          │  │
└────────────────────┘         │  └────────┬───────┘  │
                               │           │          │
                               │           ↓          │
                               │  ┌────────────────┐  │
                               │  │ Running Pods   │  │
                               │  └────────────────┘  │
                               └──────────────────────┘
```

### Fluxo de Infraestrutura (IaC)

```
┌──────────────────────┐
│       Input          │
│                      │
│  Pipeline Parameters │
│  ├─ Action: START/   │
│  │         STOP      │
│  ├─ Environment      │
│  └─ Number of Nodes  │
└──────────┬───────────┘
           │
           ↓
┌──────────────────────┐
│   OCI Discovery      │
│                      │
│  ├─ Get Cluster Info │
│  ├─ Get Node Pool    │
│  ├─ Get Nodes List   │
│  └─ Filter by State  │
└──────────┬───────────┘
           │
           ↓
┌──────────────────────┐
│    Validation        │
│                      │
│  ├─ Cluster State OK?│
│  ├─ Node Count OK?   │
│  └─ Sufficient Nodes?│
└──────────┬───────────┘
           │
           ↓
      ┌────┴─────┐
      │  Valid?  │
      └────┬─────┘
           │
    ┌──────┴──────┐
    │             │
    ↓             ↓
  ┌───┐         ┌───┐
  │Yes│         │No │
  └─┬─┘         └─┬─┘
    │             │
    ↓             ↓
┌──────────────┐  ┌──────────────────┐
│  Execution   │  │  Verification    │
│              │  │                  │
│ ├─ oci       │  │ ├─ Wait Pods    │
│ │   compute  │  │ │   Running     │
│ │   instance │  │ ├─ Wait Jobs    │
│ │   action   │  │ │   Complete    │
│ ├─ Node State│  │ └─ Validate     │
│ │   Change   │  │     Final State │
│ └─ Wait K8s  │  │                 │
│     Ready    │  │                 │
└──────┬───────┘  └────────┬─────────┘
       │                   │
       └─────────┬─────────┘
                 │
                 ↓
          ┌─────────────┐
          │   Success   │
          └─────────────┘
```

---

## 🧩 Componentes Técnicos

### Task Groups (Componentes Reutilizáveis)

#### OCI Configuration

```yaml
# Fluxo de Configuração OCI CLI
┌─────────────────────────────────────┐
│ Download Secure Files               │
│ • oci_config_brm_fenix              │
│ • oci_api_key_brm_fenix.pem         │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│ Create .oci Folder                  │
│ ~/.oci_fenix/                       │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│ Move Files & Configure Paths        │
│ • Update key_file path in config   │
│ • Set environment variables         │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│ Set Permissions                     │
│ • oci setup repair-file-permissions │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│ Validate OCI CLI                    │
│ • oci --version                     │
│ • Test connection                   │
└─────────────────────────────────────┘
```

### Atomic Tasks

```
┌───────────────────────────────────────────────────────────────────────┐
│                        Atomic Tasks (Granular)                         │
├───────────────────────────────────────────────────────────────────────┤
│                                                                        │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐         │
│  │  Build Tasks   │  │   Test Tasks   │  │  Deploy Tasks  │         │
│  │                │  │                │  │                │         │
│  │ • Maven Build  │  │ • Unit Tests   │  │ • Helm Install │         │
│  │ • Docker Build │  │ • Smoke Tests  │  │ • Helm Upgrade │         │
│  │ • Bundle       │  │ • Integration  │  │ • SSH Deploy   │         │
│  │   Artifacts    │  │   Tests        │  │                │         │
│  └────────────────┘  └────────────────┘  └────────────────┘         │
│                                                                        │
│  ┌────────────────┐  ┌────────────────┐                              │
│  │ Validation     │  │   OCI Tasks    │                              │
│  │    Tasks       │  │                │                              │
│  │                │  │ • Get Cluster  │                              │
│  │ • Check Errors │  │ • Get Node Pool│                              │
│  │ • Validate     │  │ • Get Nodes    │                              │
│  │   Version      │  │                │                              │
│  │ • Verify BRM   │  │                │                              │
│  │   Apps         │  │                │                              │
│  └────────────────┘  └────────────────┘                              │
│                                                                        │
└───────────────────────────────────────────────────────────────────────┘
```

---

## 🔐 Segurança

### Arquitetura de Segurança

```
┌────────────────────────────────────────────────────────────────────────┐
│                    Security Architecture (5 Layers)                     │
├────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐    │
│  │ Authentication   │  │ Authorization    │  │ Secret Mgmt      │    │
│  │                  │  │                  │  │                  │    │
│  │ • Azure AD       │  │ • RBAC Azure     │  │ • Secure Files   │    │
│  │ • OCI API Keys   │  │ • IAM OCI        │  │ • Variable Groups│    │
│  │ • SSH Keys       │  │ • K8s RBAC       │  │ • Service Conn.  │    │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘    │
│           │                     │                     │               │
│           └──────────┬──────────┴──────────┬──────────┘               │
│                      │                     │                          │
│                      ↓                     ↓                          │
│           ┌──────────────────┐  ┌──────────────────┐                 │
│           │ Network Security │  │  Code Security   │                 │
│           │                  │  │                  │                 │
│           │ • Bastion Host   │  │ • Fortify SCA    │                 │
│           │ • Private Networks│  │ • SonarQube     │                 │
│           │ • Firewall Rules │  │ • Docker Scan    │                 │
│           └──────────────────┘  └──────────────────┘                 │
│                                                                         │
└────────────────────────────────────────────────────────────────────────┘
```

### Camadas de Segurança

| Camada | Controles | Implementação |
|--------|-----------|---------------|
| **Application** | Code scanning, dependency check | Fortify SCA, SonarQube |
| **Container** | Image scanning, runtime protection | Docker Scan, ACR |
| **Orchestration** | RBAC, network policies, secrets | Kubernetes RBAC, OCI IAM |
| **Infrastructure** | Bastion host, private networks | OCI VCN, Security Lists |
| **Pipeline** | Secure files, encrypted variables | Azure DevOps Security |
| **Identity** | MFA, RBAC, audit logs | Azure AD, OCI IAM |

---

## ⚡ Escalabilidade

### Horizontal Scaling

```
┌────────────────────────────────────────────────────────────────────────┐
│                    Horizontal Scaling Strategy                          │
├────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────────┐       ┌──────────────────┐       ┌──────────────┐
│  │ Pipeline Agents  │       │ Kubernetes Nodes │       │ Application  │
│  │                  │       │                  │       │    Pods      │
│  │ • Agent Pool 1   │──────→│ • Node Pool 1    │──────→│ • Replicas:  │
│  │   Max: 10        │       │   3-10 nodes     │       │   2-20       │
│  │                  │       │                  │       │              │
│  │ • Agent Pool 2   │──────→│ • Node Pool 2    │──────→│ • HPA        │
│  │   Max: 10        │       │   3-10 nodes     │       │   Enabled    │
│  │                  │       │                  │       │              │
│  │ • Agent Pool 3   │──────→│ • Node Pool 3    │──────→│ • Auto-      │
│  │   Max: 10        │       │   3-10 nodes     │       │   scaling    │
│  └──────────────────┘       └──────────────────┘       └──────────────┘
│                                                                         │
│  Total Capacity: 30 agents → 30 nodes → 60-600 pods                   │
└────────────────────────────────────────────────────────────────────────┘
```

### Vertical Scaling

| Componente | Min Resources | Max Resources | Auto-scaling |
|------------|---------------|---------------|--------------|
| **Pipeline Agents** | 2 CPU, 4GB RAM | 8 CPU, 16GB RAM | ✅ Queue-based |
| **Kubernetes Nodes** | 4 CPU, 16GB RAM | 16 CPU, 64GB RAM | ✅ OKE Autoscaler |
| **BRM Pods** | 1 CPU, 2GB RAM | 4 CPU, 8GB RAM | ✅ HPA |
| **Database** | 2 OCPU, 16GB RAM | 8 OCPU, 64GB RAM | ✅ Manual |

---

## 🛡️ Alta Disponibilidade

### Multi-AZ Deployment

```
                         ┌─────────────────────┐
                         │  OCI Load Balancer  │
                         └──────────┬──────────┘
                                    │
               ┌────────────────────┼────────────────────┐
               │                    │                    │
               ↓                    ↓                    ↓
┌──────────────────────┐ ┌──────────────────────┐ ┌──────────────────────┐
│ Availability Domain 1│ │ Availability Domain 2│ │ Availability Domain 3│
│                      │ │                      │ │                      │
│  ┌────────────────┐  │ │  ┌────────────────┐  │ │  ┌────────────────┐  │
│  │  OKE Node 1    │  │ │  │  OKE Node 2    │  │ │  │  OKE Node 3    │  │
│  │                │  │ │  │                │  │ │  │                │  │
│  │  BRM Pods      │  │ │  │  BRM Pods      │  │ │  │  BRM Pods      │  │
│  └────────────────┘  │ │  └────────────────┘  │ │  └────────────────┘  │
│                      │ │                      │ │                      │
└──────────────────────┘ └──────────────────────┘ └──────────────────────┘

┌────────────────────────────────────────────────────────────────────────┐
│                           Database Layer                                │
│                                                                         │
│    ┌──────────────────────┐           ┌──────────────────────┐         │
│    │   Primary Database   │           │   Standby Database   │         │
│    │   (AD1)              │──────────→│   (AD2)              │         │
│    │                      │           │                      │         │
│    │  Active R/W          │Replication│  Passive R/O         │         │
│    └──────────────────────┘           └──────────────────────┘         │
│                                                                         │
└────────────────────────────────────────────────────────────────────────┘
```

### Disaster Recovery

| Componente | RPO | RTO | Strategy |
|------------|-----|-----|----------|
| **Pipeline Code** | 0 | 5 min | Git replication |
| **Container Images** | 0 | 10 min | ACR geo-replication |
| **Kubernetes Config** | 0 | 15 min | Helm Charts in Git |
| **Database** | 1 hour | 4 hours | Oracle Data Guard |
| **Secrets** | 0 | 5 min | Azure DevOps backup |

---

## 📊 Métricas de Arquitetura

### Performance Targets

| Métrica | Target | Atual | SLA |
|---------|--------|-------|-----|
| **Pipeline CI Execution** | <10 min | 8 min | 95% |
| **Pipeline CD Execution** | <15 min | 12 min | 95% |
| **IaC START Execution** | <20 min | 15 min | 90% |
| **Monitoring Execution** | <5 min | 3 min | 99% |
| **Deployment Success Rate** | >95% | 97% | 95% |

### Capacity Planning

```
Current Capacity          6 Months Projection       12 Months Projection
─────────────────         ───────────────────       ────────────────────

┌──────────────┐          ┌──────────────┐          ┌──────────────┐
│ 10 Envs      │─────────→│ 15 Envs      │─────────→│ 20 Envs      │
└──────────────┘          └──────────────┘          └──────────────┘

┌──────────────┐          ┌──────────────┐          ┌──────────────┐
│ 15 Apps      │─────────→│ 25 Apps      │─────────→│ 40 Apps      │
└──────────────┘          └──────────────┘          └──────────────┘

┌──────────────┐          ┌──────────────┐          ┌──────────────┐
│ 50 Nodes     │─────────→│ 100 Nodes    │─────────→│ 200 Nodes    │
└──────────────┘          └──────────────┘          └──────────────┘

┌──────────────┐          ┌──────────────┐          ┌──────────────┐
│ 200 Pods     │─────────→│ 400 Pods     │─────────→│ 800 Pods     │
└──────────────┘          └──────────────┘          └──────────────┘

Growth Trend: +50% every 6 months
```

---

## 📄 Referências Técnicas

- [Azure DevOps YAML Pipelines](https://learn.microsoft.com/azure/devops/pipelines/yaml-schema/)
- [Oracle Cloud Infrastructure Architecture](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/architecture.htm)
- [Kubernetes Architecture](https://kubernetes.io/docs/concepts/architecture/)
- [Helm Architecture](https://helm.sh/docs/topics/architecture/)
- [C4 Model](https://c4model.com/)

---

**Última Atualização:** 2 de Janeiro de 2026  
**Versão da Arquitetura:** 1.1.0  
**Autores:** BRM Fenix Architecture Team
