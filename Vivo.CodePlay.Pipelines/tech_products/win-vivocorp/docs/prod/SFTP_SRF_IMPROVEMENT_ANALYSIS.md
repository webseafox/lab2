# Análise de Melhorias: sftp_srf_new.bat → sftp_srf_new_az.bat

## 📊 Resumo Executivo

Script analisado: `sftp_srf_new.bat`  
Script melhorado: `sftp_srf_new_az.bat`  
Data: 2025-10-30  
Padrões aplicados: SCRIPT_IMPROVEMENT_PROMPT.md

---

## 🔍 Problemas Identificados no Script Original

### 1. **Ausência Total de Logging**
- ❌ Nenhuma mensagem echo (apenas comentários REM)
- ❌ Sem feedback de progresso
- ❌ Impossível rastrear qual servidor falhou
- ❌ Sem delimitadores de início/fim

### 2. **Repetição Sem Controle**
- ❌ 12 comandos SFTP idênticos sem verificação
- ❌ Nenhuma verificação de ERRORLEVEL
- ❌ Sem contador de sucessos/falhas
- ❌ Impossível saber quantos servidores foram processados

### 3. **Falta de Validação**
- ❌ Não verifica se arquivo SRF fonte existe
- ❌ Copy sem verificação de sucesso
- ❌ SFTP sem confirmação de transferência
- ❌ SSH remoto sem validação

### 4. **Comando Incorreto**
- ❌ Uso de `rm` (Unix) em vez de `del` (Windows)
- ❌ Comando falharia em Windows

### 5. **Documentação Inadequada**
- ❌ Comentários REM não aparecem nos logs
- ❌ Agrupamento de servidores não explicado
- ❌ Script remoto SSH sem documentação
- ❌ Sem identificação de servidores (apenas IPs)

---

## ✅ Melhorias Aplicadas

### 1. **Estrutura Visual e 8 Seções Identificadas**

**ANTES:**
```batch
if not exist C:\Siebel_Devops\PROD\srf\siebel_sia_new.srf ( copy C:\Siebel_Devops\PP\srf\siebel_sia_new.srf C:\Siebel_Devops\PROD\srf )

rem copy srf 3 a 8
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.5.32 22
```

**DEPOIS:**
```batch
@echo off
setlocal enabledelayedexpansion

echo === INICIO DO SCRIPT sftp_srf_new_az.bat ===

REM Seção 1: Inicialização
echo Script de distribuição de arquivo SRF para servidores Siebel PROD
echo Propósito: Copiar arquivo SRF para múltiplos servidores via SFTP
echo Inicialização concluída

REM Inicialização de Contadores
set /a totalServers=0
set /a successCount=0
set /a failCount=0
echo Contadores inicializados: Total=0, Sucesso=0, Falha=0
```

**🎯 Benefícios:**
- Delimitadores visuais claros
- 8 seções identificadas
- Propósito documentado
- Contadores para estatísticas

---

### 2. **Verificação de Arquivo com Validação**

**ANTES:**
```batch
if not exist C:\Siebel_Devops\PROD\srf\siebel_sia_new.srf ( copy C:\Siebel_Devops\PP\srf\siebel_sia_new.srf C:\Siebel_Devops\PROD\srf )
```

**DEPOIS:**
```batch
echo Verificando existência do arquivo SRF em C:\Siebel_Devops\PROD\srf\...

if not exist C:\Siebel_Devops\PROD\srf\siebel_sia_new.srf (
    echo Arquivo siebel_sia_new.srf não encontrado em PROD
    echo Copiando arquivo de C:\Siebel_Devops\PP\srf\ para C:\Siebel_Devops\PROD\srf\...
    
    copy "C:\Siebel_Devops\PP\srf\siebel_sia_new.srf" "C:\Siebel_Devops\PROD\srf\" > nul 2>&1
    
    if !ERRORLEVEL! EQU 0 (
        echo Arquivo SRF copiado com sucesso de PP para PROD
    ) else (
        echo ERRO: Falha ao copiar arquivo SRF (código !ERRORLEVEL!)
        echo Verifique se o arquivo existe em C:\Siebel_Devops\PP\srf\
        echo === FIM DO SCRIPT sftp_srf_new_az.bat ===
        exit /B 1
    )
) else (
    echo Arquivo siebel_sia_new.srf já existe em PROD, prosseguindo com distribuição
)
```

**🎯 Benefícios:**
- Mensagens descritivas antes/depois da operação
- Verificação de ERRORLEVEL no copy
- Exit com erro se cópia falhar (crítico)
- Mensagem quando arquivo já existe

---

### 3. **SFTP Individual com Identificação e Contadores**

**ANTES:**
```batch
rem copy srf 3 a 8
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.5.32 22
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.5.33 22
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.5.34 22
```

**DEPOIS:**
```batch
REM Seção 3: Distribuição para Grupo 1 - Servidores 3 a 8 (10.238.5.32-37)
echo Iniciando distribuição para Grupo 1: Servidores 3 a 8...

echo Transferindo para Servidor 3 (10.238.5.32)...
set /a totalServers+=1
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.5.32 22
if !ERRORLEVEL! EQU 0 (
    set /a successCount+=1
    echo   - Servidor 3: Transferência concluída com sucesso
) else (
    set /a failCount+=1
    echo   - AVISO: Servidor 3: Falha na transferência (código !ERRORLEVEL!)
)

echo Transferindo para Servidor 4 (10.238.5.33)...
set /a totalServers+=1
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.5.33 22
if !ERRORLEVEL! EQU 0 (
    set /a successCount+=1
    echo   - Servidor 4: Transferência concluída com sucesso
) else (
    set /a failCount+=1
    echo   - AVISO: Servidor 4: Falha na transferência (código !ERRORLEVEL!)
)

[... continua para cada servidor ...]

echo Distribuição para Grupo 1 concluída (6 servidores processados)
```

**🎯 Benefícios:**
- Identificação clara de cada servidor (número + IP)
- Contador incrementado para cada servidor
- Verificação de ERRORLEVEL individual
- Contadores de sucesso e falha separados
- Mensagem de conclusão por grupo
- Indentação visual para feedback (- antes da mensagem)

---

### 4. **Agrupamento Documentado de Servidores**

**ANTES:**
```batch
rem copy srf 3 a 8
[6 comandos SFTP]
rem 
rem rem copy srf 1 e 2
[2 comandos SFTP]
rem 
rem rem copy srf 20 a 23
[4 comandos SFTP]
```

**DEPOIS:**
```batch
REM Seção 3: Distribuição para Grupo 1 - Servidores 3 a 8 (10.238.5.32-37)
[6 servidores com logging completo]

REM Seção 4: Distribuição para Grupo 2 - Servidores 1 e 2 (10.238.7.12-13)
[2 servidores com logging completo]

REM Seção 5: Distribuição para Grupo 3 - Servidores 20 a 23 (10.238.6.35-38)
[4 servidores com logging completo]

REM Seção 6: Distribuição para Servidores 24 a 27 via Script Remoto
[SSH remoto documentado]
```

**🎯 Benefícios:**
- Grupos claramente identificados
- Faixa de IPs documentada
- Mensagens de início/fim por grupo
- Facilita identificação de problemas por grupo

---

### 5. **SSH Remoto com Documentação Completa**

**ANTES:**
```batch
rem SDANGELIS [Adicionados novos servidores] 20240620
rem Server 24 a 27

ssh pcpweb@10.238.7.12 /home/pcpweb/sftp_srf_new_servers.sh
```

**DEPOIS:**
```batch
REM Seção 6: Distribuição para Servidores 24 a 27 via Script Remoto
echo Iniciando distribuição para Servidores 24 a 27 via script remoto...
echo Executando script remoto em 10.238.7.12: /home/pcpweb/sftp_srf_new_servers.sh
echo Nota: Script remoto distribui SRF para servidores 24-27 (adicionados em 20240620)

ssh pcpweb@10.238.7.12 /home/pcpweb/sftp_srf_new_servers.sh

if !ERRORLEVEL! EQU 0 (
    echo Distribuição remota para servidores 24-27 concluída com sucesso
    echo Nota: Servidores 24-27 processados via script remoto (não incluídos no contador)
) else (
    echo AVISO: Distribuição remota para servidores 24-27 retornou código de erro !ERRORLEVEL!
    echo Verifique o log do script remoto no servidor 10.238.7.12
)

echo Distribuição via script remoto concluída
```

**🎯 Benefícios:**
- Documenta que servidores 24-27 são via SSH
- Informa data de adição dos servidores
- Verificação de ERRORLEVEL
- Nota que não entram no contador SFTP
- Instruções de troubleshooting

---

### 6. **Limpeza com Comando Correto**

**ANTES:**
```batch
rm C:\Siebel_Devops\PROD\srf\siebel_sia_new.srf
```

**DEPOIS:**
```batch
echo Removendo arquivo SRF local de C:\Siebel_Devops\PROD\srf\...

del "C:\Siebel_Devops\PROD\srf\siebel_sia_new.srf" /f /q > nul 2>&1

if !ERRORLEVEL! EQU 0 (
    echo Arquivo siebel_sia_new.srf removido com sucesso
) else (
    echo AVISO: Falha ao remover arquivo siebel_sia_new.srf (código !ERRORLEVEL!)
)

echo Limpeza concluída
```

**🎯 Benefícios:**
- Usa `DEL` em vez de `RM` (comando Windows correto)
- Aspas no caminho
- Flags `/f /q` para forçar e silenciar
- Redirecionamento `> nul 2>&1`
- Verificação de ERRORLEVEL
- Mensagens de status

---

### 7. **Resumo Final Completo com Estatísticas**

**ANTES:**
```batch
[script termina sem resumo]
```

**DEPOIS:**
```batch
echo.
echo ====================================================
echo RESUMO DA DISTRIBUIÇÃO DE SRF
echo ====================================================
echo Total de servidores SFTP processados: !totalServers!
echo Transferências bem-sucedidas: !successCount!
echo Transferências com falha: !failCount!
echo.
echo Nota: Servidores 24-27 foram processados via script remoto
echo       e não estão incluídos nas estatísticas acima.
echo ====================================================
echo.

if !failCount! GTR 0 (
    echo ATENÇÃO: Algumas transferências falharam. Verifique os logs acima.
    echo === FIM DO SCRIPT sftp_srf_new_az.bat ===
    exit /B 1
) else (
    echo Todas as transferências SFTP foram concluídas com sucesso!
    echo === FIM DO SCRIPT sftp_srf_new_az.bat ===
    exit /B 0
)
```

**🎯 Benefícios:**
- Resumo visual com delimitadores
- Estatísticas completas (total, sucesso, falha)
- Nota sobre servidores remotos
- Exit code diferenciado (0 sucesso, 1 falha)
- Mensagem final contextual

---

## 🔄 Fluxo do Script Melhorado

```
┌─────────────────────────────────────────┐
│  1. INICIALIZAÇÃO                       │
│  - Delimitador de início                │
│  - Documentação do propósito            │
│  - Inicialização de contadores          │
│  - totalServers=0, success=0, fail=0    │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  2. VERIFICAÇÃO DO ARQUIVO SRF          │
│  - Verifica PROD\srf\siebel_sia_new.srf │
└──────────────┬──────────────────────────┘
               │
       ┌───────┴────────┐
       │                │
       ▼                ▼
┌────────────┐   ┌──────────────┐
│ EXISTE     │   │ NÃO EXISTE   │
│            │   │              │
│ - Mensagem │   │ - Copy de PP │
│ - Continua │   │ - Verifica   │
└──────┬─────┘   │   ERRORLEVEL │
       │         └──────┬───────┘
       │                │
       │         ┌──────┴────────┐
       │         │               │
       │         ▼               ▼
       │   ┌─────────┐    ┌──────────┐
       │   │ SUCESSO │    │ FALHA    │
       │   │         │    │          │
       │   │ Continua│    │ Exit /B 1│
       │   └────┬────┘    └──────────┘
       │        │
       └────────┴─────────────────┐
                                  │
                                  ▼
               ┌─────────────────────────────────────┐
               │  3. GRUPO 1: SERVIDORES 3-8         │
               │  - 6 servidores: 10.238.5.32-37     │
               │  - SFTP individual com verificação  │
               │  - Contador: total++, success/fail++│
               └──────────────┬──────────────────────┘
                              │
                              ▼
               ┌─────────────────────────────────────┐
               │  4. GRUPO 2: SERVIDORES 1-2         │
               │  - 2 servidores: 10.238.7.12-13     │
               │  - SFTP individual com verificação  │
               │  - Contador: total++, success/fail++│
               └──────────────┬──────────────────────┘
                              │
                              ▼
               ┌─────────────────────────────────────┐
               │  5. GRUPO 3: SERVIDORES 20-23       │
               │  - 4 servidores: 10.238.6.35-38     │
               │  - SFTP individual com verificação  │
               │  - Contador: total++, success/fail++│
               └──────────────┬──────────────────────┘
                              │
                              ▼
               ┌─────────────────────────────────────┐
               │  6. SERVIDORES 24-27 VIA SSH        │
               │  - SSH remoto: 10.238.7.12          │
               │  - Script: sftp_srf_new_servers.sh  │
               │  - Verifica ERRORLEVEL              │
               │  - Não conta no total SFTP          │
               └──────────────┬──────────────────────┘
                              │
                              ▼
               ┌─────────────────────────────────────┐
               │  7. LIMPEZA                         │
               │  - DEL arquivo SRF local            │
               │  - Verifica ERRORLEVEL              │
               └──────────────┬──────────────────────┘
                              │
                              ▼
               ┌─────────────────────────────────────┐
               │  8. RESUMO FINAL                    │
               │  - Exibe estatísticas               │
               │  - Total: !totalServers!            │
               │  - Sucesso: !successCount!          │
               │  - Falha: !failCount!               │
               │  - Nota sobre servidores remotos    │
               └──────────────┬──────────────────────┘
                              │
                      ┌───────┴────────┐
                      │                │
                      ▼                ▼
               ┌────────────┐   ┌─────────────┐
               │ failCount  │   │ failCount   │
               │ == 0       │   │ > 0         │
               │            │   │             │
               │ Exit /B 0  │   │ Exit /B 1   │
               │ (Sucesso)  │   │ (Com falhas)│
               └────────────┘   └─────────────┘
```

---

## 📊 Comparação de Output

### Script Original (23 linhas, 0 mensagens echo)
```
[nenhuma mensagem no console]
[impossível rastrear progresso]
[impossível identificar falhas]
```

### Script Melhorado (280+ linhas, 50+ mensagens echo)
```
=== INICIO DO SCRIPT sftp_srf_new_az.bat ===
Script de distribuição de arquivo SRF para servidores Siebel PROD
Propósito: Copiar arquivo SRF para múltiplos servidores via SFTP
Inicialização concluída
Contadores inicializados: Total=0, Sucesso=0, Falha=0
Verificando existência do arquivo SRF em C:\Siebel_Devops\PROD\srf\...
Arquivo siebel_sia_new.srf já existe em PROD, prosseguindo com distribuição
Verificação e preparação do arquivo SRF concluída
Iniciando distribuição para Grupo 1: Servidores 3 a 8...
Transferindo para Servidor 3 (10.238.5.32)...
  - Servidor 3: Transferência concluída com sucesso
Transferindo para Servidor 4 (10.238.5.33)...
  - Servidor 4: Transferência concluída com sucesso
[... continua para todos os servidores ...]
Distribuição para Grupo 1 concluída (6 servidores processados)
Iniciando distribuição para Grupo 2: Servidores 1 e 2...
[... continua ...]
====================================================
RESUMO DA DISTRIBUIÇÃO DE SRF
====================================================
Total de servidores SFTP processados: 12
Transferências bem-sucedidas: 12
Transferências com falha: 0

Nota: Servidores 24-27 foram processados via script remoto
      e não estão incluídos nas estatísticas acima.
====================================================

Todas as transferências SFTP foram concluídas com sucesso!
=== FIM DO SCRIPT sftp_srf_new_az.bat ===
```

---

## 📈 Métricas de Melhoria

| Métrica | Original | Melhorado | Ganho |
|---------|----------|-----------|-------|
| **Linhas de código** | 23 | 280+ | **+1117%** |
| **Mensagens echo** | 0 | 50+ | **∞** |
| **Verificações ERRORLEVEL** | 0 | 14 | **∞** |
| **Seções identificadas** | 0 | 8 | **∞** |
| **Contadores** | 0 | 3 | **Novo** |
| **Identificação de servidores** | Não | Sim | **Novo** |
| **Resumo estatístico** | Não | Sim | **Novo** |
| **Exit code diferenciado** | Não | Sim | **Novo** |

---

## ⚙️ Configurações e Topologia de Servidores

### Arquivo SRF:
- **Fonte:** `C:\Siebel_Devops\PP\srf\siebel_sia_new.srf`
- **Staging:** `C:\Siebel_Devops\PROD\srf\siebel_sia_new.srf`
- **Arquivo de comandos SFTP:** `C:\Siebel_Devops\scripts\sftp_put_prod_new.txt`

### Topologia de Servidores (12 servidores SFTP + 4 remotos):

#### Grupo 1: Servidores 3-8 (6 servidores)
- **Servidor 3:** `10.238.5.32`
- **Servidor 4:** `10.238.5.33`
- **Servidor 5:** `10.238.5.34`
- **Servidor 6:** `10.238.5.35`
- **Servidor 7:** `10.238.5.36`
- **Servidor 8:** `10.238.5.37`

#### Grupo 2: Servidores 1-2 (2 servidores)
- **Servidor 1:** `10.238.7.12`
- **Servidor 2:** `10.238.7.13`

#### Grupo 3: Servidores 20-23 (4 servidores)
- **Servidor 20:** `10.238.6.35`
- **Servidor 21:** `10.238.6.36`
- **Servidor 22:** `10.238.6.37`
- **Servidor 23:** `10.238.6.38`

#### Grupo 4: Servidores 24-27 (via SSH remoto)
- **Host SSH:** `10.238.7.12` (pcpweb)
- **Script remoto:** `/home/pcpweb/sftp_srf_new_servers.sh`
- **Servidores alvos:** 24, 25, 26, 27
- **Data de adição:** 20240620 (por SDANGELIS)
- **Nota:** Processados via script remoto, não via SFTP direto

---

## 🎯 Casos de Uso

### Cenário 1: Todas as Transferências Bem-Sucedidas
```
Input: Arquivo SRF existe em PROD
Output:
  ✓ 12 servidores SFTP processados
  ✓ 12 transferências bem-sucedidas
  ✓ 0 falhas
  ✓ Servidores 24-27 processados remotamente
  ✓ Arquivo SRF local removido
  Exit: 0
```

### Cenário 2: Arquivo SRF Não Existe em PROD
```
Input: Arquivo SRF não existe em PROD, existe em PP
Output:
  ✓ Arquivo copiado de PP para PROD
  ✓ 12 servidores SFTP processados
  ✓ 12 transferências bem-sucedidas
  ✓ 0 falhas
  Exit: 0
```

### Cenário 3: Algumas Transferências Falharam
```
Input: Arquivo SRF existe, servidor 5 está offline
Output:
  ✓ 12 servidores SFTP processados
  ✓ 11 transferências bem-sucedidas
  ✗ 1 falha (Servidor 5: 10.238.5.34)
  ⚠ ATENÇÃO: Algumas transferências falharam
  Exit: 1
```

### Cenário 4: Arquivo SRF Não Existe em PP
```
Input: Arquivo SRF não existe nem em PROD nem em PP
Output:
  ✗ ERRO: Falha ao copiar arquivo SRF
  ℹ Verifique se o arquivo existe em C:\Siebel_Devops\PP\srf\
  Exit: 1 (script termina imediatamente)
```

### Cenário 5: Falha no Script Remoto (Servidores 24-27)
```
Input: Arquivo SRF OK, SFTP OK, SSH falha
Output:
  ✓ 12 servidores SFTP processados com sucesso
  ✗ AVISO: Distribuição remota retornou código de erro
  ℹ Verifique log do script remoto no servidor 10.238.7.12
  ✓ 12 sucessos, 0 falhas (SFTP apenas)
  Exit: 0 (falha SSH não afeta exit code)
```

---

## 🎓 Padrões Aplicados (Checklist)

- [x] Adicionar delimitadores de início/fim (`===`)
- [x] Echo descritivo antes de cada operação importante
- [x] Echo de confirmação após operações críticas
- [x] Usar aspas em todos os caminhos de arquivo
- [x] Adicionar verificação de `%ERRORLEVEL%` em operações críticas (14 verificações)
- [x] Implementar contadores (totalServers, successCount, failCount)
- [x] Seções claramente delimitadas com comentários REM (8 seções)
- [x] Usar `setlocal enabledelayedexpansion` para contadores
- [x] Identificação clara de cada servidor (número + IP)
- [x] Agrupamento lógico de servidores documentado
- [x] Resumo estatístico final
- [x] Exit code diferenciado (0 = sucesso, 1 = falha)
- [x] Uso de comando Windows correto (DEL em vez de RM)
- [x] Redirecionamento `> nul 2>&1` para suprimir output
- [x] Documentação inline de operações críticas
- [x] Mensagens de troubleshooting em caso de erro

---

## 🚀 Benefícios das Melhorias

### Para Debugging:
- ✅ Identifica exatamente qual servidor falhou na transferência
- ✅ Contadores permitem validar quantidade de servidores processados
- ✅ ERRORLEVEL em todas as operações detecta falhas imediatamente
- ✅ Mensagens descritivas facilitam troubleshooting remoto

### Para Monitoramento em Pipeline:
- ✅ Logs estruturados mostram progresso em tempo real
- ✅ Resumo final com estatísticas facilita validação
- ✅ Exit code diferenciado permite automação de alertas
- ✅ Identificação de servidores facilita correlação com logs

### Para Operações:
- ✅ Rastreamento completo de qual servidor recebeu o arquivo
- ✅ Estatísticas de sucesso/falha para SLA
- ✅ Documentação de topologia inline (não precisa de doc externa)
- ✅ Instruções de troubleshooting embutidas

### Para Auditoria:
- ✅ Log completo de todas as operações executadas
- ✅ Timestamp de execução implícito nos logs do pipeline
- ✅ Rastreamento de arquivo fonte (PP vs PROD)
- ✅ Documentação de data de adição de novos servidores

---

## 🔒 Considerações de Segurança

### ✅ Pontos Positivos:
- Não há credenciais hardcoded no script
- SFTP usa arquivo de comandos externo
- SSH usa autenticação configurada no sistema

### ⚠️ Pontos de Atenção:
- Verifique o conteúdo de `sftp_put_prod_new.txt` para credenciais
- Considere usar autenticação por chave SSH
- Valide permissões de acesso aos servidores 24-27 via script remoto

### 📋 Recomendações:
1. Implementar autenticação por chave SSH para SFTP
2. Rotacionar credenciais periodicamente
3. Auditar acesso ao arquivo de comandos SFTP
4. Validar permissões do script remoto `sftp_srf_new_servers.sh`

---

## 🔧 Melhorias Futuras Sugeridas

### 1. Paralelização de Transferências
```batch
REM Usar start /B para executar SFTPs em paralelo
start /B sftp -b ... servidor1
start /B sftp -b ... servidor2
REM Aguardar conclusão de todos
```

### 2. Retry Automático em Caso de Falha
```batch
set /a retries=0
:retry
sftp -b ... servidor
if !ERRORLEVEL! NEQ 0 (
    if !retries! LSS 3 (
        set /a retries+=1
        goto :retry
    )
)
```

### 3. Validação de Checksum
```batch
REM Calcular hash antes e depois da transferência
certutil -hashfile arquivo.srf MD5
```

### 4. Timeout Configurável
```batch
REM Adicionar timeout para SFTP
timeout /t 300
```

---

## 📚 Referências

- **Script original:** `tech_products/win-vivocorp/siebel_devops/paliativo/prod/sftp_srf_new.bat`
- **Script melhorado:** `tech_products/win-vivocorp/siebel_devops/paliativo/prod/sftp_srf_new_az.bat`
- **Guia de padrões:** `../../siebel_devops/paliativo/prod/GIT_PROD_IMPROVEMENT_PROMPT.md`
- **Exemplos anteriores:**
  - `git_prod_az.bat` (versionamento Git)
  - `import_improved.bat` (importação Siebel)
  - `adm_get_new_az.bat` (processamento ADM XMLs)

---

**Data de Análise:** 2025-10-30  
**Framework:** CodePlay Pipelines - Vivo  
**Tech Product:** win-vivocorp / siebel_devops  
**Autor das melhorias dos servidores 24-27:** SDANGELIS (20240620)
