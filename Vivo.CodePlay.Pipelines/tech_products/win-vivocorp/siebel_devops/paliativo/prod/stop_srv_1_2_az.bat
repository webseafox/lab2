@echo off
setlocal enabledelayedexpansion

echo ==================================================
echo === INICIO DO SCRIPT stop_srv_1_2_az.bat
echo ===
echo ==================================================

:: ---------------------------
:: Inicialização
:: ---------------------------
echo Script: Parar servidores Siebel 1 e 2 com delay
echo Propósito: %date% %time%
echo Data/Hora:

echo Iniciando processo de stop dos servidores Siebel...
echo Este processo inclui delays de 260 segundos entre o stop dos servidores 1 e 2
echo.

:: ---------------------------
:: Contadores de controle
:: ---------------------------
set totalServers=2
set successCount=0
set failCount=0

:: ---------------------------
:: SERVIDOR 1: 10.238.7.12 (siebelsrv1)
:: ---------------------------
echo ========================================
echo [SERVIDOR 1] Iniciando servidor 1
echo Data/Hora:

echo Conectando em pcpweb@10.238.7.12 (siebelsrv1)...
echo Executando stop_srv.sh em background...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.7.12 "sudo -u supweb /opt/web/siebel/siebel811/siebelsrv1/siebsrvr/scripts/stop_srv.sh &>/dev/null &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Comando de stop enviado com sucesso para 10.238.7.12 ^(siebelsrv1^)
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 1 ^(10.238.7.12/siebelsrv1^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
    goto :servidor2
)
echo.

echo Aguardando 260 segundos para estabilizacao do servidor...
echo Inicio do delay: %time%
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.7.12 "sleep 260" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Delay de 260 segundos concluido com sucesso
    echo Fim do delay: %time%
) else (
    echo AVISO: Erro durante delay, mas continuando - ERRORLEVEL: !exitCode!
)
echo.

:: ---------------------------
:: SERVIDOR 2: 10.238.7.13 (siebelsrv2)
:: ---------------------------
:servidor2
echo ========================================
echo [SERVIDOR 2] Iniciando servidor 2
echo Data/Hora:

echo Conectando em pcpweb@10.238.7.13 (siebelsrv2)...
echo Executando stop_srv.sh em background...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.7.13 "sudo -u supweb /opt/web/siebel/siebel811/siebelsrv2/siebsrvr/scripts/stop_srv.sh &>/dev/null &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Comando de stop enviado com sucesso para 10.238.7.13 ^(siebelsrv2^)
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 2 ^(10.238.7.13/siebelsrv2^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
    goto :resumo
)
echo.

echo Aguardando 260 segundos para estabilizacao do servidor...
echo Inicio do delay: %time%
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.7.13 "sleep 260" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Delay de 260 segundos concluido com sucesso
    echo Fim do delay: %time%
) else (
    echo AVISO: Erro durante delay, mas continuando - ERRORLEVEL: !exitCode!
)
echo.

:resumo
echo ========================================
echo RESUMO DO stop DOS SERVIDORES
echo ========================================
echo Total de servidores: %totalServers%
echo Comandos enviados com sucesso: !successCount!
echo Comandos com falha: !failCount!
echo Data/Hora:

if !successCount! GEQ 2 (
    echo Tempo total de delays: 520 segundos (~8.7 minutos)
) else if !successCount! EQU 1 (
    echo Tempo total de delays: 260 segundos (~4.3 minutos)
) else (
    echo Nenhum delay executado devido a falhas
)
echo.

if !failCount! GTR 0 (
    echo AVISO: Processo concluido com falhas
    echo AVISO: Verifique os logs dos servidores que falharam
    echo AVISO: Servidores que falharam NAO foram iniciados
    echo.
    echo Script finalizado com codigo de erro
    exit /B 1
) else (
    echo SUCESSO: Todos os comandos de stop foram enviados com sucesso
    echo Servidores 1 e 2 estao em processo de inicializacao
    echo Aguarde alguns minutos adicionais para completa inicializacao
    echo Recomendacao: Verificar status dos servidores apos 5-10 minutos
    echo.
    echo Script finalizado com sucesso
    exit /B 0
)
