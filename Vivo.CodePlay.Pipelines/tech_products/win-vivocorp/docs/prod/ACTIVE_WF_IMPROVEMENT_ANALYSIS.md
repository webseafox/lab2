# Análise de Melhorias: active_wf.bat → active_wf_az.bat

## 📋 Informações do Script

- **Script Original:** `active_wf.bat`
- **Script Melhorado:** `active_wf_az.bat`
- **Propósito:** Ativar workflows Siebel após deploy
- **Ambiente:** Produção Siebel CRM v8.1
- **Data da Análise:** 2025-10-30

## 📊 Métricas de Melhoria

| Métrica | Antes | Depois | Variação |
|---------|-------|--------|----------|
| **Linhas Totais** | 4 | 75 | +1775% |
| **Comandos echo** | 0 | 25+ | ∞ |
| **Verificações ERRORLEVEL** | 0 | 1 | +1 |
| **Contadores** | 0 | 2 | +2 |
| **Seções lógicas** | 0 | 1 | +1 |
| **Tratamento de erro** | ❌ Inexistente | ✅ Completo | - |

## 🎯 Melhorias Implementadas

### 1. ✅ Verbosidade e Rastreabilidade

**ANTES:**
```batch
ssh pcpweb@10.238.7.12 /home/pcpweb/active_wf.sh


exit 0
```

**DEPOIS:**
```batch
echo ========================================
echo [SECAO 1] Ativando workflows Siebel
echo ========================================
echo.

echo [Active WF] Conectando em pcpweb@10.238.7.12...
echo [Active WF] Executando: /home/pcpweb/active_wf.sh
ssh pcpweb@10.238.7.12 /home/pcpweb/active_wf.sh
if !ERRORLEVEL! EQU 0 (
    echo [Active WF] Script active_wf.sh executado com sucesso
    echo [Active WF] Workflows ativados no servidor
    set /A successCount+=1
) else (
    echo [ERRO] Falha ao executar active_wf.sh - ERRORLEVEL: !ERRORLEVEL!
    echo [ERRO] Workflows podem nao estar ativados
    set /A failCount+=1
)
```

**Impacto:**
- Logs rastreáveis para auditoria
- Identificação clara de sucesso ou falha
- Contexto sobre o que o script faz

### 2. ✅ Cabeçalho Estruturado

**ANTES:**
```batch
ssh pcpweb@10.238.7.12 /home/pcpweb/active_wf.sh
```

**DEPOIS:**
```batch
@echo off
setlocal enabledelayedexpansion

echo ========================================
echo SCRIPT: active_wf_az.bat
echo PROPOSITO: Ativar workflows Siebel
echo DATA/HORA: %date% %time%
echo ========================================
echo.

echo [INFO] Iniciando processo de ativacao de workflows...
```

**Impacto:**
- Timestamp para correlação com outros logs
- Identificação clara do propósito do script
- Contexto para troubleshooting

### 3. ✅ Tratamento de Erros com ERRORLEVEL

**ANTES:**
```batch
ssh pcpweb@10.238.7.12 /home/pcpweb/active_wf.sh
exit 0
rem Sempre retorna sucesso, mesmo se falhar
```

**DEPOIS:**
```batch
ssh pcpweb@10.238.7.12 /home/pcpweb/active_wf.sh
if !ERRORLEVEL! EQU 0 (
    echo [Active WF] Script active_wf.sh executado com sucesso
    echo [Active WF] Workflows ativados no servidor
    set /A successCount+=1
) else (
    echo [ERRO] Falha ao executar active_wf.sh - ERRORLEVEL: !ERRORLEVEL!
    echo [ERRO] Workflows podem nao estar ativados
    set /A failCount+=1
)
```

**Impacto:**
- Detecção imediata de falhas de conexão SSH
- Identificação de problemas na execução do script remoto
- Pipeline pode tomar decisões baseadas no resultado

### 4. ✅ Contadores Estatísticos

**ANTES:**
```batch
rem Sem contadores ou resumo
```

**DEPOIS:**
```batch
set successCount=0
set failCount=0

rem ... após operação ...
set /A successCount+=1  rem ou failCount+=1

rem ... no final ...
echo ========================================
echo RESUMO DA ATIVACAO DE WORKFLOWS
echo ========================================
echo Total de operacoes: 1
echo Operacoes bem-sucedidas: !successCount!
echo Operacoes com falha: !failCount!
```

**Impacto:**
- Visão estatística mesmo sendo operação única
- Padrão consistente com outros scripts
- Base para monitoramento e alertas

### 5. ✅ Exit Code Baseado em Resultados

**ANTES:**
```batch
exit 0
rem Sempre retorna sucesso
```

**DEPOIS:**
```batch
if !failCount! GTR 0 (
    echo [AVISO] Processo concluido com falhas
    echo [AVISO] Workflows podem nao estar ativos
    echo [AVISO] Verifique manualmente o status dos workflows
    echo [AVISO] Consulte logs em /home/pcpweb/ no servidor
    echo.
    echo [INFO] Script finalizado com codigo de erro
    exit /B 1
) else (
    echo [SUCESSO] Script active_wf.sh executado com sucesso
    echo [INFO] Workflows Siebel foram ativados
    echo [INFO] Processos de workflow devem estar operacionais
    echo [INFO] Recomendacao: Validar workflows no Siebel Tools
    echo.
    echo [INFO] Script finalizado com sucesso
    exit /B 0
)
```

**Impacto:**
- Exit code 0 = workflows ativados com sucesso
- Exit code 1 = falha na ativação
- Pipeline pode parar se workflows não foram ativados
- Orientações claras sobre próximos passos

### 6. ✅ Mensagens de Recomendação

**ANTES:**
```batch
rem Sem orientações ou recomendações
```

**DEPOIS:**
```batch
echo [INFO] Recomendacao: Validar workflows no Siebel Tools
echo [AVISO] Consulte logs em /home/pcpweb/ no servidor
```

**Impacto:**
- Orientação sobre validação manual
- Indicação de onde encontrar logs detalhados
- Facilita troubleshooting por operadores

## 🏗️ Arquitetura do Processo

### Servidor Envolvido

**Servidor: 10.238.7.12**
- **User:** pcpweb
- **Script Remoto:** `/home/pcpweb/active_wf.sh`
- **Função:** Ativar workflows no Siebel
- **Logs:** Provavelmente em `/home/pcpweb/` ou `/var/log/siebel/`

### Fluxo de Dados

```
┌─────────────────────────────────────────┐
│ Windows: active_wf_az.bat               │
│ - Executa comando SSH                   │
│ - Aguarda resposta                      │
└────────────────┬────────────────────────┘
                 │ SSH
                 ▼
┌─────────────────────────────────────────┐
│ Linux (10.238.7.12):                    │
│ pcpweb@10.238.7.12                      │
│ /home/pcpweb/active_wf.sh               │
└────────────────┬────────────────────────┘
                 │ Executa
                 ▼
┌─────────────────────────────────────────┐
│ Siebel Workflow Engine                  │
│ - Ativa processos de workflow           │
│ - Habilita automações                   │
│ - Inicia regras de negócio              │
└─────────────────────────────────────────┘
```

## 📈 Fluxo de Execução

```
┌─────────────────────────────────────────────────┐
│  INÍCIO: active_wf_az.bat                       │
│  - Exibe cabeçalho com timestamp                │
│  - Inicializa contadores (0, 0)                 │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│  SEÇÃO 1: Ativar Workflows                      │
│  ┌──────────────────────────────────────────┐   │
│  │  1. Echo "Conectando..."                 │   │
│  │  2. SSH active_wf.sh                     │   │
│  │  3. Verifica ERRORLEVEL                  │   │
│  │  4. Se OK: log sucesso, successCount++   │   │
│  │  5. Se ERRO: log erro, failCount++       │   │
│  └──────────────────────────────────────────┘   │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│  RESUMO ESTATÍSTICO                             │
│  - Total: 1 operação                            │
│  - Sucessos: !successCount!                     │
│  - Falhas: !failCount!                          │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
              ┌────┴────┐
              │ failCount > 0? │
              └────┬────┘
                   │
        ┌──────────┴──────────┐
        │ SIM               NÃO │
        ▼                       ▼
┌──────────────┐      ┌──────────────┐
│ [AVISO]      │      │ [SUCESSO]    │
│ Workflows    │      │ Workflows    │
│ podem não    │      │ ativados     │
│ estar ativos │      │ Validar em   │
│ Verificar    │      │ Siebel Tools │
│ manualmente  │      │              │
│ exit /B 1    │      │ exit /B 0    │
└──────────────┘      └──────────────┘
```

## 🎓 Detalhamento por Seção

### Seção 1: Ativar Workflows
- **Linhas:** 21-41
- **Input:** Conexão SSH disponível, script active_wf.sh no servidor
- **Output:** Comando SSH, verificação ERRORLEVEL
- **Tempo:** ~2-5 segundos (depende da quantidade de workflows)
- **Verificações:** 1 × ERRORLEVEL

## 🔍 Cenários de Uso

### Cenário 1: Ativação Bem-Sucedida de Workflows
**Entrada:**
```cmd
active_wf_az.bat
```

**Saída Esperada:**
```
========================================
SCRIPT: active_wf_az.bat
PROPOSITO: Ativar workflows Siebel
DATA/HORA: 30/10/2025 17:30:00
========================================

[INFO] Iniciando processo de ativacao de workflows...

========================================
[SECAO 1] Ativando workflows Siebel
========================================

[Active WF] Conectando em pcpweb@10.238.7.12...
[Active WF] Executando: /home/pcpweb/active_wf.sh
[Active WF] Script active_wf.sh executado com sucesso
[Active WF] Workflows ativados no servidor

========================================
RESUMO DA ATIVACAO DE WORKFLOWS
========================================
Total de operacoes: 1
Operacoes bem-sucedidas: 1
Operacoes com falha: 0
========================================

[SUCESSO] Script active_wf.sh executado com sucesso
[INFO] Workflows Siebel foram ativados
[INFO] Processos de workflow devem estar operacionais
[INFO] Recomendacao: Validar workflows no Siebel Tools

[INFO] Script finalizado com sucesso
```

**Exit Code:** 0  
**Próximo Passo:** Validar workflows no Siebel Tools ou Application

### Cenário 2: Falha na Ativação (Conexão SSH)
**Entrada:**
```cmd
active_wf_az.bat
rem Servidor 10.238.7.12 indisponível
```

**Saída Esperada:**
```
========================================
SCRIPT: active_wf_az.bat
PROPOSITO: Ativar workflows Siebel
DATA/HORA: 30/10/2025 17:30:00
========================================

[INFO] Iniciando processo de ativacao de workflows...

========================================
[SECAO 1] Ativando workflows Siebel
========================================

[Active WF] Conectando em pcpweb@10.238.7.12...
[Active WF] Executando: /home/pcpweb/active_wf.sh
[ERRO] Falha ao executar active_wf.sh - ERRORLEVEL: 255
[ERRO] Workflows podem nao estar ativados

========================================
RESUMO DA ATIVACAO DE WORKFLOWS
========================================
Total de operacoes: 1
Operacoes bem-sucedidas: 0
Operacoes com falha: 1
========================================

[AVISO] Processo concluido com falhas
[AVISO] Workflows podem nao estar ativos
[AVISO] Verifique manualmente o status dos workflows
[AVISO] Consulte logs em /home/pcpweb/ no servidor

[INFO] Script finalizado com codigo de erro
```

**Exit Code:** 1  
**Ação Necessária:** Verificar conectividade SSH e status do servidor

### Cenário 3: Falha no Script Remoto
**Entrada:**
```cmd
active_wf_az.bat
rem Script active_wf.sh não encontrado ou com erro
```

**Saída Esperada:**
```
========================================
[SECAO 1] Ativando workflows Siebel
========================================

[Active WF] Conectando em pcpweb@10.238.7.12...
[Active WF] Executando: /home/pcpweb/active_wf.sh
[ERRO] Falha ao executar active_wf.sh - ERRORLEVEL: 127
[ERRO] Workflows podem nao estar ativados

========================================
RESUMO DA ATIVACAO DE WORKFLOWS
========================================
Total de operacoes: 1
Operacoes bem-sucedidas: 0
Operacoes com falha: 1
========================================

[AVISO] Processo concluido com falhas
[AVISO] Workflows podem nao estar ativos
[AVISO] Verifique manualmente o status dos workflows
[AVISO] Consulte logs em /home/pcpweb/ no servidor

[INFO] Script finalizado com codigo de erro
```

**Exit Code:** 1  
**ERRORLEVEL 127:** Comando/script não encontrado  
**Ação Necessária:** Verificar se /home/pcpweb/active_wf.sh existe e tem permissões

### Cenário 4: Integração com Pipeline Azure DevOps
**Pipeline YAML:**
```yaml
# Após deploy completo e restart de servidores
- task: BatchScript@1
  displayName: 'Start Siebel Servers 1-2'
  inputs:
    filename: 'tech_products/win-vivocorp/siebel_devops/paliativo/prod/start_srv_new_az.bat'

- task: BatchScript@1
  displayName: 'Import ADM and Deploy Batch'
  inputs:
    filename: 'tech_products/win-vivocorp/siebel_devops/paliativo/prod/adm_import_new_az.bat'

- task: BatchScript@1
  displayName: 'Activate Siebel Workflows'
  inputs:
    filename: 'tech_products/win-vivocorp/siebel_devops/paliativo/prod/active_wf_az.bat'
  continueOnError: false
  condition: succeeded()

- task: PowerShell@2
  displayName: 'Validate Workflows Active'
  inputs:
    targetType: 'inline'
    script: |
      if ($LASTEXITCODE -ne 0) {
        Write-Error "Falha ao ativar workflows Siebel"
        Write-Host "##vso[task.complete result=Failed;]STOP"
      }
      Write-Host "Workflows ativados com sucesso"
      Write-Host "Deploy Siebel concluído com sucesso"

- task: ManualValidation@0
  displayName: 'Manual Validation - Check Workflows in Siebel Tools'
  inputs:
    notifyUsers: 'siebel-ops@empresa.com'
    instructions: 'Validar workflows ativos no Siebel Tools antes de aprovar'
  condition: succeeded()
```

**Resultado:** Pipeline falha se workflows não forem ativados, impedindo conclusão do deploy

## 📝 Observações Importantes

### 1. O Que São Workflows Siebel?

Workflows no Siebel são **processos de negócio automatizados** que controlam:
- **Aprovações:** Descontos, pedidos, contratos
- **Escalações:** Tickets não resolvidos, casos críticos
- **Integrações:** Comunicação com sistemas externos
- **Notificações:** E-mails, alertas, lembretes
- **Regras de Negócio:** Validações automáticas, cálculos

**Se não estiverem ativos, processos críticos param!**

### 2. Por Que Ativar Workflows Após Deploy?

Após restart dos servidores Siebel:
- Workflows podem estar em estado inativo (disabled)
- Processos não executam automaticamente
- Integrações param de funcionar
- Notificações não são enviadas

O script `active_wf.sh` **reativa todos os workflows** necessários.

### 3. Validação Manual Recomendada

Mesmo com exit code 0, é recomendado validar no **Siebel Tools**:
```
Siebel Tools → Administration - Workflow → Workflow Processes
- Verificar Status = Active
- Verificar Run Mode = Background
- Testar workflows críticos manualmente
```

### 4. Logs do Script Remoto

O script `active_wf.sh` pode gerar logs em:
- `/home/pcpweb/active_wf.log`
- `/var/log/siebel/workflow_activation.log`
- Output do próprio SSH (se houver echo no script)

Consultar esses logs em caso de falha.

### 5. Simplicidade vs Criticidade

Este é o script **mais simples** de todos (apenas 1 comando SSH), mas é **criticamente importante**:

| Complexidade | Criticidade | Impacto de Falha |
|--------------|-------------|------------------|
| ⭐ Baixa | ⭐⭐⭐⭐⭐ Alta | Processos de negócio param |

### 6. Posição no Pipeline de Deploy

```
1. sftp_srf_new_az.bat      → Distribui SRF novo
2. stop_srv_az.bat          → Para 16 servidores
3. rename_srf_az.bat        → Renomeia SRF
4. start_srv_new_az.bat     → Inicia servers 1-2 (delay 520s)
5. start_srv_az.bat         → Inicia servers 3-27
6. adm_import_new_az.bat    → Import ADM + batch
7. active_wf_az.bat         → Ativa workflows ⭐ (você está aqui)
8. Validação manual/automática
```

**Última etapa crítica antes de liberar para produção!**

### 7. Diferença de Exit Code

**ANTES:**
```batch
exit 0
rem Sempre 0, mesmo se falhar
```

**Impacto:** Pipeline prossegue mesmo se workflows não foram ativados → **Produção com problema silencioso**

**DEPOIS:**
```batch
exit /B 1  # Se falhar
exit /B 0  # Se sucesso
```

**Impacto:** Pipeline **para imediatamente** se workflows não forem ativados → **Problema detectado antes de liberar produção**

## 🚀 Próximos Passos

1. **Validar Script Remoto:**
   - Confirmar existência de `/home/pcpweb/active_wf.sh`
   - Revisar conteúdo do script (quais workflows ativa?)
   - Verificar logs gerados pelo script

2. **Testar em Desenvolvimento:**
   - Executar active_wf_az.bat em DEV
   - Validar workflows no Siebel Tools
   - Confirmar que processos funcionam após ativação

3. **Documentar Workflows Críticos:**
   - Listar workflows que devem estar ativos
   - Criar checklist de validação
   - Definir critérios de aceite

4. **Implementar Validação Automática:**
   - Script que consulta status de workflows
   - Query no banco Siebel verificando workflows ativos
   - Testes automatizados de processos críticos

5. **Monitoramento Contínuo:**
   - Alertas se workflows ficarem inativos
   - Dashboard com status de workflows
   - Histórico de ativações

## 🔧 Possíveis Melhorias Futuras

### 1. Validação Automática Pós-Ativação
```batch
rem Após ativar, validar se workflows estão realmente ativos
echo [Validation] Validando status dos workflows...
ssh pcpweb@10.238.7.12 /home/pcpweb/check_wf_status.sh
if !ERRORLEVEL! EQU 0 (
    echo [Validation] Workflows confirmados como ativos
) else (
    echo [ERRO] Workflows ativados mas validacao falhou
    set /A failCount+=1
)
```

### 2. Lista de Workflows Ativados
```batch
rem Exibir quais workflows foram ativados
echo [Active WF] Workflows ativados:
ssh pcpweb@10.238.7.12 "cat /home/pcpweb/last_activated_workflows.log"
```

### 3. Retry em Caso de Falha
```batch
set maxRetries=3
set retryCount=0

:retry
ssh pcpweb@10.238.7.12 /home/pcpweb/active_wf.sh
if !ERRORLEVEL! EQU 0 (
    echo [Success] Workflows ativados
    goto :success
) else (
    set /A retryCount+=1
    if !retryCount! LSS %maxRetries% (
        echo [Retry] Tentativa !retryCount! de %maxRetries%...
        timeout /t 10
        goto :retry
    ) else (
        echo [ERRO] Falha apos %maxRetries% tentativas
        goto :failure
    )
)
```

## 📚 Referências

- **SCRIPT_IMPROVEMENT_PROMPT.md:** Guia mestre de melhorias
- **Script Original:** `active_wf.bat` (4 linhas)
- **Script Melhorado:** `active_wf_az.bat` (75 linhas)
- **Scripts Relacionados:**
  - `start_srv_new_az.bat`: Inicia servidores antes de ativar workflows
  - `start_srv_az.bat`: Inicia demais servidores
  - `adm_import_new_az.bat`: Import ADM executado antes de workflows
- **Siebel Documentation:** Workflow Process Guide v8.1
- **Azure DevOps:** CodePlay Pipelines Framework

---

**Autor:** Azure DevOps Copilot  
**Data:** 2025-10-30  
**Versão:** 1.0
