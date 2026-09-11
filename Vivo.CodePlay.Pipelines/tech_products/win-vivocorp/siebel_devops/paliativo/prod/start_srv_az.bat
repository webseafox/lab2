@echo off
setlocal enabledelayedexpansion

echo ==================================================
echo === INICIO DO SCRIPT start_srv_az.bat ===
echo ==================================================

echo Script: start_srv_az.bat
echo Proposito: Iniciar servidores Siebel em producao
echo Data/Hora: %date% %time%
echo.
echo Iniciando processo de start dos servidores Siebel...
echo Este processo inclui delays de 260 segundos entre grupos de servidores
echo.

set totalServers=16
set successCount=0
set failCount=0

echo ==================================================
echo GRUPO 1: Iniciando servidores 1 e 2
echo ==================================================
echo.

echo Conectando em pcpweb@10.238.7.12 (siebelsrv1)...
echo Executando start_srv.sh em background...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.7.12 "sudo -u supweb /opt/web/siebel/siebel811/siebelsrv1/siebsrvr/scripts/start_srv.sh &>/dev/null &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 1: Comando de start enviado com sucesso para 10.238.7.12 ^(siebelsrv1^)
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 1 ^(10.238.7.12/siebelsrv1^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Aguardando 260 segundos para estabilizacao do servidor 1...
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

echo Conectando em pcpweb@10.238.7.13 (siebelsrv2)...
echo Executando start_srv.sh em background...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.7.13 "sudo -u supweb /opt/web/siebel/siebel811/siebelsrv2/siebsrvr/scripts/start_srv.sh &>/dev/null &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 2: Comando de start enviado com sucesso para 10.238.7.13 ^(siebelsrv2^)
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 2 ^(10.238.7.13/siebelsrv2^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Aguardando 260 segundos para estabilizacao do servidor 2...
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

echo ==================================================
echo GRUPO 2: Iniciando servidores 3 a 8
echo ==================================================
echo.

echo Conectando em pcpweb@10.238.5.32...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.5.32 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 3: Comando de start enviado com sucesso para 10.238.5.32
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 3 ^(10.238.5.32^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.5.33...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.5.33 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 4: Comando de start enviado com sucesso para 10.238.5.33
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 4 ^(10.238.5.33^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.5.34...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.5.34 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 5: Comando de start enviado com sucesso para 10.238.5.34
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 5 ^(10.238.5.34^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.5.35...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.5.35 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 6: Comando de start enviado com sucesso para 10.238.5.35
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 6 ^(10.238.5.35^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.5.36...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.5.36 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 7: Comando de start enviado com sucesso para 10.238.5.36
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 7 ^(10.238.5.36^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.5.37...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.5.37 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 8: Comando de start enviado com sucesso para 10.238.5.37
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 8 ^(10.238.5.37^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Aguardando 260 segundos para estabilizacao do grupo 2...
echo Inicio do delay: %time%
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.5.32 "sleep 260" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Delay de 260 segundos concluido com sucesso
    echo Fim do delay: %time%
) else (
    echo AVISO: Erro durante delay, mas continuando - ERRORLEVEL: !exitCode!
)
echo.

echo ==================================================
echo GRUPO 3: Iniciando servidores 20 a 23
echo ==================================================
echo.

echo Conectando em pcpweb@10.238.6.35...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.35 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 20: Comando de start enviado com sucesso para 10.238.6.35
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 20 ^(10.238.6.35^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.6.36...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.36 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 21: Comando de start enviado com sucesso para 10.238.6.36
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 21 ^(10.238.6.36^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.6.37...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.37 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 22: Comando de start enviado com sucesso para 10.238.6.37
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 22 ^(10.238.6.37^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.6.38...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.38 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 23: Comando de start enviado com sucesso para 10.238.6.38
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 23 ^(10.238.6.38^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Aguardando 260 segundos para estabilizacao do grupo 3...
echo Inicio do delay: %time%
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.35 "sleep 260" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Delay de 260 segundos concluido com sucesso
    echo Fim do delay: %time%
) else (
    echo AVISO: Erro durante delay, mas continuando - ERRORLEVEL: !exitCode!
)
echo.

echo ==================================================
echo GRUPO 4: Iniciando servidores 24 a 27
echo ==================================================
echo.

echo Conectando em pcpweb@10.238.6.67...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.67 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 24: Comando de start enviado com sucesso para 10.238.6.67
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 24 ^(10.238.6.67^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.6.68...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.68 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 25: Comando de start enviado com sucesso para 10.238.6.68
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 25 ^(10.238.6.68^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.6.65...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.65 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 26: Comando de start enviado com sucesso para 10.238.6.65
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 26 ^(10.238.6.65^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.6.66...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.66 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 27: Comando de start enviado com sucesso para 10.238.6.66
    set /A successCount+=1
) else (
    echo ERRO: Falha ao enviar comando para servidor 27 ^(10.238.6.66^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo ==================================================
echo RESUMO DO START DOS SERVIDORES
echo ==================================================
echo Total de servidores: %totalServers%
echo Comandos enviados com sucesso: !successCount!
echo Comandos com falha: !failCount!
echo ==================================================
echo.

if !failCount! GTR 0 (
    echo AVISO: Processo concluido com falhas
    echo AVISO: Verifique os logs dos servidores que falharam
    echo AVISO: Servidores que falharam NAO foram iniciados
    echo.
    echo Script finalizado com codigo de erro
    echo ==================================================
    echo === FIM DO SCRIPT start_srv_az.bat ===
    echo ==================================================
    exit /B 1
) else (
    echo SUCESSO: Todos os comandos de start foram enviados com sucesso
    echo Os servidores estao em processo de inicializacao
    echo Aguarde alguns minutos adicionais para completa inicializacao
    echo Recomendacao: Verificar status dos servidores apos 5-10 minutos
    echo.
    echo Script finalizado com sucesso
    echo ==================================================
    echo === FIM DO SCRIPT start_srv_az.bat ===
    echo ==================================================
    exit /B 0
)
