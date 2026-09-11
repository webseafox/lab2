# Análise de Melhorias: start_srv_new.bat → start_srv_new_az.bat

## 📋 Informações do Script

- **Script Original:** `start_srv_new.bat`
- **Script Melhorado:** `start_srv_new_az.bat`
- **Propósito:** Iniciar servidores Siebel 1 e 2 com delays de estabilização
- **Ambiente:** Produção Siebel CRM v8.1
- **Data da Análise:** 2025-10-30

## 📊 Métricas de Melhoria

| Métrica | Antes | Depois | Variação |
|---------|-------|--------|----------|
| **Linhas Totais** | 10 | 139 | +1290% |
| **Comandos echo** | 0 | 40+ | ∞ |
| **Verificações ERRORLEVEL** | 0 | 4 | +4 |
| **Contadores** | 0 | 3 | +3 |
| **Delays monitorados** | 2 | 2 | - |
| **Labels (goto)** | 0 | 2 | +2 |
| **Tratamento de erro** | ❌ Inexistente | ✅ Completo | - |

## 🎯 Melhorias Implementadas

### 1. ✅ Verbosidade com Timestamps de Delay

**ANTES:**
```batch
rem starting server 1 e 2
ssh pcpweb@10.238.7.12 "sudo -u supweb /opt/web/siebel/siebel811/siebelsrv1/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.12 "sleep 260"
```

**DEPOIS:**
```batch
echo ========================================
echo [SERVIDOR 1] Iniciando servidor 1
echo ========================================
echo.

echo [Server 1] Conectando em pcpweb@10.238.7.12 ^(siebelsrv1^)...
echo [Server 1] Executando start_srv.sh em background...
ssh pcpweb@10.238.7.12 "sudo -u supweb /opt/web/siebel/siebel811/siebelsrv1/siebsrvr/scripts/start_srv.sh &>/dev/null &"
if !ERRORLEVEL! EQU 0 (
    echo [Server 1] Comando de start enviado com sucesso para 10.238.7.12 ^(siebelsrv1^)
    set /A successCount+=1
) else (
    echo [ERRO] Falha ao enviar comando para servidor 1 ^(10.238.7.12/siebelsrv1^) - ERRORLEVEL: !ERRORLEVEL!
    set /A failCount+=1
    goto :servidor2
)
echo.

echo [Server 1] Aguardando 260 segundos para estabilizacao do servidor...
echo [INFO] Inicio do delay: %time%
ssh pcpweb@10.238.7.12 "sleep 260"
if !ERRORLEVEL! EQU 0 (
    echo [Server 1] Delay de 260 segundos concluido com sucesso
    echo [INFO] Fim do delay: %time%
) else (
    echo [AVISO] Erro durante delay, mas continuando - ERRORLEVEL: !ERRORLEVEL!
)
```

**Impacto:**
- Timestamps de início e fim de cada delay (260s = ~4.3 minutos)
- Possibilidade de calcular tempo real de espera
- Logs rastreáveis para cada fase (start + delay)

### 2. ✅ Cabeçalho com Informação de Tempo

**ANTES:**
```batch
@echo off
setlocal enableextensions

rem starting server 1 e 2
```

**DEPOIS:**
```batch
@echo off
setlocal enabledelayedexpansion

echo ========================================
echo SCRIPT: start_srv_new_az.bat
echo PROPOSITO: Iniciar servidores Siebel 1 e 2 com delay
echo DATA/HORA: %date% %time%
echo ========================================
echo.

echo [INFO] Iniciando processo de start dos servidores Siebel 1 e 2...
echo [INFO] Este processo inclui delays de 260 segundos entre servidores
```

**Impacto:**
- Expectativa clara de delays longos (520 segundos total = ~8.7 minutos)
- Usuário/pipeline sabe que é operação demorada
- `enabledelayedexpansion` para contadores

### 3. ✅ Tratamento de Erros com Goto

**ANTES:**
```batch
ssh pcpweb@10.238.7.12 "sudo -u supweb /opt/web/siebel/siebel811/siebelsrv1/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.12 "sleep 260"
ssh pcpweb@10.238.7.13 "sudo -u supweb /opt/web/siebel/siebel811/siebelsrv2/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.13 "sleep 260"
rem Nenhuma verificação - continua mesmo com falhas
```

**DEPOIS:**
```batch
ssh pcpweb@10.238.7.12 "sudo -u supweb /opt/web/siebel/siebel811/siebelsrv1/siebsrvr/scripts/start_srv.sh &>/dev/null &"
if !ERRORLEVEL! EQU 0 (
    echo [Server 1] Comando de start enviado com sucesso
    set /A successCount+=1
) else (
    echo [ERRO] Falha ao enviar comando para servidor 1 - ERRORLEVEL: !ERRORLEVEL!
    set /A failCount+=1
    goto :servidor2  rem Pula delay se falhar
)

echo [Server 1] Aguardando 260 segundos para estabilizacao...
ssh pcpweb@10.238.7.12 "sleep 260"
if !ERRORLEVEL! EQU 0 (
    echo [Server 1] Delay concluido com sucesso
) else (
    echo [AVISO] Erro durante delay, mas continuando
)

:servidor2
ssh pcpweb@10.238.7.13 "sudo -u supweb /opt/web/siebel/siebel811/siebelsrv2/siebsrvr/scripts/start_srv.sh &>/dev/null &"
if !ERRORLEVEL! EQU 0 (
    echo [Server 2] Comando de start enviado com sucesso
    set /A successCount+=1
) else (
    echo [ERRO] Falha ao enviar comando para servidor 2 - ERRORLEVEL: !ERRORLEVEL!
    set /A failCount+=1
    goto :resumo  rem Pula delay se falhar
)
```

**Impacto:**
- Se servidor 1 falhar, pula delay e vai direto para servidor 2
- Se servidor 2 falhar, pula delay e vai direto para resumo
- Não desperdiça 260 segundos em delays inúteis quando há falha
- Economia de até 520 segundos em caso de falha total

### 4. ✅ Contadores Estatísticos

**ANTES:**
```batch
exit 0
rem Sempre sucesso, sem métricas
```

**DEPOIS:**
```batch
set totalServers=2
set successCount=0
set failCount=0

rem ... após cada operação ...
set /A successCount+=1  rem ou failCount+=1

rem ... no final ...
echo ========================================
echo RESUMO DO START DOS SERVIDORES
echo ========================================
echo Total de servidores: %totalServers%
echo Comandos enviados com sucesso: !successCount!
echo Comandos com falha: !failCount!
```

**Impacto:**
- Visão clara de quantos servidores iniciaram
- Base para alertas (ex: se successCount < 2)
- Métricas para dashboard de operações

### 5. ✅ Cálculo de Tempo Total

**ANTES:**
```batch
rem Sem informação de tempo total
```

**DEPOIS:**
```batch
if !successCount! EQU 2 (
    echo [INFO] Tempo total de delays: 520 segundos ^(~8.7 minutos^)
) else if !successCount! EQU 1 (
    echo [INFO] Tempo total de delays: 260 segundos ^(~4.3 minutos^)
) else (
    echo [INFO] Nenhum delay executado devido a falhas
)
```

**Impacto:**
- Informação clara do tempo gasto em delays
- Facilita troubleshooting de timeouts em pipelines
- Usuário sabe quanto tempo foi investido

### 6. ✅ Exit Code Baseado em Resultados

**ANTES:**
```batch
exit 0
rem Sempre retorna sucesso
```

**DEPOIS:**
```batch
if !failCount! GTR 0 (
    echo [AVISO] Processo concluido com falhas
    echo [AVISO] Verifique os logs dos servidores que falharam
    echo [AVISO] Servidores que falharam NAO foram iniciados
    echo.
    echo [INFO] Script finalizado com codigo de erro
    exit /B 1
) else (
    echo [SUCESSO] Todos os comandos de start foram enviados com sucesso
    echo [INFO] Servidores 1 e 2 estao em processo de inicializacao
    echo [INFO] Aguarde alguns minutos adicionais para completa inicializacao
    echo [INFO] Recomendacao: Verificar status dos servidores apos 5-10 minutos
    echo.
    echo [INFO] Script finalizado com sucesso
    exit /B 0
)
```

**Impacto:**
- Exit code 0 = ambos os servidores iniciados
- Exit code 1 = pelo menos uma falha
- Pipeline pode decidir próximos passos

### 7. ✅ Verificação de Delays

**ANTES:**
```batch
ssh pcpweb@10.238.7.12 "sleep 260"
rem Sem verificação se delay completou
```

**DEPOIS:**
```batch
echo [Server 1] Aguardando 260 segundos para estabilizacao do servidor...
echo [INFO] Inicio do delay: %time%
ssh pcpweb@10.238.7.12 "sleep 260"
if !ERRORLEVEL! EQU 0 (
    echo [Server 1] Delay de 260 segundos concluido com sucesso
    echo [INFO] Fim do delay: %time%
) else (
    echo [AVISO] Erro durante delay, mas continuando - ERRORLEVEL: !ERRORLEVEL!
)
```

**Impacto:**
- Detecção de desconexões SSH durante delay
- Timestamps permitem validar se delay foi realmente 260s
- Avisos se delay for interrompido

### 8. ✅ Uso de Labels (goto) para Controle de Fluxo

**ANTES:**
```batch
rem Fluxo linear, sem controle
```

**DEPOIS:**
```batch
if !ERRORLEVEL! NEQ 0 (
    goto :servidor2  rem Pula delay do servidor 1
)

:servidor2
rem Código do servidor 2

if !ERRORLEVEL! NEQ 0 (
    goto :resumo  rem Pula delay do servidor 2
)

:resumo
rem Resumo estatístico
```

**Impacto:**
- Não desperdiça tempo com delays após falhas
- Fluxo mais eficiente
- Código mais legível com seções bem definidas

## 🏗️ Topologia dos Servidores

### Servidor 1
- **Host:** 10.238.7.12
- **User:** pcpweb
- **Path:** `/opt/web/siebel/siebel811/siebelsrv1/siebsrvr/scripts/start_srv.sh`
- **Instância:** siebelsrv1
- **Delay Após Start:** 260 segundos (~4.3 minutos)
- **Ordem:** 1º

### Servidor 2
- **Host:** 10.238.7.13
- **User:** pcpweb
- **Path:** `/opt/web/siebel/siebel811/siebelsrv2/siebsrvr/scripts/start_srv.sh`
- **Instância:** siebelsrv2
- **Delay Após Start:** 260 segundos (~4.3 minutos)
- **Ordem:** 2º

**Tempo Total:** 520 segundos (~8.7 minutos)

**Nota:** Delays são para estabilização do servidor Siebel antes de iniciar o próximo

## 📈 Fluxo de Execução

```
┌─────────────────────────────────────────────────┐
│  INÍCIO: start_srv_new_az.bat                   │
│  - Exibe cabeçalho com timestamp                │
│  - Avisa sobre delays de 260s                   │
│  - Inicializa contadores (2, 0, 0)              │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│  SERVIDOR 1: 10.238.7.12 (siebelsrv1)          │
│  ┌──────────────────────────────────────────┐   │
│  │  1. Echo "Conectando..."                 │   │
│  │  2. SSH start_srv.sh &>/dev/null &       │   │
│  │  3. Verifica ERRORLEVEL                  │   │
│  └──────────────────────────────────────────┘   │
└──────────────────┬──────────────────────────────┘
                   │
              ┌────┴────┐
              │ ERRORLEVEL = 0? │
              └────┬────┘
                   │
        ┌──────────┴──────────┐
        │ SIM               NÃO │
        ▼                       ▼
┌───────────────┐      ┌───────────────┐
│ Sucesso       │      │ Falha         │
│ successCount++│      │ failCount++   │
│               │      │ goto servidor2│
└───────┬───────┘      └───────┬───────┘
        │                      │
        ▼                      │
┌───────────────┐              │
│ DELAY 260s    │              │
│ Timestamp ini │              │
│ sleep 260     │              │
│ Timestamp fim │              │
│ Verifica OK   │              │
└───────┬───────┘              │
        │                      │
        └──────────┬───────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│  SERVIDOR 2: 10.238.7.13 (siebelsrv2)          │
│  ┌──────────────────────────────────────────┐   │
│  │  1. Echo "Conectando..."                 │   │
│  │  2. SSH start_srv.sh &>/dev/null &       │   │
│  │  3. Verifica ERRORLEVEL                  │   │
│  └──────────────────────────────────────────┘   │
└──────────────────┬──────────────────────────────┘
                   │
              ┌────┴────┐
              │ ERRORLEVEL = 0? │
              └────┬────┘
                   │
        ┌──────────┴──────────┐
        │ SIM               NÃO │
        ▼                       ▼
┌───────────────┐      ┌───────────────┐
│ Sucesso       │      │ Falha         │
│ successCount++│      │ failCount++   │
│               │      │ goto resumo   │
└───────┬───────┘      └───────┬───────┘
        │                      │
        ▼                      │
┌───────────────┐              │
│ DELAY 260s    │              │
│ Timestamp ini │              │
│ sleep 260     │              │
│ Timestamp fim │              │
│ Verifica OK   │              │
└───────┬───────┘              │
        │                      │
        └──────────┬───────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│  RESUMO ESTATÍSTICO                             │
│  - Total: 2 servidores                          │
│  - Sucessos: !successCount!                     │
│  - Falhas: !failCount!                          │
│  - Tempo total: 0/260/520 segundos              │
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
│ Falhas       │      │ Ambos OK     │
│ Servidores   │      │ Aguardar +5m │
│ não iniciados│      │ para status  │
│ exit /B 1    │      │ exit /B 0    │
└──────────────┘      └──────────────┘
```

## 🎓 Detalhamento por Seção

### Seção 1: Inicialização
- **Linhas:** 1-20
- **Input:** Nenhum
- **Output:** Cabeçalho com aviso de delays
- **Tempo:** < 1 segundo

### Seção 2: Servidor 1 - Start
- **Linhas:** 22-41
- **Input:** Conexão SSH, script start_srv.sh disponível
- **Output:** Comando SSH, verificação ERRORLEVEL
- **Tempo:** ~1-2 segundos
- **Ação em Falha:** `goto :servidor2` (pula delay)

### Seção 3: Servidor 1 - Delay
- **Linhas:** 43-54
- **Input:** Servidor 1 iniciado com sucesso
- **Output:** Delay de 260 segundos com timestamps
- **Tempo:** 260 segundos (~4.3 minutos)
- **Propósito:** Estabilização do servidor Siebel

### Seção 4: Servidor 2 - Start
- **Linhas:** 56-76
- **Input:** Conexão SSH, script start_srv.sh disponível
- **Output:** Comando SSH, verificação ERRORLEVEL
- **Tempo:** ~1-2 segundos
- **Ação em Falha:** `goto :resumo` (pula delay)

### Seção 5: Servidor 2 - Delay
- **Linhas:** 78-89
- **Input:** Servidor 2 iniciado com sucesso
- **Output:** Delay de 260 segundos com timestamps
- **Tempo:** 260 segundos (~4.3 minutos)
- **Propósito:** Estabilização do servidor Siebel

### Seção 6: Resumo e Exit
- **Linhas:** 91-139
- **Input:** Valores de contadores
- **Output:** Resumo, tempo total, mensagens finais
- **Exit Code:** 0 (sucesso) ou 1 (falha)

## 🔍 Cenários de Uso

### Cenário 1: Start Bem-Sucedido em Ambos os Servidores
**Entrada:**
```cmd
start_srv_new_az.bat
```

**Saída Esperada:**
```
========================================
SCRIPT: start_srv_new_az.bat
PROPOSITO: Iniciar servidores Siebel 1 e 2 com delay
DATA/HORA: 30/10/2025 16:00:00
========================================

[INFO] Iniciando processo de start dos servidores Siebel 1 e 2...
[INFO] Este processo inclui delays de 260 segundos entre servidores

========================================
[SERVIDOR 1] Iniciando servidor 1
========================================

[Server 1] Conectando em pcpweb@10.238.7.12 (siebelsrv1)...
[Server 1] Executando start_srv.sh em background...
[Server 1] Comando de start enviado com sucesso para 10.238.7.12 (siebelsrv1)

[Server 1] Aguardando 260 segundos para estabilizacao do servidor...
[INFO] Inicio do delay: 16:00:05
[Server 1] Delay de 260 segundos concluido com sucesso
[INFO] Fim do delay: 16:04:25

========================================
[SERVIDOR 2] Iniciando servidor 2
========================================

[Server 2] Conectando em pcpweb@10.238.7.13 (siebelsrv2)...
[Server 2] Executando start_srv.sh em background...
[Server 2] Comando de start enviado com sucesso para 10.238.7.13 (siebelsrv2)

[Server 2] Aguardando 260 segundos para estabilizacao do servidor...
[INFO] Inicio do delay: 16:04:30
[Server 2] Delay de 260 segundos concluido com sucesso
[INFO] Fim do delay: 16:08:50

========================================
RESUMO DO START DOS SERVIDORES
========================================
Total de servidores: 2
Comandos enviados com sucesso: 2
Comandos com falha: 0
========================================

[INFO] Tempo total de delays: 520 segundos (~8.7 minutos)

[SUCESSO] Todos os comandos de start foram enviados com sucesso
[INFO] Servidores 1 e 2 estao em processo de inicializacao
[INFO] Aguarde alguns minutos adicionais para completa inicializacao
[INFO] Recomendacao: Verificar status dos servidores apos 5-10 minutos

[INFO] Script finalizado com sucesso
```

**Exit Code:** 0  
**Tempo Total:** ~8.7 minutos (520s delays + ~5s comandos)

### Cenário 2: Falha no Servidor 1
**Entrada:**
```cmd
start_srv_new_az.bat
rem Script start_srv.sh não encontrado em servidor 1
```

**Saída Esperada:**
```
========================================
[SERVIDOR 1] Iniciando servidor 1
========================================

[Server 1] Conectando em pcpweb@10.238.7.12 (siebelsrv1)...
[Server 1] Executando start_srv.sh em background...
[ERRO] Falha ao enviar comando para servidor 1 (10.238.7.12/siebelsrv1) - ERRORLEVEL: 127

========================================
[SERVIDOR 2] Iniciando servidor 2
========================================

[Server 2] Conectando em pcpweb@10.238.7.13 (siebelsrv2)...
[Server 2] Executando start_srv.sh em background...
[Server 2] Comando de start enviado com sucesso para 10.238.7.13 (siebelsrv2)

[Server 2] Aguardando 260 segundos para estabilizacao do servidor...
[INFO] Inicio do delay: 16:00:10
[Server 2] Delay de 260 segundos concluido com sucesso
[INFO] Fim do delay: 16:04:30

========================================
RESUMO DO START DOS SERVIDORES
========================================
Total de servidores: 2
Comandos enviados com sucesso: 1
Comandos com falha: 1
========================================

[INFO] Tempo total de delays: 260 segundos (~4.3 minutos)

[AVISO] Processo concluido com falhas
[AVISO] Verifique os logs dos servidores que falharam
[AVISO] Servidores que falharam NAO foram iniciados

[INFO] Script finalizado com codigo de erro
```

**Exit Code:** 1  
**Tempo Economizado:** 260 segundos (não esperou delay do servidor 1)

### Cenário 3: Falha em Ambos os Servidores
**Entrada:**
```cmd
start_srv_new_az.bat
rem Conexão SSH indisponível
```

**Saída Esperada:**
```
========================================
[SERVIDOR 1] Iniciando servidor 1
========================================

[Server 1] Conectando em pcpweb@10.238.7.12 (siebelsrv1)...
[Server 1] Executando start_srv.sh em background...
[ERRO] Falha ao enviar comando para servidor 1 (10.238.7.12/siebelsrv1) - ERRORLEVEL: 255

========================================
[SERVIDOR 2] Iniciando servidor 2
========================================

[Server 2] Conectando em pcpweb@10.238.7.13 (siebelsrv2)...
[Server 2] Executando start_srv.sh em background...
[ERRO] Falha ao enviar comando para servidor 2 (10.238.7.13/siebelsrv2) - ERRORLEVEL: 255

========================================
RESUMO DO START DOS SERVIDORES
========================================
Total de servidores: 2
Comandos enviados com sucesso: 0
Comandos com falha: 2
========================================

[INFO] Nenhum delay executado devido a falhas

[AVISO] Processo concluido com falhas
[AVISO] Verifique os logs dos servidores que falharam
[AVISO] Servidores que falharam NAO foram iniciados

[INFO] Script finalizado com codigo de erro
```

**Exit Code:** 1  
**Tempo Economizado:** 520 segundos (não esperou nenhum delay)

### Cenário 4: Integração com Pipeline Azure DevOps
**Pipeline YAML:**
```yaml
- task: BatchScript@1
  displayName: 'Start Siebel Servers 1 and 2'
  inputs:
    filename: 'tech_products/win-vivocorp/siebel_devops/paliativo/prod/start_srv_new_az.bat'
  continueOnError: false
  timeoutInMinutes: 15  # 8.7 min de delays + margem

- task: PowerShell@2
  displayName: 'Validate Server Status'
  inputs:
    targetType: 'inline'
    script: |
      if ($LASTEXITCODE -ne 0) {
        Write-Error "Falha ao iniciar servidores Siebel"
        exit 1
      }
      Write-Host "Servidores iniciados com sucesso"
      Write-Host "Aguardando estabilizacao adicional..."
      Start-Sleep -Seconds 300  # Aguarda mais 5 minutos
      
- task: BatchScript@1
  displayName: 'Check Server Health'
  inputs:
    filename: 'tech_products/win-vivocorp/siebel_devops/paliativo/prod/check_status.bat'
  condition: succeeded()
```

**Resultado:** Pipeline aguarda ~14 minutos (8.7 min do script + 5 min extra) antes de validar status

## 📝 Observações Importantes

### 1. Por Que Delays de 260 Segundos?
- **Inicialização Siebel:** Siebel CRM demora para carregar componentes
- **Estabilização:** Necessário para conexões de banco de dados, cache, etc.
- **Evita Sobrecarga:** Iniciar todos de uma vez pode sobrecarregar recursos
- **Prática Comum:** Delays são padrão em startups de servidores Siebel

### 2. Diferença entre enableextensions e enabledelayedexpansion
**ANTES:**
```batch
setlocal enableextensions
rem Suporta comandos estendidos, mas não delayed expansion
```

**DEPOIS:**
```batch
setlocal enabledelayedexpansion
rem Necessário para !successCount! dentro de blocos if
```

### 3. Background Execution (&>/dev/null &)
- `&>/dev/null`: Redireciona stdout e stderr para /dev/null (silencia output)
- `&`: Executa em background no servidor remoto
- Script Windows retorna imediatamente
- Por isso precisa do delay manual (sleep 260)

### 4. Paths Diferentes para siebelsrv1 e siebelsrv2
**Servidor 1:**
```
/opt/web/siebel/siebel811/siebelsrv1/siebsrvr/scripts/start_srv.sh
```

**Servidor 2:**
```
/opt/web/siebel/siebel811/siebelsrv2/siebsrvr/scripts/start_srv.sh
```

Ambos os servidores têm instâncias separadas do Siebel.

### 5. Lógica de goto para Economia de Tempo
```batch
if falhou:
    goto :servidor2  # Não espera delay de 260s
```

**Benefício:** Em caso de falha total, economiza 520 segundos (~8.7 minutos)

### 6. Por Que Apenas 2 Servidores?
Este script é específico para servidores 1 e 2, que possivelmente:
- São servidores críticos que precisam de atenção especial
- Requerem delays de estabilização mais longos
- São iniciados separadamente dos demais (3-8, 20-27)

Provavelmente existe um `start_srv_az.bat` diferente para os outros 14 servidores.

## 🚀 Próximos Passos

1. **Testar em Desenvolvimento:**
   - Validar delays de 260s são suficientes
   - Confirmar estabilização dos servidores
   - Verificar se timestamps estão corretos

2. **Otimizar Delays:**
   - Monitorar tempo real de estabilização
   - Avaliar se 260s pode ser reduzido
   - Considerar delays adaptativos baseados em health checks

3. **Integrar ao Pipeline:**
   - Configurar timeout adequado (15+ minutos)
   - Adicionar verificação de status pós-start
   - Implementar retry em caso de falha

4. **Health Checks:**
   - Criar script de validação de status
   - Verificar se servidores estão realmente UP após delays
   - Automatizar verificação de componentes Siebel

5. **Documentar Dependências:**
   - Clarificar por que apenas 2 servidores
   - Documentar relação com outros scripts de start
   - Mapear sequência completa de startup

## 📚 Referências

- **SCRIPT_IMPROVEMENT_PROMPT.md:** Guia mestre de melhorias
- **Script Original:** `start_srv_new.bat` (10 linhas)
- **Script Melhorado:** `start_srv_new_az.bat` (139 linhas)
- **Scripts Relacionados:**
  - `stop_srv_az.bat`: Para servidores antes de manutenção
  - `rename_srf_az.bat`: Renomeia SRF antes do start
  - `start_srv_az.bat`: Inicia outros servidores (3-8, 20-27)
- **Siebel Documentation:** CRM v8.1 Server Startup Procedures
- **Azure DevOps:** CodePlay Pipelines Framework

---

**Autor:** Azure DevOps Copilot  
**Data:** 2025-10-30  
**Versão:** 1.0
