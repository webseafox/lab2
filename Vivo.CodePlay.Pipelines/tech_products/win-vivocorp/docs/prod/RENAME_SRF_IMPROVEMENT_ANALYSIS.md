# Análise de Melhorias: rename_srf.bat → rename_srf_az.bat

## 📋 Informações do Script

- **Script Original:** `rename_srf.bat`
- **Script Melhorado:** `rename_srf_az.bat`
- **Propósito:** Renomear arquivos SRF nos servidores Siebel via scripts remotos
- **Ambiente:** Produção Siebel CRM v8.1
- **Data da Análise:** 2025-10-30

## 📊 Métricas de Melhoria

| Métrica | Antes | Depois | Variação |
|---------|-------|--------|----------|
| **Linhas Totais** | 19 | 250 | +1216% |
| **Comandos echo** | 0 | 65+ | ∞ |
| **Verificações ERRORLEVEL** | 0 | 13 | +13 |
| **Contadores** | 0 | 3 | +3 |
| **Grupos lógicos** | 4 (implícito) | 4 (explícito) | - |
| **Tratamento de erro** | ❌ Inexistente | ✅ Completo | - |

## 🎯 Melhorias Implementadas

### 1. ✅ Verbosidade e Rastreabilidade

**ANTES:**
```batch
rem rename srf server 3 a 8
ssh pcpweb@10.238.5.32 /home/pcpweb/rename_srf.sh
ssh pcpweb@10.238.5.33 /home/pcpweb/rename_srf.sh
ssh pcpweb@10.238.5.34 /home/pcpweb/rename_srf.sh
```

**DEPOIS:**
```batch
echo ========================================
echo [GRUPO 1] Renomeando SRF nos servidores 3 a 8
echo ========================================
echo.

echo [Server 3] Conectando em pcpweb@10.238.5.32...
ssh pcpweb@10.238.5.32 /home/pcpweb/rename_srf.sh
if !ERRORLEVEL! EQU 0 (
    echo [Server 3] Script rename_srf.sh executado com sucesso em 10.238.5.32
    set /A successCount+=1
) else (
    echo [ERRO] Falha ao executar script no servidor 3 ^(10.238.5.32^) - ERRORLEVEL: !ERRORLEVEL!
    set /A failCount+=1
)
echo.

echo [Server 4] Conectando em pcpweb@10.238.5.33...
ssh pcpweb@10.238.5.33 /home/pcpweb/rename_srf.sh
if !ERRORLEVEL! EQU 0 (
    echo [Server 4] Script rename_srf.sh executado com sucesso em 10.238.5.33
    set /A successCount+=1
) else (
    echo [ERRO] Falha ao executar script no servidor 4 ^(10.238.5.33^) - ERRORLEVEL: !ERRORLEVEL!
    set /A failCount+=1
)
```

**Impacto:**
- Feedback individual para cada servidor
- Identificação imediata de falhas por servidor
- Logs completos para troubleshooting

### 2. ✅ Cabeçalho Estruturado com Timestamp

**ANTES:**
```batch
rem rename srf server 3 a 8
```

**DEPOIS:**
```batch
@echo off
setlocal enabledelayedexpansion

echo ========================================
echo SCRIPT: rename_srf_az.bat
echo PROPOSITO: Renomear arquivos SRF nos servidores Siebel
echo DATA/HORA: %date% %time%
echo ========================================
echo.

echo [INFO] Iniciando processo de rename de arquivos SRF...
```

**Impacto:**
- Timestamp para auditoria
- Contexto claro do propósito
- Facilita correlação com logs de outros scripts

### 3. ✅ Tratamento de Erros Individual

**ANTES:**
```batch
ssh pcpweb@10.238.5.32 /home/pcpweb/rename_srf.sh
rem Nenhuma verificação de sucesso/falha
```

**DEPOIS:**
```batch
ssh pcpweb@10.238.5.32 /home/pcpweb/rename_srf.sh
if !ERRORLEVEL! EQU 0 (
    echo [Server 3] Script rename_srf.sh executado com sucesso em 10.238.5.32
    set /A successCount+=1
) else (
    echo [ERRO] Falha ao executar script no servidor 3 ^(10.238.5.32^) - ERRORLEVEL: !ERRORLEVEL!
    set /A failCount+=1
)
```

**Impacto:**
- Detecção de falhas por servidor
- Possibilidade de retry em servidores específicos
- Pipeline pode tomar ação baseada em falhas

### 4. ✅ Contadores Estatísticos

**ANTES:**
```batch
rem Sem contadores ou resumo
```

**DEPOIS:**
```batch
set totalServers=16
set successCount=0
set failCount=0

rem ... após cada operação ...
set /A successCount+=1
rem ou
set /A failCount+=1

rem ... no final ...
echo ========================================
echo RESUMO DO RENAME DE ARQUIVOS SRF
echo ========================================
echo Total de servidores: %totalServers%
echo Scripts executados com sucesso: !successCount!
echo Scripts com falha: !failCount!
```

**Impacto:**
- Validação de que todos os 16 servidores foram processados
- Métrica para monitoramento e alertas
- Base para decisão de continuar ou abortar pipeline

### 5. ✅ Organização em Grupos Lógicos Explícitos

**ANTES:**
```batch
rem rename srf server 3 a 8
ssh pcpweb@10.238.5.32 /home/pcpweb/rename_srf.sh
...
rem rename srf server 1 e 2
ssh pcpweb@10.238.7.12 /home/pcpweb/rename_srf.sh
...
rem rename srf server 20 a 23
ssh pcpweb@10.238.6.35 /home/pcpweb/rename_srf.sh
```

**DEPOIS:**
```batch
rem ========================================
rem GRUPO 1: Servidores 3 a 8 (10.238.5.32-37)
rem ========================================
echo ========================================
echo [GRUPO 1] Renomeando SRF nos servidores 3 a 8
echo ========================================

rem ========================================
rem GRUPO 2: Servidores 1 e 2 (10.238.7.12-13)
rem ========================================
echo ========================================
echo [GRUPO 2] Renomeando SRF nos servidores 1 e 2
echo ========================================

rem ========================================
rem GRUPO 3: Servidores 20 a 23 (10.238.6.35-38)
rem ========================================
echo ========================================
echo [GRUPO 3] Renomeando SRF nos servidores 20 a 23
echo ========================================
```

**Impacto:**
- Separação visual clara entre grupos de servidores
- Facilita identificação de qual grupo falhou
- Documentação de ranges de IP diretamente no código

### 6. ✅ Exit Code Baseado em Resultados

**ANTES:**
```batch
rem Sem exit code explícito
rem Retorna último ERRORLEVEL (imprevisível)
```

**DEPOIS:**
```batch
if !failCount! GTR 0 (
    echo [AVISO] Processo concluido com falhas
    echo [AVISO] Verifique os logs dos servidores que falharam
    echo [AVISO] Alguns servidores podem ter arquivos SRF com nome antigo
    echo.
    echo [INFO] Script finalizado com codigo de erro
    exit /B 1
) else (
    echo [SUCESSO] Todos os scripts de rename foram executados com sucesso
    echo [INFO] Arquivos SRF renomeados em todos os 16 servidores
    echo [INFO] Os servidores estao prontos para restart com novo SRF
    echo.
    echo [INFO] Script finalizado com sucesso
    exit /B 0
)
```

**Impacto:**
- Exit code 0 = todos os renames bem-sucedidos
- Exit code 1 = pelo menos uma falha
- Pipeline pode decidir se prossegue para restart dos servidores

### 7. ✅ Mensagens de Contexto Melhoradas

**ANTES:**
```batch
rem SDANGELIS [Adicionados novos servidores] 20240620
rem Server 24 a 27
ssh pcpweb@10.238.7.12 /home/pcpweb/rename_srf_new_servers.sh
```

**DEPOIS:**
```batch
rem ========================================
rem GRUPO 4: Servidores 24 a 27 (via script remoto)
rem ========================================
echo ========================================
echo [GRUPO 4] Renomeando SRF nos servidores 24 a 27
echo ========================================
echo.

echo [Servers 24-27] Executando script remoto em pcpweb@10.238.7.12...
echo [INFO] Script: /home/pcpweb/rename_srf_new_servers.sh
ssh pcpweb@10.238.7.12 /home/pcpweb/rename_srf_new_servers.sh
if !ERRORLEVEL! EQU 0 (
    echo [Servers 24-27] Script remoto executado com sucesso
    echo [INFO] Servidores 24, 25, 26 e 27 tiveram SRF renomeados
    set /A successCount+=4
) else (
    echo [ERRO] Falha ao executar script remoto para servidores 24-27 - ERRORLEVEL: !ERRORLEVEL!
    set /A failCount+=4
)
```

**Impacto:**
- Clareza sobre script remoto gerenciando múltiplos servidores
- Incremento correto de contadores (+4)
- Feedback específico para grupo remoto

## 🏗️ Topologia dos Servidores

### Grupo 1: Servidores 3-8 (Ordem de Execução: 1º)
- **Range IP:** 10.238.5.32-37
- **User:** pcpweb
- **Script Remoto:** `/home/pcpweb/rename_srf.sh`
- **Servidores:** 6
- **Função:** Renomeia SRF individual em cada servidor

### Grupo 2: Servidores 1-2 (Ordem de Execução: 2º)
- **Range IP:** 10.238.7.12-13
- **User:** pcpweb
- **Script Remoto:** `/home/pcpweb/rename_srf.sh`
- **Servidores:** 2
- **Função:** Renomeia SRF individual

### Grupo 3: Servidores 20-23 (Ordem de Execução: 3º)
- **Range IP:** 10.238.6.35-38
- **User:** pcpweb
- **Script Remoto:** `/home/pcpweb/rename_srf.sh`
- **Servidores:** 4
- **Função:** Renomeia SRF individual

### Grupo 4: Servidores 24-27 (Ordem de Execução: 4º)
- **Host Controle:** 10.238.7.12
- **User:** pcpweb
- **Script Remoto:** `/home/pcpweb/rename_srf_new_servers.sh`
- **Servidores:** 4
- **IPs Gerenciados:** 10.238.6.67-68 (e possivelmente 65-66)
- **Função:** Script centralizado que renomeia SRF em 4 servidores
- **Nota:** Adicionados em 20/06/2024 por SDANGELIS

**Total:** 16 servidores Siebel

## 📈 Fluxo de Execução

```
┌─────────────────────────────────────────────────┐
│  INÍCIO: rename_srf_az.bat                      │
│  - Exibe cabeçalho com timestamp                │
│  - Inicializa contadores (16, 0, 0)             │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│  GRUPO 1: Servidores 3-8 (10.238.5.32-37)      │
│  ┌──────────────────────────────────────────┐   │
│  │  Para cada servidor (3-8):               │   │
│  │  1. Echo "Conectando..."                 │   │
│  │  2. SSH rename_srf.sh                    │   │
│  │  3. Verifica ERRORLEVEL                  │   │
│  │  4. Se OK: log sucesso, successCount++   │   │
│  │  5. Se ERRO: log erro, failCount++       │   │
│  │  6. Echo separador                       │   │
│  └──────────────────────────────────────────┘   │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│  GRUPO 2: Servidores 1-2 (10.238.7.12-13)      │
│  ┌──────────────────────────────────────────┐   │
│  │  Para cada servidor (1-2):               │   │
│  │  (mesmo fluxo de verificação)            │   │
│  └──────────────────────────────────────────┘   │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│  GRUPO 3: Servidores 20-23 (10.238.6.35-38)    │
│  ┌──────────────────────────────────────────┐   │
│  │  Para cada servidor (20-23):             │   │
│  │  (mesmo fluxo de verificação)            │   │
│  └──────────────────────────────────────────┘   │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│  GRUPO 4: Servidores 24-27 (Script Remoto)     │
│  ┌──────────────────────────────────────────┐   │
│  │  1. Echo script remoto                   │   │
│  │  2. SSH rename_srf_new_servers.sh        │   │
│  │  3. Verifica ERRORLEVEL                  │   │
│  │  4. Se OK: successCount += 4             │   │
│  │  5. Se ERRO: failCount += 4              │   │
│  └──────────────────────────────────────────┘   │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│  RESUMO ESTATÍSTICO                             │
│  - Total: 16 servidores                         │
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
│ Falhas       │      │ Todos OK     │
│ SRF com nome │      │ Prontos para │
│ antigo       │      │ restart      │
│ exit /B 1    │      │ exit /B 0    │
└──────────────┘      └──────────────┘
```

## 🎓 Detalhamento por Seção

### Seção 1: Inicialização
- **Linhas:** 1-18
- **Input:** Nenhum (sem parâmetros)
- **Output:** Cabeçalho com timestamp
- **Verificações:** Nenhuma

### Seção 2: GRUPO 1 (Servers 3-8)
- **Linhas:** 20-104
- **Input:** Script `/home/pcpweb/rename_srf.sh` disponível nos servidores
- **Output:** 6 execuções SSH com logs individuais
- **Verificações:** 6 × ERRORLEVEL
- **Contadores:** successCount e failCount atualizados

### Seção 3: GRUPO 2 (Servers 1-2)
- **Linhas:** 106-136
- **Input:** Script `/home/pcpweb/rename_srf.sh` disponível
- **Output:** 2 execuções SSH com logs individuais
- **Verificações:** 2 × ERRORLEVEL
- **Contadores:** successCount e failCount atualizados

### Seção 4: GRUPO 3 (Servers 20-23)
- **Linhas:** 138-202
- **Input:** Script `/home/pcpweb/rename_srf.sh` disponível
- **Output:** 4 execuções SSH com logs individuais
- **Verificações:** 4 × ERRORLEVEL
- **Contadores:** successCount e failCount atualizados

### Seção 5: GRUPO 4 (Servers 24-27)
- **Linhas:** 204-222
- **Input:** Script `/home/pcpweb/rename_srf_new_servers.sh` no servidor 10.238.7.12
- **Output:** 1 execução SSH (controla 4 servidores)
- **Verificações:** 1 × ERRORLEVEL
- **Contadores:** +4 ou -4 de uma vez

### Seção 6: Resumo e Exit
- **Linhas:** 224-250
- **Input:** Valores de contadores
- **Output:** Resumo estatístico, mensagens finais
- **Verificações:** failCount > 0
- **Exit Code:** 0 (sucesso) ou 1 (falha parcial/total)

## 🔍 Cenários de Uso

### Cenário 1: Rename Bem-Sucedido em Todos os Servidores
**Entrada:**
```cmd
rename_srf_az.bat
```

**Saída Esperada:**
```
========================================
SCRIPT: rename_srf_az.bat
PROPOSITO: Renomear arquivos SRF nos servidores Siebel
DATA/HORA: 30/10/2025 15:20:45
========================================

[INFO] Iniciando processo de rename de arquivos SRF...

========================================
[GRUPO 1] Renomeando SRF nos servidores 3 a 8
========================================

[Server 3] Conectando em pcpweb@10.238.5.32...
[Server 3] Script rename_srf.sh executado com sucesso em 10.238.5.32

... (continua para todos os 16 servidores) ...

========================================
RESUMO DO RENAME DE ARQUIVOS SRF
========================================
Total de servidores: 16
Scripts executados com sucesso: 16
Scripts com falha: 0
========================================

[SUCESSO] Todos os scripts de rename foram executados com sucesso
[INFO] Arquivos SRF renomeados em todos os 16 servidores
[INFO] Os servidores estao prontos para restart com novo SRF

[INFO] Script finalizado com sucesso
```

**Exit Code:** 0  
**Próximo Passo:** Executar `start_srv_az.bat` para reiniciar servidores

### Cenário 2: Falha em 1 Servidor Individual
**Entrada:**
```cmd
rename_srf_az.bat
rem Script rename_srf.sh não encontrado em 10.238.5.34
```

**Saída Esperada:**
```
...
[Server 5] Conectando em pcpweb@10.238.5.34...
[ERRO] Falha ao executar script no servidor 5 (10.238.5.34) - ERRORLEVEL: 127
...

========================================
RESUMO DO RENAME DE ARQUIVOS SRF
========================================
Total de servidores: 16
Scripts executados com sucesso: 15
Scripts com falha: 1
========================================

[AVISO] Processo concluido com falhas
[AVISO] Verifique os logs dos servidores que falharam
[AVISO] Alguns servidores podem ter arquivos SRF com nome antigo

[INFO] Script finalizado com codigo de erro
```

**Exit Code:** 1  
**Ação Necessária:** Verificar servidor 5, corrigir e re-executar

### Cenário 3: Falha no Script Remoto (Grupo 4)
**Entrada:**
```cmd
rename_srf_az.bat
rem Script rename_srf_new_servers.sh com erro
```

**Saída Esperada:**
```
...
========================================
[GRUPO 4] Renomeando SRF nos servidores 24 a 27
========================================

[Servers 24-27] Executando script remoto em pcpweb@10.238.7.12...
[INFO] Script: /home/pcpweb/rename_srf_new_servers.sh
[ERRO] Falha ao executar script remoto para servidores 24-27 - ERRORLEVEL: 1
...

========================================
RESUMO DO RENAME DE ARQUIVOS SRF
========================================
Total de servidores: 16
Scripts executados com sucesso: 12
Scripts com falha: 4
========================================

[AVISO] Processo concluido com falhas
[AVISO] Verifique os logs dos servidores que falharam
[AVISO] Alguns servidores podem ter arquivos SRF com nome antigo

[INFO] Script finalizado com codigo de erro
```

**Exit Code:** 1  
**Ação Necessária:** Investigar script remoto, verificar servidores 24-27

### Cenário 4: Integração com Pipeline Azure DevOps
**Pipeline YAML:**
```yaml
- task: BatchScript@1
  displayName: 'Rename SRF Files on All Servers'
  inputs:
    filename: 'tech_products/win-vivocorp/siebel_devops/paliativo/prod/rename_srf_az.bat'
  continueOnError: false

- task: PowerShell@2
  displayName: 'Validate Rename Success'
  inputs:
    targetType: 'inline'
    script: |
      if ($LASTEXITCODE -ne 0) {
        Write-Error "Falha ao renomear SRF em alguns servidores"
        Write-Host "##vso[task.complete result=Failed;]STOP"
      }
      Write-Host "SRF renomeado com sucesso em todos os servidores"

- task: BatchScript@1
  displayName: 'Restart Siebel Servers'
  inputs:
    filename: 'tech_products/win-vivocorp/siebel_devops/paliativo/prod/start_srv_az.bat'
  condition: succeeded()
```

**Resultado:** Pipeline só prossegue para restart se todos os renames forem bem-sucedidos

## 📝 Observações Importantes

### 1. Scripts Remotos Utilizados
- **rename_srf.sh:** Executado individualmente em 12 servidores (3-8, 1-2, 20-23)
- **rename_srf_new_servers.sh:** Executado centralizadamente no 10.238.7.12 para controlar servidores 24-27

### 2. Ordem de Execução dos Grupos
O script executa na ordem: **3-8 → 1-2 → 20-23 → 24-27**

Esta ordem pode ser estratégica:
- Grupo 1 (3-8): Maior quantidade de servidores primeiro
- Grupo 2 (1-2): Servidores críticos no meio
- Grupo 3 (20-23): Cluster intermediário
- Grupo 4 (24-27): Servidores mais novos por último

### 3. Diferença entre Scripts Remotos
- **rename_srf.sh:** Script individual, executa em contexto local de cada servidor
- **rename_srf_new_servers.sh:** Script agregador, faz SSH para múltiplos servidores

### 4. Importância do Exit Code
Este script é tipicamente executado **ANTES** de reiniciar servidores:
1. `rename_srf_az.bat` → Renomeia arquivos
2. `start_srv_az.bat` → Reinicia com novo SRF

Se o rename falhar, o restart **não deve ocorrer** (servidores iniciariam com SRF antigo).

### 5. Contadores e Grupo 4
O Grupo 4 incrementa/decrementa **4 de uma vez**:
```batch
set /A successCount+=4  rem ou failCount+=4
```

Isso reflete que um único comando SSH controla 4 servidores simultaneamente.

## 🚀 Próximos Passos

1. **Validar Scripts Remotos:**
   - Confirmar existência de `/home/pcpweb/rename_srf.sh` em todos os 12 servidores individuais
   - Confirmar existência de `/home/pcpweb/rename_srf_new_servers.sh` em 10.238.7.12
   - Testar execução manual dos scripts

2. **Testar em Desenvolvimento:**
   - Executar rename_srf_az.bat em ambiente de DEV
   - Validar logs gerados
   - Confirmar contadores funcionando corretamente

3. **Integrar ao Pipeline:**
   - Adicionar task no YAML do Azure DevOps
   - Configurar dependência: rename → start (condicional)
   - Implementar notificações de falha

4. **Documentar Procedimento de Rollback:**
   - Como reverter rename se necessário
   - Script de rollback (rename de volta ao nome original)
   - Procedimento de emergência

5. **Monitoramento:**
   - Dashboard de sucesso/falha por servidor
   - Alertas para falhas recorrentes em servidores específicos
   - Histórico de execuções

## 📚 Referências

- **SCRIPT_IMPROVEMENT_PROMPT.md:** Guia mestre de melhorias
- **Script Original:** `rename_srf.bat` (19 linhas)
- **Script Melhorado:** `rename_srf_az.bat` (250 linhas)
- **Scripts Relacionados:**
  - `sftp_srf_new_az.bat`: Distribui SRF para servidores
  - `stop_srv_az.bat`: Para servidores antes do rename
  - `start_srv_az.bat`: Reinicia servidores após rename
- **Azure DevOps:** CodePlay Pipelines Framework

---

**Autor:** Azure DevOps Copilot  
**Data:** 2025-10-30  
**Versão:** 1.0
