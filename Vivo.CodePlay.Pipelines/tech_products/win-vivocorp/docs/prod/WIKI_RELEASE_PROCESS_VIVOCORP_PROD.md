# 📘 Processo de Release VivoCorp - Ambiente de Produção

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Arquitetura e Componentes](#arquitetura-e-componentes)
- [Fluxo Completo de Release](#fluxo-completo-de-release)
- [Processos Detalhados](#processos-detalhados)
  - [1. Versionamento e Controle Git](#1-versionamento-e-controle-git)
  - [2. Importação de Artefatos Siebel](#2-importação-de-artefatos-siebel)
  - [3. Gerenciamento de Servidores](#3-gerenciamento-de-servidores)
  - [4. Distribuição de Arquivos SRF](#4-distribuição-de-arquivos-srf)
  - [5. Processamento ADM](#5-processamento-adm)
  - [6. Ativação de Componentes](#6-ativação-de-componentes)
- [Características Técnicas](#características-técnicas)
- [Padrões e Boas Práticas](#padrões-e-boas-práticas)
- [Monitoramento e Troubleshooting](#monitoramento-e-troubleshooting)

---

## 🎯 Visão Geral

O processo de release do **VivoCorp em Produção** é um pipeline automatizado que gerencia o deploy de atualizações do Siebel CRM v8.1 através de scripts batch executados em pipelines Azure DevOps.

### Principais Características

| Característica | Descrição |
|----------------|-----------|
| **Plataforma** | Windows Server + Siebel CRM 8.1 |
| **Orquestração** | Azure DevOps Pipelines |
| **Automação** | Scripts Batch (.bat) avançados |
| **Infraestrutura** | 12 servidores Linux (RHEL) + Servidor Windows de deploy |
| **Protocolos** | SSH, SFTP, Git |
| **Artefatos** | SRF (Siebel Repository File), SIF (Siebel Import File), XML (ADM) |

### Objetivos do Processo

✅ **Versionamento rastreável** com Git  
✅ **Deploy controlado** com checkpoints e validações  
✅ **Alta disponibilidade** durante releases  
✅ **Rollback rápido** em caso de problemas  
✅ **Auditoria completa** com logs estruturados  
✅ **Automação end-to-end** com mínima intervenção manual

---

## 🏗️ Arquitetura e Componentes

### Infraestrutura

```mermaid
graph TB
    subgraph "Azure DevOps"
        AZ[Azure Pipeline]
    end
    
    subgraph "Windows Deploy Server"
        WS[Servidor Windows<br/>C:\Siebel_Devops\PROD\]
        REPO[Repositório Git Local]
        SCRIPTS[Scripts Batch]
    end
    
    subgraph "Siebel Infrastructure - PROD"
        subgraph "Servidores 1-2"
            S1[10.238.7.12<br/>siebelsrv1]
            S2[10.238.7.12<br/>siebelsrv2]
        end
        
        subgraph "Servidores 3-8"
            S3[10.238.5.32<br/>siebelsrv3-8]
        end
        
        subgraph "Servidores 9-12"
            S9[10.238.5.33<br/>siebelsrv9-12]
        end
        
        subgraph "Servidor ADM"
            ADM[10.238.7.12<br/>ADM Gateway]
        end
    end
    
    AZ -->|Trigger Pipeline| WS
    WS -->|SSH/SFTP| S1
    WS -->|SSH/SFTP| S2
    WS -->|SSH/SFTP| S3
    WS -->|SSH/SFTP| S9
    WS -->|SSH/SFTP| ADM
    
    REPO -.->|Git Clone| WS
    SCRIPTS -.->|Executados por| WS
```

### Componentes Principais

#### 📁 Estrutura de Diretórios

```
C:\Siebel_Devops\PROD\
├── ambientes\
│   └── src-vivocorp-prod\          # Repositório Git clonado
│       └── Siebel Repository\
│           ├── Objects\             # Objetos Siebel (.xml)
│           ├── Projects\            # Projetos (.xml)
│           ├── Webtemps\            # Web Templates (.xml)
│           ├── Workflows\           # Workflows (.xml)
│           └── Repository\          # Repository Files (.sif)
├── srf\
│   └── siebel_sia_new.srf          # Arquivo SRF compilado
├── adm\                             # Arquivos ADM XML
└── scripts\                         # Scripts de automação
```

#### 🔧 Scripts de Automação

| Categoria | Scripts | Propósito |
|-----------|---------|-----------|
| **Versionamento** | `git_prod_az.bat`<br/>`limpa_repo_az.bat` | Clonagem, limpeza e gerenciamento Git |
| **Importação** | `import_az.bat` | Importação de arquivos SIF para repositório |
| **Gerenciamento Servidores** | `start_srv_new_az.bat`<br/>`stop_srv_az.bat`<br/>`check_srv.bat` | Controle de servidores Siebel |
| **Distribuição SRF** | `sftp_srf_new_az.bat`<br/>`rename_srf_az.bat` | Transferência e ativação de SRF |
| **Processamento ADM** | `adm_get_new_az.bat`<br/>`adm_import_new_az.bat` | Exportação e importação de configurações ADM |
| **Ativação Componentes** | `active_rs_az.bat`<br/>`active_task_az.bat`<br/>`active_wf_az.bat` | Ativação de Record Sets, Tasks e Workflows |
| **Compilação** | `Compile.bat` | Compilação de repositório Siebel |

---

## 🔄 Fluxo Completo de Release

### Pipeline End-to-End

```mermaid
flowchart TD
    START([Início do Pipeline]) --> PREP[Preparação do Ambiente]
    
    PREP --> GIT{Versionamento Git}
    GIT -->|Clean| CLEAN[limpa_repo_az.bat]
    GIT -->|Clone| CLONE[git_prod_az.bat]
    
    CLEAN --> CLONE
    CLONE --> IMPORT[Importação SIF<br/>import_az.bat]
    
    IMPORT --> COMPILE[Compilação Siebel<br/>Compile.bat]
    
    COMPILE --> STOP[Parar Servidores<br/>stop_srv_az.bat]
    
    STOP --> BACKUP{Backup Atual}
    BACKUP --> RENAME[Rename SRF Antigo<br/>rename_srf_az.bat]
    
    RENAME --> SFTP[Distribuir Novo SRF<br/>sftp_srf_new_az.bat]
    
    SFTP --> START[Iniciar Servidores<br/>start_srv_new_az.bat]
    
    START --> CHECK{Health Check}
    CHECK -->|Falha| ROLLBACK[Rollback]
    CHECK -->|Sucesso| ADM[Processar ADM]
    
    ADM --> ADM_GET[Exportar ADM<br/>adm_get_new_az.bat]
    ADM_GET --> ADM_IMPORT[Importar ADM<br/>adm_import_new_az.bat]
    
    ADM_IMPORT --> ACTIVE{Ativar Componentes}
    ACTIVE --> RS[Record Sets<br/>active_rs_az.bat]
    ACTIVE --> TASK[Tasks<br/>active_task_az.bat]
    ACTIVE --> WF[Workflows<br/>active_wf_az.bat]
    
    RS --> VALIDATE
    TASK --> VALIDATE
    WF --> VALIDATE
    
    VALIDATE{Validação Final} -->|Sucesso| SUCCESS([Release Completo])
    VALIDATE -->|Falha| ROLLBACK
    
    ROLLBACK --> FAIL([Release Falhado])
    
    style START fill:#90EE90
    style SUCCESS fill:#90EE90
    style FAIL fill:#FF6B6B
    style ROLLBACK fill:#FFD700
    style CHECK fill:#87CEEB
    style VALIDATE fill:#87CEEB
```

### Timeline Estimado

```mermaid
gantt
    title Timeline de Release em Produção
    dateFormat HH:mm
    axisFormat %H:%M
    
    section Preparação
    Limpeza Repositório     :prep1, 00:00, 2m
    Clone Git              :prep2, after prep1, 5m
    Importação SIF         :prep3, after prep2, 10m
    
    section Build
    Compilação Siebel      :build1, after prep3, 15m
    
    section Deploy
    Parar Servidores       :deploy1, after build1, 5m
    Backup SRF             :deploy2, after deploy1, 2m
    Distribuir SRF (12 srv):deploy3, after deploy2, 8m
    Iniciar Servidores     :deploy4, after deploy3, 10m
    
    section Configuração
    Exportar ADM           :config1, after deploy4, 5m
    Importar ADM           :config2, after config1, 5m
    
    section Ativação
    Ativar Record Sets     :active1, after config2, 3m
    Ativar Tasks           :active2, after config2, 3m
    Ativar Workflows       :active3, after config2, 3m
    
    section Validação
    Health Checks          :val1, after active3, 5m
```

**⏱️ Tempo Total Estimado:** ~75 minutos (1h15min)

---

## 📊 Processos Detalhados

### 1. Versionamento e Controle Git

#### Fluxo Git

```mermaid
flowchart LR
    A[Azure DevOps<br/>Repository] -->|Clone com Tags| B[C:\Siebel_Devops\PROD\ambientes\]
    
    B --> C{Repositório<br/>Existente?}
    C -->|Sim| D[limpa_repo_az.bat<br/>Remove diretório]
    C -->|Não| E[git_prod_az.bat]
    
    D --> E
    
    E --> F[Git Clone]
    F --> G[Checkout Tag/Branch]
    G --> H[Repositório Pronto]
    
    H --> I[Arquivos .xml/.sif<br/>Disponíveis]
    
    style A fill:#0078D4
    style H fill:#90EE90
```

#### Scripts Envolvidos

**🔹 limpa_repo_az.bat**
- **Propósito:** Limpar repositório Git existente para clone limpo
- **Ações:**
  - Remove flags de somente-leitura recursivamente
  - Deleta diretório `src-vivocorp-prod`
  - Valida remoção bem-sucedida
- **Output:** Diretório limpo para novo clone

**🔹 git_prod_az.bat**
- **Propósito:** Clonar repositório Git do Azure DevOps
- **Ações:**
  - Navega para `C:\Siebel_Devops\PROD\ambientes\`
  - Clona repositório com tags
  - Valida clone bem-sucedido
  - Gera timestamp para rastreabilidade
- **Autenticação:** Token de serviço `svc_vcorops`
- **Output:** Repositório Git clonado com todos os artefatos

#### Estrutura do Repositório Clonado

```
src-vivocorp-prod\
└── Siebel Repository\
    ├── Objects\              # Business Components, Applets, Views
    ├── Projects\             # Projetos Siebel
    ├── Webtemps\            # Templates Web
    ├── Workflows\           # Processos de workflow
    └── Repository\          # Arquivos .sif para importação
```

---

### 2. Importação de Artefatos Siebel

#### Fluxo de Importação

```mermaid
flowchart TD
    START([Início Import]) --> CHECK_DIR[Navegar para Diretório<br/>C:\Siebel_Devops\PROD\ambientes\<br/>src-vivocorp-prod\<br/>Siebel Repository\Repository]
    
    CHECK_DIR --> CHECK_FILES{Arquivos .sif<br/>Existem?}
    
    CHECK_FILES -->|Não| ERROR1[ERRO: Arquivos não encontrados]
    CHECK_FILES -->|Sim| COUNT[Contar Arquivos .sif]
    
    COUNT --> LOOP{Para cada<br/>arquivo .sif}
    
    LOOP --> IMPORT_CMD[Executar siebdev.exe<br/>/c import /u SADMIN /p *** /f arquivo.sif]
    
    IMPORT_CMD --> CHECK_ERR{ERRORLEVEL<br/>= 0?}
    
    CHECK_ERR -->|Erro| LOG_FAIL[Log: Falha na importação<br/>Incrementar failCount]
    CHECK_ERR -->|Sucesso| LOG_SUCCESS[Log: Importação bem-sucedida<br/>Incrementar successCount]
    
    LOG_FAIL --> NEXT1{Mais arquivos?}
    LOG_SUCCESS --> NEXT2{Mais arquivos?}
    
    NEXT1 -->|Sim| LOOP
    NEXT2 -->|Sim| LOOP
    
    NEXT1 -->|Não| REPORT
    NEXT2 -->|Não| REPORT
    
    REPORT[Relatório Final:<br/>Total: X arquivos<br/>Sucesso: Y<br/>Falha: Z]
    
    REPORT --> CLEANUP[Limpar Flags SSH<br/>em Servidores Remotos]
    
    CLEANUP --> END([Fim Import])
    
    ERROR1 --> END
    
    style START fill:#90EE90
    style END fill:#90EE90
    style ERROR1 fill:#FF6B6B
    style CHECK_ERR fill:#FFD700
```

#### Script: import_az.bat

**Características Principais:**
- ✅ **Loop Automático:** Processa todos os `.sif` no diretório
- ✅ **Contador de Sucessos/Falhas:** Estatísticas de importação
- ✅ **Tratamento de Erros:** Valida cada importação
- ✅ **Limpeza de Flags:** Remove flags SSH após importação
- ✅ **Logs Estruturados:** Cada etapa documentada

**Comando de Importação:**
```batch
siebdev.exe /c import /u SADMIN /p PASSWORD /f "%%~nxf"
```

**Parâmetros:**
- `/c import` - Comando de importação
- `/u SADMIN` - Usuário administrador Siebel
- `/p PASSWORD` - Senha do usuário
- `/f arquivo.sif` - Arquivo Siebel Import File

**Output Esperado:**
```
========================================
[001/015] Importando: VIVO_Project_v1.sif
========================================
Tamanho: 2.5 MB
[SUCESSO] Importação concluída: VIVO_Project_v1.sif

Estatísticas finais:
Total de arquivos: 15
Importados com sucesso: 15
Falhas: 0
```

---

### 3. Gerenciamento de Servidores

#### Fluxo de Start/Stop

```mermaid
sequenceDiagram
    participant Pipeline
    participant Script as Script Batch
    participant Server1 as Servidor 1<br/>(10.238.7.12/srv1)
    participant Server2 as Servidor 2<br/>(10.238.7.12/srv2)
    participant Servers38 as Servidores 3-8<br/>(10.238.5.32)
    participant Servers912 as Servidores 9-12<br/>(10.238.5.33)
    
    Note over Pipeline,Servers912: STOP SEQUENCE
    
    Pipeline->>Script: stop_srv_az.bat
    
    Script->>Server1: SSH: stop_srv.sh
    Server1-->>Script: OK (ERRORLEVEL 0)
    
    Script->>Server2: SSH: stop_srv.sh
    Server2-->>Script: OK (ERRORLEVEL 0)
    
    Script->>Servers38: SSH: stop_srv.sh (bulk)
    Servers38-->>Script: OK
    
    Script->>Servers912: SSH: stop_srv.sh (bulk)
    Servers912-->>Script: OK
    
    Script-->>Pipeline: Relatório: 4 grupos parados
    
    Note over Pipeline,Servers912: START SEQUENCE
    
    Pipeline->>Script: start_srv_new_az.bat
    
    Script->>Server1: SSH: start_srv.sh &
    Server1-->>Script: Comando enviado
    Script->>Server1: Delay 260s
    Note over Server1: Estabilização<br/>(~4.3 min)
    
    Script->>Server2: SSH: start_srv.sh &
    Server2-->>Script: Comando enviado
    Script->>Server2: Delay 260s
    Note over Server2: Estabilização<br/>(~4.3 min)
    
    Script-->>Pipeline: Relatório: 2 servidores iniciados
```

#### Scripts de Controle

**🔹 stop_srv_az.bat**
- **Propósito:** Parar todos os servidores Siebel antes do deploy
- **Sequência:**
  1. Para servidor 1 (10.238.7.12/siebelsrv1)
  2. Para servidor 2 (10.238.7.12/siebelsrv2)
  3. Para servidores 3-8 (10.238.5.32)
  4. Para servidores 9-12 (10.238.5.33)
- **Validação:** Verifica ERRORLEVEL de cada comando SSH
- **Segurança:** Script não-bloqueante (exit /B 0)

**🔹 start_srv_new_az.bat**
- **Propósito:** Iniciar servidores Siebel com delays de estabilização
- **Características:**
  - ⏱️ **Delay de 260 segundos** (4min 20s) após cada start
  - 📊 **Contadores:** totalServers, successCount, failCount
  - 🕐 **Timestamps:** Registra hora de início/fim de delays
  - ⚠️ **Error Handling:** Labels e gotos para falhas
- **Sequência:**
  1. Inicia servidor 1 → Aguarda 260s
  2. Inicia servidor 2 → Aguarda 260s
  3. Relatório final

**🔹 check_srv.bat**
- **Propósito:** Verificar status dos servidores
- **Validações:**
  - Processos Siebel rodando
  - Portas abertas
  - Conectividade SSH

---

### 4. Distribuição de Arquivos SRF

#### Arquitetura SRF

O arquivo **SRF (Siebel Repository File)** é o binário compilado do repositório Siebel que contém toda a metadata de configuração, objetos de negócio, views, applets e lógica.

```mermaid
flowchart TB
    subgraph "Origem"
        SRC[C:\Siebel_Devops\PP\srf\<br/>siebel_sia_new.srf]
    end
    
    subgraph "Staging"
        STAGE[C:\Siebel_Devops\PROD\srf\<br/>siebel_sia_new.srf]
    end
    
    subgraph "Backup Produção"
        BACKUP[Renomear SRF Existente<br/>siebel_sia.srf → siebel_sia_YYYYMMDD_HHMMSS.srf]
    end
    
    subgraph "Servidores Produção"
        S38[Servidores 3-8<br/>10.238.5.32]
        S912[Servidores 9-12<br/>10.238.5.33]
        S1[Servidor 1<br/>10.238.7.12]
        S2[Servidor 2<br/>10.238.7.12]
    end
    
    SRC -->|Copy se não existe| STAGE
    
    STAGE -->|rename_srf_az.bat| BACKUP
    
    BACKUP -->|SFTP| S38
    BACKUP -->|SFTP| S912
    BACKUP -->|SFTP| S1
    BACKUP -->|SFTP| S2
    
    S38 -->|SSH: Rename| ACTIVE38[siebel_sia_new.srf → siebel_sia.srf]
    S912 -->|SSH: Rename| ACTIVE912[siebel_sia_new.srf → siebel_sia.srf]
    
    style SRC fill:#87CEEB
    style BACKUP fill:#FFD700
    style ACTIVE38 fill:#90EE90
    style ACTIVE912 fill:#90EE90
```

#### Fluxo de Distribuição

```mermaid
flowchart TD
    START([Início Distribuição SRF]) --> CHECK_LOCAL{SRF Local<br/>Existe?}
    
    CHECK_LOCAL -->|Não| COPY[Copiar de PP para PROD]
    CHECK_LOCAL -->|Sim| RENAME_SCRIPT
    
    COPY --> RENAME_SCRIPT[rename_srf_az.bat]
    
    RENAME_SCRIPT --> LOOP_RENAME{Para cada<br/>servidor}
    
    LOOP_RENAME --> SSH_RENAME[SSH: Renomear SRF antigo<br/>siebel_sia.srf → siebel_sia_TIMESTAMP.srf]
    
    SSH_RENAME --> CHECK_RENAME{Rename<br/>OK?}
    
    CHECK_RENAME -->|Erro| LOG_RENAME_FAIL[Log: Falha no rename<br/>failCount++]
    CHECK_RENAME -->|Sucesso| LOG_RENAME_OK[Log: Backup criado<br/>successCount++]
    
    LOG_RENAME_FAIL --> NEXT_RENAME{Mais servidores?}
    LOG_RENAME_OK --> NEXT_RENAME
    
    NEXT_RENAME -->|Sim| LOOP_RENAME
    NEXT_RENAME -->|Não| SFTP_SCRIPT
    
    SFTP_SCRIPT[sftp_srf_new_az.bat] --> LOOP_SFTP{Para cada<br/>servidor}
    
    LOOP_SFTP --> SFTP_TRANSFER[SFTP: Transferir siebel_sia_new.srf]
    
    SFTP_TRANSFER --> CHECK_SFTP{SFTP<br/>OK?}
    
    CHECK_SFTP -->|Erro| LOG_SFTP_FAIL[Log: Falha na transferência<br/>failCount++]
    CHECK_SFTP -->|Sucesso| SSH_ACTIVATE[SSH: Ativar novo SRF<br/>mv siebel_sia_new.srf → siebel_sia.srf]
    
    SSH_ACTIVATE --> CHECK_ACTIVATE{Ativação<br/>OK?}
    
    CHECK_ACTIVATE -->|Erro| LOG_ACTIVATE_FAIL[Log: Falha na ativação]
    CHECK_ACTIVATE -->|Sucesso| LOG_ACTIVATE_OK[Log: SRF ativado<br/>successCount++]
    
    LOG_SFTP_FAIL --> NEXT_SFTP{Mais servidores?}
    LOG_ACTIVATE_FAIL --> NEXT_SFTP
    LOG_ACTIVATE_OK --> NEXT_SFTP
    
    NEXT_SFTP -->|Sim| LOOP_SFTP
    NEXT_SFTP -->|Não| REPORT
    
    REPORT[Relatório Final:<br/>Total: 12 servidores<br/>Sucesso: X<br/>Falha: Y]
    
    REPORT --> END([Fim Distribuição])
    
    style START fill:#90EE90
    style END fill:#90EE90
    style CHECK_RENAME fill:#FFD700
    style CHECK_SFTP fill:#FFD700
    style CHECK_ACTIVATE fill:#FFD700
```

#### Scripts de Distribuição

**🔹 rename_srf_az.bat**
- **Propósito:** Backup do SRF existente nos servidores
- **Padrão de Backup:** `siebel_sia_YYYYMMDD_HHMMSS.srf`
- **Grupos de Servidores:**
  - Servidores 3-8: 10.238.5.32
  - Servidores 9-12: 10.238.5.33
- **Comando SSH:**
  ```batch
  ssh pcpweb@10.238.5.32 "for d in siebelsrv{3..8}; do sudo -u supweb mv /.../siebel_sia.srf /.../siebel_sia_%timestamp%.srf; done"
  ```

**🔹 sftp_srf_new_az.bat**
- **Propósito:** Distribuir e ativar novo SRF em 12 servidores
- **Processo por Servidor:**
  1. **Validar** arquivo fonte existe
  2. **Copiar** de PP para PROD (se necessário)
  3. **SFTP** transferir `siebel_sia_new.srf`
  4. **SSH** renomear para `siebel_sia.srf`
  5. **Validar** cada etapa com ERRORLEVEL
- **Contadores:**
  - `totalServers`: 12
  - `successCount`: Transferências bem-sucedidas
  - `failCount`: Falhas

**Exemplo de Comando SFTP:**
```batch
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.5.32 22
```

**Conteúdo de sftp_put_prod_new.txt:**
```
put C:\Siebel_Devops\PROD\srf\siebel_sia_new.srf /remote/path/siebel_sia_new.srf
quit
```

---

### 5. Processamento ADM

#### O que é ADM?

**ADM (Application Deployment Manager)** é o componente do Siebel que gerencia configurações de runtime, como:
- Parâmetros de componentes
- Assignment rules
- Políticas de workflow
- Configurações de sincronização móvel

Essas configurações são armazenadas em arquivos XML e importadas para o banco de dados Siebel.

#### Fluxo ADM

```mermaid
flowchart LR
    subgraph "Exportação"
        A[Servidor ADM<br/>10.238.7.12] -->|adm_get_new_az.bat| B[Exportar XMLs<br/>via SSH]
        B -->|SFTP| C[C:\Siebel_Devops\PROD\adm\<br/>*.xml]
    end
    
    subgraph "Importação"
        C -->|adm_import_new_az.bat| D{Para cada<br/>XML}
        D --> E[siebdev.exe<br/>/c admimport]
        E --> F{ERRORLEVEL<br/>= 0?}
        F -->|Sim| G[Configuração<br/>Aplicada]
        F -->|Não| H[Erro Registrado]
    end
    
    subgraph "Resultado"
        G --> I[Configurações ADM<br/>Atualizadas no DB]
    end
    
    style A fill:#87CEEB
    style C fill:#FFD700
    style I fill:#90EE90
    style H fill:#FF6B6B
```

#### Scripts ADM

**🔹 adm_get_new_az.bat**
- **Propósito:** Exportar configurações ADM do servidor para XML
- **Processo:**
  1. Conecta via SSH em 10.238.7.12
  2. Executa comando de exportação ADM
  3. Copia XMLs via SFTP para `C:\Siebel_Devops\PROD\adm\`
  4. Valida arquivos recebidos
- **Arquivos Exportados:**
  - `ADM_Config_Component.xml`
  - `ADM_Config_Assignment.xml`
  - `ADM_Config_Workflow.xml`
  - etc.

**🔹 adm_import_new_az.bat**
- **Propósito:** Importar configurações ADM do XML para o banco de dados
- **Características:**
  - ✅ Loop automático sobre todos os XMLs em `C:\Siebel_Devops\PROD\adm\`
  - ✅ Validação de existência de arquivos
  - ✅ Contador de sucessos/falhas
  - ✅ Logs detalhados por arquivo
- **Comando de Importação:**
  ```batch
  siebdev.exe /c admimport /u SADMIN /p PASSWORD /f "%%~nxf"
  ```

**Exemplo de Output:**
```
========================================
[ADM] Processando arquivo 1/5
========================================
Arquivo: ADM_Config_Component.xml
Tamanho: 512 KB

[SUCESSO] Importação ADM concluída: ADM_Config_Component.xml

Estatísticas de importação:
Total de arquivos: 5
Importados com sucesso: 5
Falhas: 0
```

---

### 6. Ativação de Componentes

Após a importação de artefatos e configurações, componentes específicos do Siebel precisam ser ativados/desativados para aplicar as mudanças.

#### Tipos de Componentes

```mermaid
graph TB
    subgraph "Componentes Siebel"
        RS[Record Sets<br/>🗂️]
        TASK[Tasks<br/>⚙️]
        WF[Workflows<br/>🔄]
    end
    
    RS -->|Ativa/Desativa| RS_DESC[Conjuntos de Registros<br/>Entidades de Dados]
    TASK -->|Ativa/Desativa| TASK_DESC[Tarefas Agendadas<br/>Jobs Batch]
    WF -->|Ativa/Desativa| WF_DESC[Processos de Negócio<br/>Fluxos Automatizados]
    
    RS_DESC --> DB[(Siebel Database)]
    TASK_DESC --> DB
    WF_DESC --> DB
    
    style RS fill:#87CEEB
    style TASK fill:#FFD700
    style WF fill:#90EE90
```

#### Fluxo de Ativação

```mermaid
sequenceDiagram
    participant Pipeline
    participant RS as active_rs_az.bat
    participant TASK as active_task_az.bat
    participant WF as active_wf_az.bat
    participant Server as 10.238.7.12
    participant DB as Siebel DB
    
    Pipeline->>RS: Ativar Record Sets
    
    RS->>Server: SSH: cd script_path
    RS->>Server: SSH: ./run_flag_rs.sh
    Server->>DB: UPDATE S_RS_SET<br/>WHERE NAME IN (...)
    DB-->>Server: Record Sets ativados
    Server-->>RS: ERRORLEVEL 0
    RS-->>Pipeline: ✅ Record Sets ativados
    
    Pipeline->>TASK: Ativar Tasks
    
    TASK->>Server: SSH: cd script_path
    TASK->>Server: SSH: ./run_flag_task.sh
    Server->>DB: UPDATE S_TASK<br/>WHERE NAME IN (...)
    DB-->>Server: Tasks ativadas
    Server-->>TASK: ERRORLEVEL 0
    TASK-->>Pipeline: ✅ Tasks ativadas
    
    Pipeline->>WF: Ativar Workflows
    
    WF->>Server: SSH: cd script_path
    WF->>Server: SSH: ./run_flag_wf.sh
    Server->>DB: UPDATE S_WORKFLOW<br/>WHERE NAME IN (...)
    DB-->>Server: Workflows ativados
    Server-->>WF: ERRORLEVEL 0
    WF-->>Pipeline: ✅ Workflows ativados
```

#### Scripts de Ativação

**🔹 active_rs_az.bat**
- **Propósito:** Ativar/desativar Record Sets específicos
- **Comando:**
  ```batch
  ssh pcpweb@10.238.7.12 "cd /opt/web/siebel/siebel811/siebelsrv1/scripts/ && ./run_flag_rs.sh"
  ```
- **Funcionalidade:** Executa script shell remoto que atualiza flags no banco de dados

**🔹 active_task_az.bat**
- **Propósito:** Ativar/desativar Tasks agendadas
- **Comando:**
  ```batch
  ssh pcpweb@10.238.7.12 "cd /opt/web/siebel/siebel811/siebelsrv1/scripts/ && ./run_flag_task.sh"
  ```
- **Uso Comum:** 
  - Desativar tasks antes do deploy
  - Reativar tasks após validação

**🔹 active_wf_az.bat**
- **Propósito:** Ativar/desativar Workflows de negócio
- **Comando:**
  ```batch
  ssh pcpweb@10.238.7.12 "cd /opt/web/siebel/siebel811/siebelsrv1/scripts/ && ./run_flag_wf.sh"
  ```
- **Impacto:** Workflows controlam processos críticos de negócio

**Características Comuns:**
- ✅ Validação de ERRORLEVEL
- ✅ Logs estruturados com delimitadores
- ✅ Timestamp de execução
- ✅ Script não-bloqueante (exit /B 0)
- ✅ Mensagens de sucesso/erro claras

---

## 🔧 Características Técnicas

### Padrões de Script Batch Avançado

Todos os scripts seguem padrões modernos de desenvolvimento batch:

#### 1. **Verbosidade Estruturada**

```batch
@echo off
setlocal enabledelayedexpansion

echo === INICIO DO SCRIPT nome_script.bat ===
echo Script: Descrição do propósito
echo Inicialização concluída
echo.

REM Seção 1: Preparação
echo ========================================
echo [SECAO] Nome da Seção
echo ========================================
```

#### 2. **Delayed Expansion**

Permite uso de variáveis dentro de loops e condicionais:

```batch
setlocal enabledelayedexpansion

set /a counter=0

for %%f in (*.sif) do (
    set /a counter+=1
    echo [!counter!] Processando: %%~nxf
)
```

#### 3. **Tratamento de Erros**

```batch
comando_critico > nul 2>&1

if !ERRORLEVEL! EQU 0 (
    echo [SUCESSO] Operação concluída
    set /a successCount+=1
) else (
    echo [ERRO] Falha na operação - ERRORLEVEL: !ERRORLEVEL!
    set /a failCount+=1
    goto :handle_error
)
```

#### 4. **Contadores e Estatísticas**

```batch
REM Inicialização de Contadores
set /a totalItems=0
set /a successCount=0
set /a failCount=0

REM ... processamento ...

REM Relatório Final
echo ========================================
echo Estatísticas de Processamento
echo ========================================
echo Total de itens: %totalItems%
echo Processados com sucesso: %successCount%
echo Falhas: %failCount%
```

#### 5. **Modificadores FOR**

```batch
for %%f in (*.sif) do (
    echo Arquivo completo: %%f
    echo Nome com extensão: %%~nxf
    echo Tamanho: %%~zf bytes
    echo Caminho completo: %%~ff
)
```

#### 6. **Redirecionamento Inteligente**

```batch
REM Suprimir output verboso mas manter logs
git clone https://... > nul 2>&1

REM Capturar output em arquivo
siebdev.exe /c import /f arquivo.sif > import.log 2>&1

REM Output seletivo
echo [INFO] Mensagem importante
comando > nul 2>&1
echo [RESULTADO] Comando concluído
```

#### 7. **Labels e Navegação**

```batch
:main_process
    comando1
    if !ERRORLEVEL! NEQ 0 goto :error_handler
    comando2
    goto :success

:error_handler
    echo [ERRO] Falha detectada
    set /a failCount+=1
    goto :cleanup

:success
    echo [SUCESSO] Processo concluído
    goto :cleanup

:cleanup
    echo Finalizando...
    exit /B 0
```

---

### Protocolos e Conectividade

#### SSH (Secure Shell)

**Uso:** Execução remota de comandos nos servidores Linux

**Características:**
- Autenticação por chave pública/privada
- Conexão persistente durante execução
- Execução de scripts shell remotos

**Exemplo:**
```batch
ssh pcpweb@10.238.7.12 "sudo -u supweb /path/to/script.sh"
```

**Validação:**
```batch
if !ERRORLEVEL! EQU 0 (
    echo [SUCESSO] Comando SSH executado
) else (
    echo [ERRO] Falha SSH - ERRORLEVEL: !ERRORLEVEL!
)
```

#### SFTP (SSH File Transfer Protocol)

**Uso:** Transferência segura de arquivos (SRF, XML)

**Características:**
- Transferência criptografada
- Suporte a arquivos grandes (SRF ~500MB)
- Controle de permissões

**Exemplo:**
```batch
sftp -b C:\Siebel_Devops\scripts\sftp_commands.txt pcpweb@10.238.5.32 22
```

**Arquivo de Comandos SFTP:**
```
put C:\local\file.srf /remote/path/file.srf
chmod 755 /remote/path/file.srf
quit
```

#### Git over HTTPS

**Uso:** Clonagem de repositório Azure DevOps

**Características:**
- Autenticação via PAT (Personal Access Token)
- Clone com histórico completo e tags
- Suporte a large files

**Exemplo:**
```batch
git clone --tags https://svc_vcorops:TOKEN@dev.azure.com/org/project/_git/repo C:\destino
```

---

### Arquitetura de Logs

#### Níveis de Log

| Nível | Formato | Uso |
|-------|---------|-----|
| **INFO** | `[INFO]` | Informações gerais de progresso |
| **SUCESSO** | `[SUCESSO]` | Operações concluídas com êxito |
| **AVISO** | `[AVISO]` | Situações não-ideais mas não-bloqueantes |
| **ERRO** | `[ERRO]` | Falhas que impedem operação |
| **DEBUG** | `[DEBUG]` | Detalhes técnicos para troubleshooting |

#### Estrutura de Log

```
=== INICIO DO SCRIPT git_prod_az.bat ===
Script: Clonagem de repositório Git para PROD
Timestamp: 20251031_143022
Inicialização concluída

========================================
[SECAO] Preparação do Ambiente
========================================

[INFO] Entrando no diretório de ambientes...
[INFO] Diretório atual: C:\Siebel_Devops\PROD\ambientes\

[INFO] Clonando repositório...
[INFO] Repositório: src-vivocorp-prod
[SUCESSO] Repositório clonado com sucesso

========================================
[SECAO] Estatísticas Finais
========================================
Tempo total: 5 minutos 23 segundos

=== FIM DO SCRIPT git_prod_az.bat ===
```

---

## 📖 Padrões e Boas Práticas

### Convenções de Nomenclatura

#### Arquivos Script

| Padrão | Exemplo | Uso |
|--------|---------|-----|
| `{acao}_{contexto}_az.bat` | `git_prod_az.bat` | Scripts de produção com padrão AZ |
| `{acao}_{contexto}.bat` | `import.bat` | Scripts legados (sem melhorias) |
| `{acao}_{objeto}_new_az.bat` | `sftp_srf_new_az.bat` | Scripts com nova implementação |

#### Variáveis

```batch
REM Contadores - snake_case com sufixo Count
set /a successCount=0
set /a failCount=0
set /a totalServers=0

REM Timestamps - camelCase
set datetime=%date:~-4%%date:~3,2%%date:~0,2%
set "timestamp=%datetime: =0%"

REM Paths - UPPERCASE
set SIEBEL_ROOT=C:\Siebel_Devops\PROD
set REPO_PATH=%SIEBEL_ROOT%\ambientes\src-vivocorp-prod
```

### Checklist de Qualidade

#### ✅ Todo Script Deve Ter:

- [ ] Cabeçalho com `=== INICIO DO SCRIPT ===`
- [ ] `setlocal enabledelayedexpansion` se usar contadores
- [ ] Seções identificadas com `REM` e delimitadores `===`
- [ ] Echo do diretório após cada `cd`
- [ ] Validação de ERRORLEVEL após comandos críticos
- [ ] Contadores de sucesso/falha (quando aplicável)
- [ ] Relatório final com estatísticas
- [ ] Rodapé com `=== FIM DO SCRIPT ===`
- [ ] `exit /B 0` para não bloquear pipeline

#### ✅ Mensagens de Log Devem:

- [ ] Ser descritivas e contextuais
- [ ] Incluir nível ([INFO], [SUCESSO], [ERRO])
- [ ] Documentar operações antes e depois
- [ ] Incluir valores de ERRORLEVEL em erros
- [ ] Usar delimitadores para operações longas

#### ✅ Tratamento de Erros Deve:

- [ ] Verificar ERRORLEVEL após comandos críticos
- [ ] Incrementar contadores de falha
- [ ] Logar erro com contexto
- [ ] Não bloquear pipeline (exit /B 0)
- [ ] Usar labels/goto quando necessário

---

### Segurança e Compliance

#### Gestão de Credenciais

**❌ NUNCA:**
```batch
set PASSWORD=senha123
git clone https://user:senha123@repo.git
```

**✅ SEMPRE:**
```batch
REM Credenciais via variáveis de ambiente do pipeline
git clone https://%GITUSER%:%GITPASS%@repo.git

REM Ou tokens de serviço
git clone https://svc_vcorops:%AZURE_TOKEN%@repo.git
```

#### Auditoria

Todos os scripts geram logs rastreáveis:
- ✅ Timestamp de execução
- ✅ Usuário executor (contexto do pipeline)
- ✅ Comandos executados
- ✅ Resultados de cada operação
- ✅ Estatísticas de sucesso/falha

#### Controle de Acesso

- 🔐 Scripts executados com usuário de serviço `svc_vcorops`
- 🔐 SSH com chaves públicas/privadas
- 🔐 SFTP com autenticação por certificado
- 🔐 Tokens com expiração e rotação periódica

---

## 🔍 Monitoramento e Troubleshooting

### Pontos de Validação

#### Durante o Pipeline

```mermaid
flowchart TD
    A[Pipeline Start] --> B{Git Clone OK?}
    B -->|Não| E1[FALHA: Clone]
    B -->|Sim| C{Import OK?}
    
    C -->|Não| E2[FALHA: Import]
    C -->|Sim| D{Compile OK?}
    
    D -->|Não| E3[FALHA: Compile]
    D -->|Sim| F{Stop Servers OK?}
    
    F -->|Não| E4[FALHA: Stop]
    F -->|Sim| G{SFTP OK?}
    
    G -->|Não| E5[FALHA: SFTP]
    G -->|Sim| H{Start Servers OK?}
    
    H -->|Não| E6[FALHA: Start]
    H -->|Sim| I{Health Check OK?}
    
    I -->|Não| E7[FALHA: Health]
    I -->|Sim| J{ADM OK?}
    
    J -->|Não| E8[FALHA: ADM]
    J -->|Sim| K{Activation OK?}
    
    K -->|Não| E9[FALHA: Activation]
    K -->|Sim| L[SUCCESS]
    
    E1 --> ROLLBACK[Trigger Rollback]
    E2 --> ROLLBACK
    E3 --> ROLLBACK
    E4 --> ROLLBACK
    E5 --> ROLLBACK
    E6 --> ROLLBACK
    E7 --> ROLLBACK
    E8 --> ROLLBACK
    E9 --> ROLLBACK
    
    style L fill:#90EE90
    style ROLLBACK fill:#FF6B6B
```

### Troubleshooting por Componente

#### 🔧 Git Clone Falhando

**Sintomas:**
- ERRORLEVEL != 0 no git clone
- Repositório não clonado

**Possíveis Causas:**
1. Token expirado/inválido
2. Permissões insuficientes
3. Rede/firewall bloqueando
4. Diretório existente (não limpo)

**Solução:**
```batch
REM 1. Validar token
echo %GITPASS% (verificar se não está vazio)

REM 2. Limpar repositório existente
call limpa_repo_az.bat

REM 3. Tentar clone novamente
call git_prod_az.bat
```

#### 🔧 Import Falhando

**Sintomas:**
- ERRORLEVEL != 0 no siebdev.exe
- Mensagem "Failed to import"

**Possíveis Causas:**
1. Arquivo .sif corrompido
2. Conflitos no repositório
3. Permissões de usuário SADMIN
4. Banco de dados travado

**Solução:**
```batch
REM 1. Verificar arquivo existe
dir "C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod\Siebel Repository\Repository\*.sif"

REM 2. Validar integridade
REM Verificar tamanho do arquivo (deve ser > 0)

REM 3. Verificar logs do siebdev
type import.log
```

#### 🔧 SFTP Falhando

**Sintomas:**
- Arquivo não transferido
- ERRORLEVEL != 0

**Possíveis Causas:**
1. Arquivo SRF não existe no source
2. Permissões no servidor remoto
3. Espaço em disco cheio
4. Rede/conectividade

**Solução:**
```batch
REM 1. Verificar arquivo fonte
dir C:\Siebel_Devops\PROD\srf\siebel_sia_new.srf

REM 2. Testar conectividade
ssh pcpweb@10.238.5.32 "echo teste"

REM 3. Verificar espaço em disco remoto
ssh pcpweb@10.238.5.32 "df -h /opt/web/siebel"

REM 4. Tentar transferência manual
sftp pcpweb@10.238.5.32
```

#### 🔧 Servidores Não Iniciando

**Sintomas:**
- start_srv.sh executado mas servidor não sobe
- Delay completo mas servidor offline

**Possíveis Causas:**
1. SRF corrompido
2. Configuração incorreta
3. Recursos insuficientes
4. Problemas de rede/licença

**Solução:**
```batch
REM 1. Verificar logs do Siebel
ssh pcpweb@10.238.7.12 "tail -100 /opt/web/siebel/siebel811/siebelsrv1/log/siebsrvr.log"

REM 2. Verificar processos
ssh pcpweb@10.238.7.12 "ps aux | grep siebel"

REM 3. Tentar start manual
ssh pcpweb@10.238.7.12 "sudo -u supweb /opt/web/siebel/siebel811/siebelsrv1/siebsrvr/scripts/start_srv.sh"
```

### Métricas de Sucesso

#### KPIs do Pipeline

| Métrica | Target | Alerta |
|---------|--------|--------|
| **Tempo Total** | < 90 min | > 120 min |
| **Taxa de Sucesso Import** | 100% | < 95% |
| **Taxa de Sucesso SFTP** | 100% | < 100% |
| **Servidores Online** | 12/12 | < 12/12 |
| **Falhas no Pipeline** | 0 | > 0 |

#### Dashboard de Monitoramento

```mermaid
graph LR
    subgraph "Pipeline Metrics"
        A[Duração Total]
        B[Taxa de Sucesso]
        C[Falhas por Etapa]
    end
    
    subgraph "Infrastructure Metrics"
        D[Servidores Online]
        E[Conectividade SSH]
        F[Espaço em Disco]
    end
    
    subgraph "Business Metrics"
        G[Downtime]
        H[Rollbacks]
        I[Impacto Usuários]
    end
    
    A --> J[Azure Dashboards]
    B --> J
    C --> J
    D --> J
    E --> J
    F --> J
    G --> K[Business Reports]
    H --> K
    I --> K
```

---

## 📊 Resumo Executivo

### Características Principais

| Característica | Detalhes |
|----------------|----------|
| **Automatização** | 95% do processo automatizado via scripts batch |
| **Rastreabilidade** | Logs estruturados com timestamps e contadores |
| **Resiliência** | Tratamento de erros em cada etapa crítica |
| **Escalabilidade** | Suporte a 12 servidores simultâneos |
| **Segurança** | Autenticação via tokens/chaves, auditoria completa |
| **Velocidade** | Release completo em ~75 minutos |

### Fluxo Resumido (5 Fases)

```mermaid
graph LR
    A[1. Preparação<br/>Git + Import] --> B[2. Build<br/>Compile]
    B --> C[3. Deploy<br/>Stop + SFTP + Start]
    C --> D[4. Config<br/>ADM]
    D --> E[5. Ativação<br/>RS/Task/WF]
    
    style A fill:#87CEEB
    style B fill:#FFD700
    style C fill:#FF6B6B
    style D fill:#90EE90
    style E fill:#DDA0DD
```

### Equipe e Responsabilidades

| Papel | Responsabilidades |
|-------|------------------|
| **DevOps Engineer** | Manutenção de scripts, troubleshooting |
| **Siebel Admin** | Validação de imports, configuração ADM |
| **Release Manager** | Aprovação de releases, coordenação |
| **QA** | Validação pós-deploy, testes de regressão |
| **Suporte Infraestrutura** | Monitoramento de servidores, rede |

---

## 🎓 Referências e Documentação Adicional

### Documentos Relacionados

- [CONTRIBUTING.md](../../CONTRIBUTING.md) - Guia de contribuição
- [GUIDELINES.md](../../GUIDELINES.md) - Diretrizes do projeto
- [Framework README](../../framework/README.md) - Documentação do framework
- [Tech Products](../../tech_products/) - Outros tech products

### Análises Individuais de Scripts

Cada script possui documentação detalhada na pasta `docs/prod/`:
- [GIT_PROD_IMPROVEMENT_PROMPT.md](GIT_PROD_IMPROVEMENT_PROMPT.md)
- [IMPORT_IMPROVEMENT_ANALYSIS.md](IMPORT_IMPROVEMENT_ANALYSIS.md)
- [START_SRV_NEW_IMPROVEMENT_ANALYSIS.md](START_SRV_NEW_IMPROVEMENT_ANALYSIS.md)
- [SFTP_SRF_IMPROVEMENT_ANALYSIS.md](SFTP_SRF_IMPROVEMENT_ANALYSIS.md)
- [ADM_GET_NEW_IMPROVEMENT_ANALYSIS.md](ADM_GET_NEW_IMPROVEMENT_ANALYSIS.md)
- [ADM_IMPORT_NEW_IMPROVEMENT_ANALYSIS.md](ADM_IMPORT_NEW_IMPROVEMENT_ANALYSIS.md)
- [ACTIVE_RS_IMPROVEMENT_ANALYSIS.md](ACTIVE_RS_IMPROVEMENT_ANALYSIS.md)
- [ACTIVE_TASK_IMPROVEMENT_ANALYSIS.md](ACTIVE_TASK_IMPROVEMENT_ANALYSIS.md)
- [ACTIVE_WF_IMPROVEMENT_ANALYSIS.md](ACTIVE_WF_IMPROVEMENT_ANALYSIS.md)
- [LIMPA_REPO_IMPROVEMENT_ANALYSIS.md](LIMPA_REPO_IMPROVEMENT_ANALYSIS.md)
- [RENAME_SRF_IMPROVEMENT_ANALYSIS.md](RENAME_SRF_IMPROVEMENT_ANALYSIS.md)
- [STOP_SRV_IMPROVEMENT_ANALYSIS.md](STOP_SRV_IMPROVEMENT_ANALYSIS.md)

---

## 📞 Contato e Suporte

Para dúvidas sobre este processo:
- **Equipe:** DevOps VivoCorp
- **Canal:** Teams - Canal DevOps
- **Repositório:** Azure DevOps - Vivo.CodePlay.Pipelines

---

**Versão do Documento:** 1.0  
**Data:** 31/10/2025  
**Autor:** DevOps Team  
**Status:** ✅ Aprovado para Publicação na Wiki
