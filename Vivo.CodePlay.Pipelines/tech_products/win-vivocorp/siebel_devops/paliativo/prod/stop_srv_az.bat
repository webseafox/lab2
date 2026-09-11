@echo off
setlocal enabledelayedexpansion

echo ==================================================
echo === INICIO DO SCRIPT stop_srv_az.bat ===
echo ==================================================

echo Script: stop_srv_az.bat
echo Propósito: Parar servidores Siebel em produção
echo Data/Hora: %date% %time%
echo.
echo Iniciando processo de parada dos servidores Siebel...
echo.

set totalServers=18
set successCount=0
set failCount=0

echo ==================================================
echo GRUPO 1: Parando servidores 20 a 23
echo ==================================================
echo.

echo Conectando em pcpweb@10.238.6.35...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.35 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log 2>&1 &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 20: Comando de parada enviado com sucesso para 10.238.6.35
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 20 ^(10.238.6.35^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.6.36...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.36 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log 2>&1 &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 21: Comando de parada enviado com sucesso para 10.238.6.36
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 21 ^(10.238.6.36^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.6.37...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.37 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log 2>&1 &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 22: Comando de parada enviado com sucesso para 10.238.6.37
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 22 ^(10.238.6.37^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.6.38...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.38 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log 2>&1 &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 23: Comando de parada enviado com sucesso para 10.238.6.38
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 23 ^(10.238.6.38^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo ==================================================
echo GRUPO 2: Parando servidores 1 e 2
echo ==================================================
echo.

echo Conectando em pcpweb@10.238.7.12 (siebelsrv1)...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.7.12 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebelsrv1/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log 2>&1 &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 1: Comando de parada enviado com sucesso para 10.238.7.12 ^(siebelsrv1^)
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 1 ^(10.238.7.12/siebelsrv1^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.7.13 (siebelsrv2)...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.7.13 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebelsrv2/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log 2>&1 &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 2: Comando de parada enviado com sucesso para 10.238.7.13 ^(siebelsrv2^)
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 2 ^(10.238.7.13/siebelsrv2^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo ==================================================
echo GRUPO 3: Parando servidores 3 a 8
echo ==================================================
echo.

echo Conectando em pcpweb@10.238.5.32...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.5.32 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log 2>&1 &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 3: Comando de parada enviado com sucesso para 10.238.5.32
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 3 ^(10.238.5.32^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.5.33...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.5.33 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log 2>&1 &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 4: Comando de parada enviado com sucesso para 10.238.5.33
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 4 ^(10.238.5.33^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.5.34...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.5.34 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log 2>&1 &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 5: Comando de parada enviado com sucesso para 10.238.5.34
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 5 ^(10.238.5.34^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.5.35...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.5.35 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log 2>&1 &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 6: Comando de parada enviado com sucesso para 10.238.5.35
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 6 ^(10.238.5.35^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.5.36...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.5.36 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log 2>&1 &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 7: Comando de parada enviado com sucesso para 10.238.5.36
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 7 ^(10.238.5.36^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.5.37...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.5.37 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log 2>&1 &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 8: Comando de parada enviado com sucesso para 10.238.5.37
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 8 ^(10.238.5.37^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo ==================================================
echo GRUPO 4: Parando servidores 24 a 27
echo ==================================================
echo.

echo Executando script remoto em pcpweb@10.238.7.12...
echo Script: /home/pcpweb/stop_new_servers.sh
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.7.12 /home/pcpweb/stop_new_servers.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Script remoto executado com sucesso
    echo Servidores 24, 25, 26 e 27 receberam comando de parada
    set /A successCount+=4
) else (
    echo ERRO: Falha ao executar script remoto para servidores 24-27 - ERRORLEVEL: !exitCode!
    set /A failCount+=4
)
echo.

echo ==================================================
echo GRUPO 5: Parando servidores SVR24, SRV10 e SRV09
echo ==================================================
echo.

echo Conectando em pcpweb@10.238.6.67 (SVR24)...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.67 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log 2>&1 &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo SVR24: Comando de parada enviado com sucesso para 10.238.6.67
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para SVR24 (10.238.6.67) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.6.66 (SRV10)...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.66 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log 2>&1 &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo SRV10: Comando de parada enviado com sucesso para 10.238.6.66
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para SRV10 (10.238.6.66) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo ==================================================
echo RESUMO DA PARADA DOS SERVIDORES
echo ==================================================
echo Total de servidores: %totalServers%
echo Comandos enviados com sucesso: !successCount!
echo Comandos com falha: !failCount!
echo ==================================================
echo.

if !failCount! GTR 0 (
    echo AVISO: Processo concluído com falhas
    echo AVISO: Verifique os logs dos servidores que falharam
    echo.
    echo Script finalizado com código de erro
    echo ==================================================
    echo === FIM DO SCRIPT stop_srv_az.bat ===
    echo ==================================================
    exit /B 1
) else (
    echo SUCESSO: Todos os comandos de parada foram enviados com sucesso
    echo Os servidores estão em processo de shutdown
    echo Aguarde alguns minutos e verifique o status dos servidores
    echo.
    echo Script finalizado com sucesso
    echo ==================================================
    echo === FIM DO SCRIPT stop_srv_az.bat ===
    echo ==================================================
    exit /B 0
)
