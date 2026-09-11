# Análise de Melhorias: stop_srv.bat → stop_srv_az.bat

## 📋 Informações do Script

- **Script Original:** `stop_srv.bat`
- **Script Melhorado:** `stop_srv_az.bat`
- **Propósito:** Parar servidores Siebel em ambiente de produção via SSH
- **Ambiente:** Produção Siebel CRM v8.1
- **Data da Análise:** 2025-10-30

## 📊 Métricas de Melhoria

| Métrica | Antes | Depois | Variação |
|---------|-------|--------|----------|
| **Linhas Totais** | 30 | 258 | +760% |
| **Comandos echo** | 0 | 70+ | ∞ |
| **Verificações ERRORLEVEL** | 0 | 13 | +13 |
| **Contadores** | 0 | 3 | +3 |
| **Grupos lógicos** | 4 (implícito) | 4 (explícito) | - |
| **Tratamento de erro** | ❌ Inexistente | ✅ Completo | - |

## 🎯 Melhorias Implementadas

### 1. ✅ Verbosidade e Rastreabilidade

**ANTES:**
```batch
rem Stop 20 a 23
ssh pcpweb@10.238.6.35 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log &"
ssh pcpweb@10.238.6.36 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log &"
```

**DEPOIS:**
```batch
echo ========================================
echo [GRUPO 1] Parando servidores 20 a 23
echo ========================================
echo.

echo [Server 20] Conectando em pcpweb@10.238.6.35...
ssh pcpweb@10.238.6.35 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log 2>&1 &"
if !ERRORLEVEL! EQU 0 (
    echo [Server 20] Comando de parada enviado com sucesso para 10.238.6.35
    set /A successCount+=1
) else (
    echo [ERRO] Falha ao enviar comando para servidor 20 ^(10.238.6.35^) - ERRORLEVEL: !ERRORLEVEL!
    set /A failCount+=1
)
echo.

echo [Server 21] Conectando em pcpweb@10.238.6.36...
ssh pcpweb@10.238.6.36 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log 2>&1 &"
if !ERRORLEVEL! EQU 0 (
    echo [Server 21] Comando de parada enviado com sucesso para 10.238.6.36
    set /A successCount+=1
) else (
    echo [ERRO] Falha ao enviar comando para servidor 21 ^(10.238.6.36^) - ERRORLEVEL: !ERRORLEVEL!
    set /A failCount+=1
)
```

**Impacto:**
- Logs rastreáveis para cada servidor individualmente
- Identificação clara de qual servidor falhou
- Feedback em tempo real durante execução

### 2. ✅ Cabeçalho Estruturado

**ANTES:**
```batch
rem Stop 20 a 23
```

**DEPOIS:**
```batch
@echo off
setlocal enabledelayedexpansion

echo ========================================
echo SCRIPT: stop_srv_az.bat
echo PROPOSITO: Parar servidores Siebel em producao
echo DATA/HORA: %date% %time%
echo ========================================
echo.

echo [INFO] Iniciando processo de parada dos servidores Siebel...
```

**Impacto:**
- Identificação clara do script e timestamp
- Contexto para auditoria e troubleshooting

### 3. ✅ Tratamento de Erros com ERRORLEVEL

**ANTES:**
```batch
ssh pcpweb@10.238.6.35 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log &"
rem Sem verificação de sucesso/falha
```

**DEPOIS:**
```batch
ssh pcpweb@10.238.6.35 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log 2>&1 &"
if !ERRORLEVEL! EQU 0 (
    echo [Server 20] Comando de parada enviado com sucesso para 10.238.6.35
    set /A successCount+=1
) else (
    echo [ERRO] Falha ao enviar comando para servidor 20 ^(10.238.6.35^) - ERRORLEVEL: !ERRORLEVEL!
    set /A failCount+=1
)
```

**Impacto:**
- Detecção imediata de falhas de conexão SSH
- Contabilização de sucessos e falhas
- Pipeline pode tomar decisões baseadas no exit code

### 4. ✅ Contadores Estatísticos com Delayed Expansion

**ANTES:**
```batch
rem Sem contadores
```

**DEPOIS:**
```batch
setlocal enabledelayedexpansion

set totalServers=16
set successCount=0
set failCount=0

rem ... após cada operação ...
set /A successCount+=1
rem ou
set /A failCount+=1

rem ... no final ...
echo ========================================
echo RESUMO DA PARADA DOS SERVIDORES
echo ========================================
echo Total de servidores: %totalServers%
echo Comandos enviados com sucesso: !successCount!
echo Comandos com falha: !failCount!
```

**Impacto:**
- Visão estatística do processo de parada
- Facilita validação de que todos os servidores foram alcançados
- Base para alertas e monitoramento

### 5. ✅ Redirecionamento de Stderr (2>&1)

**ANTES:**
```batch
ssh pcpweb@10.238.6.35 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log &"
```

**DEPOIS:**
```batch
ssh pcpweb@10.238.6.35 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log 2>&1 &"
```

**Impacto:**
- Captura tanto stdout quanto stderr no log remoto
- Erros não se perdem, facilitando troubleshooting

### 6. ✅ Organização em Grupos Lógicos

**ANTES:**
```batch
rem Stop 20 a 23
ssh pcpweb@10.238.6.35 ...
ssh pcpweb@10.238.6.36 ...
ssh pcpweb@10.238.6.37 ...
ssh pcpweb@10.238.6.38 ...

rem Stop 1 e 2
ssh pcpweb@10.238.7.12 ...
ssh pcpweb@10.238.7.13 ...

rem Start 3 a 8 [comentário incorreto!]
ssh pcpweb@10.238.5.32 ...
```

**DEPOIS:**
```batch
rem ========================================
rem GRUPO 1: Servidores 20 a 23 (10.238.6.35-38)
rem ========================================
echo ========================================
echo [GRUPO 1] Parando servidores 20 a 23
echo ========================================
echo.

rem ... comandos do grupo 1 ...

rem ========================================
rem GRUPO 2: Servidores 1 e 2 (10.238.7.12-13)
rem ========================================
echo ========================================
echo [GRUPO 2] Parando servidores 1 e 2
echo ========================================
```

**Correções:**
- Corrigido comentário "Start 3 a 8" → "GRUPO 3: Servidores 3 a 8"
- Documentado range de IPs para cada grupo
- Separação visual clara entre grupos

### 7. ✅ Exit Code Baseado em Resultados

**ANTES:**
```batch
exit 0
rem Sempre retorna sucesso, mesmo com falhas
```

**DEPOIS:**
```batch
if !failCount! GTR 0 (
    echo [AVISO] Processo concluido com falhas
    echo [AVISO] Verifique os logs dos servidores que falharam
    echo.
    echo [INFO] Script finalizado com codigo de erro
    exit /B 1
) else (
    echo [SUCESSO] Todos os comandos de parada foram enviados com sucesso
    echo [INFO] Os servidores estao em processo de shutdown
    echo [INFO] Aguarde alguns minutos e verifique o status dos servidores
    echo.
    echo [INFO] Script finalizado com sucesso
    exit /B 0
)
```

**Impacto:**
- Pipeline pode detectar falhas automaticamente
- Exit code 1 sinaliza problemas
- Exit code 0 confirma sucesso total

### 8. ✅ Identificação Individual de Servidores

**ANTES:**
```batch
rem Servidores numerados apenas em comentários
ssh pcpweb@10.238.6.35 ...
ssh pcpweb@10.238.6.36 ...
```

**DEPOIS:**
```batch
echo [Server 20] Conectando em pcpweb@10.238.6.35...
ssh pcpweb@10.238.6.35 ...
echo [Server 20] Comando de parada enviado com sucesso para 10.238.6.35

echo [Server 21] Conectando em pcpweb@10.238.6.36...
ssh pcpweb@10.238.6.36 ...
echo [Server 21] Comando de parada enviado com sucesso para 10.238.6.36
```

**Impacto:**
- Rastreamento individual por número de servidor
- Correlação fácil entre logs e topologia
- Facilita comunicação com time de infraestrutura

## 🏗️ Topologia dos Servidores

### Grupo 1: Servidores 20-23
- **Range IP:** 10.238.6.35-38
- **User:** pcpweb
- **Path:** `/opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh`
- **Servidores:** 4

### Grupo 2: Servidores 1-2
- **Range IP:** 10.238.7.12-13
- **User:** pcpweb
- **Path Srv1:** `/opt/web/siebel/siebel811/siebelsrv1/siebsrvr/scripts/stop_srv.sh`
- **Path Srv2:** `/opt/web/siebel/siebel811/siebelsrv2/siebsrvr/scripts/stop_srv.sh`
- **Servidores:** 2
- **Nota:** Instâncias múltiplas no mesmo host físico

### Grupo 3: Servidores 3-8
- **Range IP:** 10.238.5.32-37
- **User:** pcpweb
- **Path:** `/opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh`
- **Servidores:** 6

### Grupo 4: Servidores 24-27 (Script Remoto)
- **Host Controle:** 10.238.7.12
- **User:** pcpweb
- **Script Remoto:** `/home/pcpweb/stop_new_servers.sh`
- **Servidores:** 4
- **IPs Gerenciados:** 10.238.6.65-68 (comentados no original)
- **Nota:** Adicionados em 20/06/2024 por SDANGELIS

**Total:** 16 servidores Siebel em produção

## 📈 Fluxo de Execução

```
┌─────────────────────────────────────────────────┐
│  INÍCIO: stop_srv_az.bat                        │
│  - Exibe cabeçalho com timestamp                │
│  - Inicializa contadores (16, 0, 0)             │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│  GRUPO 1: Servidores 20-23 (10.238.6.35-38)    │
│  ┌──────────────────────────────────────────┐   │
│  │  Para cada servidor (20, 21, 22, 23):   │   │
│  │  1. Echo "Conectando..."                 │   │
│  │  2. SSH + nohup stop_srv.sh              │   │
│  │  3. Verifica ERRORLEVEL                  │   │
│  │  4. Se OK: successCount++                │   │
│  │  5. Se ERRO: failCount++, log erro       │   │
│  │  6. Echo separador                       │   │
│  └──────────────────────────────────────────┘   │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│  GRUPO 2: Servidores 1-2 (10.238.7.12-13)      │
│  ┌──────────────────────────────────────────┐   │
│  │  Para cada servidor (1, 2):              │   │
│  │  - Srv1: siebelsrv1 em 10.238.7.12      │   │
│  │  - Srv2: siebelsrv2 em 10.238.7.13      │   │
│  │  (mesmo fluxo de verificação)            │   │
│  └──────────────────────────────────────────┘   │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│  GRUPO 3: Servidores 3-8 (10.238.5.32-37)      │
│  ┌──────────────────────────────────────────┐   │
│  │  Para cada servidor (3-8):               │   │
│  │  (mesmo fluxo de verificação)            │   │
│  └──────────────────────────────────────────┘   │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│  GRUPO 4: Servidores 24-27 (Script Remoto)     │
│  ┌──────────────────────────────────────────┐   │
│  │  1. Echo "Executando script remoto"     │   │
│  │  2. SSH stop_new_servers.sh em .7.12    │   │
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
│ exit /B 1    │      │ exit /B 0    │
└──────────────┘      └──────────────┘
```

## 🎓 Detalhamento por Seção

### Seção 1: Inicialização
- **Linhas:** 1-15
- **Input:** Nenhum (sem parâmetros)
- **Output:** Cabeçalho com timestamp
- **Verificações:** Nenhuma

### Seção 2: GRUPO 1 (Servers 20-23)
- **Linhas:** 17-83
- **Input:** Conexão SSH disponível
- **Output:** 4 comandos SSH, logs individuais
- **Verificações:** 4 × ERRORLEVEL
- **Contadores:** successCount e failCount atualizados

### Seção 3: GRUPO 2 (Servers 1-2)
- **Linhas:** 85-117
- **Input:** Conexão SSH disponível
- **Output:** 2 comandos SSH, logs individuais
- **Verificações:** 2 × ERRORLEVEL
- **Contadores:** successCount e failCount atualizados
- **Especial:** Paths diferenciados (siebelsrv1/siebelsrv2)

### Seção 4: GRUPO 3 (Servers 3-8)
- **Linhas:** 119-203
- **Input:** Conexão SSH disponível
- **Output:** 6 comandos SSH, logs individuais
- **Verificações:** 6 × ERRORLEVEL
- **Contadores:** successCount e failCount atualizados

### Seção 5: GRUPO 4 (Servers 24-27)
- **Linhas:** 205-223
- **Input:** Script remoto `/home/pcpweb/stop_new_servers.sh`
- **Output:** 1 comando SSH (controla 4 servidores)
- **Verificações:** 1 × ERRORLEVEL
- **Contadores:** +4 ou -4 de uma vez

### Seção 6: Resumo e Exit
- **Linhas:** 225-258
- **Input:** Valores de contadores
- **Output:** Resumo estatístico, mensagens finais
- **Verificações:** failCount > 0
- **Exit Code:** 0 (sucesso) ou 1 (falha)

## 🔍 Cenários de Uso

### Cenário 1: Shutdown Completo para Manutenção
**Entrada:**
```cmd
stop_srv_az.bat
```

**Saída Esperada:**
```
========================================
SCRIPT: stop_srv_az.bat
PROPOSITO: Parar servidores Siebel em producao
DATA/HORA: 30/10/2025 14:35:22
========================================

[INFO] Iniciando processo de parada dos servidores Siebel...

========================================
[GRUPO 1] Parando servidores 20 a 23
========================================

[Server 20] Conectando em pcpweb@10.238.6.35...
[Server 20] Comando de parada enviado com sucesso para 10.238.6.35

[Server 21] Conectando em pcpweb@10.238.6.35...
[Server 21] Comando de parada enviado com sucesso para 10.238.6.36

... (continua para todos os 16 servidores) ...

========================================
RESUMO DA PARADA DOS SERVIDORES
========================================
Total de servidores: 16
Comandos enviados com sucesso: 16
Comandos com falha: 0
========================================

[SUCESSO] Todos os comandos de parada foram enviados com sucesso
[INFO] Os servidores estao em processo de shutdown
[INFO] Aguarde alguns minutos e verifique o status dos servidores

[INFO] Script finalizado com sucesso
```

**Exit Code:** 0

### Cenário 2: Falha de Conexão em 1 Servidor
**Entrada:**
```cmd
stop_srv_az.bat
rem Servidor 10.238.6.36 fora do ar
```

**Saída Esperada:**
```
...
[Server 21] Conectando em pcpweb@10.238.6.36...
[ERRO] Falha ao enviar comando para servidor 21 (10.238.6.36) - ERRORLEVEL: 255
...

========================================
RESUMO DA PARADA DOS SERVIDORES
========================================
Total de servidores: 16
Comandos enviados com sucesso: 15
Comandos com falha: 1
========================================

[AVISO] Processo concluido com falhas
[AVISO] Verifique os logs dos servidores que falharam

[INFO] Script finalizado com codigo de erro
```

**Exit Code:** 1

### Cenário 3: Falha Total no Grupo 4
**Entrada:**
```cmd
stop_srv_az.bat
rem Script remoto stop_new_servers.sh não encontrado
```

**Saída Esperada:**
```
...
[Servers 24-27] Executando script remoto em pcpweb@10.238.7.12...
[INFO] Script: /home/pcpweb/stop_new_servers.sh
[ERRO] Falha ao executar script remoto para servidores 24-27 - ERRORLEVEL: 127
...

========================================
RESUMO DA PARADA DOS SERVIDORES
========================================
Total de servidores: 16
Comandos enviados com sucesso: 12
Comandos com falha: 4
========================================

[AVISO] Processo concluido com falhas
[AVISO] Verifique os logs dos servidores que falharam

[INFO] Script finalizado com codigo de erro
```

**Exit Code:** 1

### Cenário 4: Integração com Pipeline Azure DevOps
**Pipeline YAML:**
```yaml
- task: BatchScript@1
  displayName: 'Stop Siebel Servers'
  inputs:
    filename: 'tech_products/win-vivocorp/siebel_devops/paliativo/prod/stop_srv_az.bat'
  continueOnError: false
  condition: succeeded()

- task: PowerShell@2
  displayName: 'Check Stop Status'
  inputs:
    targetType: 'inline'
    script: |
      if ($LASTEXITCODE -ne 0) {
        Write-Error "Falha ao parar servidores Siebel"
        exit 1
      }
      Write-Host "Servidores Siebel parados com sucesso"
```

**Resultado:** Pipeline falha automaticamente se exit code ≠ 0

## 📝 Observações Importantes

### 1. Script Remoto stop_new_servers.sh
- **Localização:** `/home/pcpweb/stop_new_servers.sh` em 10.238.7.12
- **Responsabilidade:** Controlar servidores 24-27 (10.238.6.65-68)
- **Vantagem:** Gerenciamento centralizado de novos servidores
- **Limitação:** Falha única afeta 4 servidores simultaneamente

### 2. Comandos Comentados no Original
```batch
rem ssh pcpweb@10.238.7.12 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebelsrv2/siebsrvr/scripts/stop_srv.sh > /opt/web/siebel/siebel811/siebelsrv2/siebsrvr/scripts/stop_devops.log &"
rem ssh pcpweb@10.238.7.13 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebelsrv2/siebsrvr/scripts/stop_srv.sh > /opt/web/siebel/siebel811/siebelsrv2/siebsrvr/scripts/stop_devops.log &"
```

**Análise:** Paths de log diferentes (não em `/tmp/devops/`). Mantidos comentados por decisão de design anterior.

### 3. Correções de Comentários
**Original:** `rem Start 3 a 8` (incorreto)  
**Corrigido:** `rem GRUPO 3: Servidores 3 a 8` (correto)

### 4. Nohup e Background Execution
- Comando `nohup ... &` executa em background no servidor remoto
- Script Windows retorna imediatamente após enviar comando
- Shutdown real dos servidores leva minutos
- Logs remotos em `/tmp/devops/stop_devops.log`

## 🚀 Próximos Passos

1. **Testar em Desenvolvimento:**
   - Validar conectividade SSH com todos os 16 servidores
   - Confirmar permissões sudo funcionando
   - Verificar logs em `/tmp/devops/stop_devops.log`

2. **Validar Script Remoto:**
   - Confirmar existência de `/home/pcpweb/stop_new_servers.sh`
   - Testar execução manual do script
   - Verificar IPs 10.238.6.65-68 acessíveis

3. **Integrar ao Pipeline:**
   - Adicionar task no YAML do Azure DevOps
   - Configurar notificações de falha
   - Documentar procedimento de rollback

4. **Monitoramento:**
   - Implementar verificação pós-parada (status dos servidores)
   - Criar dashboard com métricas de shutdown
   - Alertas para falhas recorrentes

## 📚 Referências

- **SCRIPT_IMPROVEMENT_PROMPT.md:** Guia mestre de melhorias
- **Script Original:** `stop_srv.bat` (30 linhas)
- **Script Melhorado:** `stop_srv_az.bat` (258 linhas)
- **Documentação Siebel:** CRM v8.1 Server Management
- **Azure DevOps:** CodePlay Pipelines Framework

---

**Autor:** Azure DevOps Copilot  
**Data:** 2025-10-30  
**Versão:** 1.0
