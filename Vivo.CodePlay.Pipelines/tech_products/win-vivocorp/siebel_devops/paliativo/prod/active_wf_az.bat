@echo off
setlocal enabledelayedexpansion

echo ==================================================
echo === INICIO DO SCRIPT active_wf_az.bat ===
echo ==================================================

echo Script: active_wf_az.bat
echo Script: active_wf_az.bat
echo Propósito: Ativar workflows Siebel
echo Data/Hora: %date% %time%
echo.
echo Iniciando processo de ativação de workflows...
echo.

set successCount=0
set failCount=0
:: ---------------------------
echo Ativando workflows Siebel...
echo.

echo Conectando em pcpweb@10.238.7.12...
echo Executando: /home/pcpweb/active_wf.sh
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.7.12 /home/pcpweb/active_wf.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Script active_wf.sh executado com sucesso
    echo Workflows ativados no servidor
    set /A successCount+=1
) else (
    echo ERRO: Falha ao executar active_wf.sh - ERRORLEVEL: !exitCode!
    echo ERRO: Workflows podem nao estar ativados
    set /A failCount+=1
)
echo.

echo ==================================================
echo RESUMO DA ATIVACAO DE WORKFLOWS
echo ========================================
echo Total de operacoes: 1
echo Operacoes bem-sucedidas: !successCount!
echo Operacoes com falha: !failCount!
echo ==================================================
echo.

if !failCount! GTR 0 (
    echo AVISO: Processo concluído com falhas
    echo AVISO: Workflows podem não estar ativos
    echo AVISO: Verifique manualmente o status dos workflows
    echo AVISO: Consulte logs em /home/pcpweb/ no servidor
    echo.
    echo Script finalizado com código de erro
    echo ==================================================
    echo === FIM DO SCRIPT active_wf_az.bat ===
    echo ==================================================
    exit /B 1
) else (
    echo SUCESSO: Script active_wf.sh executado com sucesso
    echo Workflows Siebel foram ativados
    echo Processos de workflow devem estar operacionais
    echo Recomendação: Validar workflows no Siebel Tools
    echo.
    echo Script finalizado com sucesso
    echo ==================================================
    echo === FIM DO SCRIPT active_wf_az.bat ===
    echo ==================================================
    exit /B 0
)
