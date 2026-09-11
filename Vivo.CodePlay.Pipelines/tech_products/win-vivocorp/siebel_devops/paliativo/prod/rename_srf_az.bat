@echo off
setlocal enabledelayedexpansion

echo ==================================================
echo === INICIO DO SCRIPT rename_srf_az.bat ===
echo ==================================================

echo Script: rename_srf_az.bat
echo Propósito: Renomear arquivos SRF nos servidores Siebel
echo Data/Hora: %date% %time%
echo.
echo Iniciando processo de rename de arquivos SRF...
echo.

set totalServers=18
set successCount=0
set failCount=0

echo ==================================================
echo GRUPO 1: Renomeando SRF nos servidores 3 a 8
echo Data/Hora:

echo Conectando em pcpweb@10.238.5.32...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.5.32 /home/pcpweb/rename_srf.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Servidor 3: Script rename_srf.sh executado com sucesso em 10.238.5.32
    set /A successCount+=1
) else (
    echo ERRO: Falha ao executar script no servidor 3 ^(10.238.5.32^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.5.33...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.5.33 /home/pcpweb/rename_srf.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Script rename_srf.sh executado com sucesso em 10.238.5.33
    set /A successCount+=1
) else (
    echo ERRO: Falha ao executar script no servidor 4 ^(10.238.5.33^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.5.34...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.5.34 /home/pcpweb/rename_srf.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Script rename_srf.sh executado com sucesso em 10.238.5.34
    set /A successCount+=1
) else (
    echo ERRO: Falha ao executar script no servidor 5 ^(10.238.5.34^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.5.35...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.5.35 /home/pcpweb/rename_srf.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Script rename_srf.sh executado com sucesso em 10.238.5.35
    set /A successCount+=1
) else (
    echo ERRO: Falha ao executar script no servidor 6 ^(10.238.5.35^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.5.36...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.5.36 /home/pcpweb/rename_srf.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Script rename_srf.sh executado com sucesso em 10.238.5.36
    set /A successCount+=1
) else (
    echo ERRO: Falha ao executar script no servidor 7 ^(10.238.5.36^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.5.37...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.5.37 /home/pcpweb/rename_srf.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Script rename_srf.sh executado com sucesso em 10.238.5.37
    set /A successCount+=1
) else (
    echo ERRO: Falha ao executar script no servidor 8 ^(10.238.5.37^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo ========================================
echo [GRUPO 2] Renomeando SRF nos servidores 1 e 2
echo Data/Hora:

echo Conectando em pcpweb@10.238.7.12...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.7.12 /home/pcpweb/rename_srf.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Script rename_srf.sh executado com sucesso em 10.238.7.12
    set /A successCount+=1
) else (
    echo ERRO: Falha ao executar script no servidor 1 ^(10.238.7.12^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.7.13...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.7.13 /home/pcpweb/rename_srf.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Script rename_srf.sh executado com sucesso em 10.238.7.13
    set /A successCount+=1
) else (
    echo ERRO: Falha ao executar script no servidor 2 ^(10.238.7.13^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo ========================================
echo [GRUPO 3] Renomeando SRF nos servidores 20 a 23
echo Data/Hora:

echo Conectando em pcpweb@10.238.6.35...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.35 /home/pcpweb/rename_srf.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Script rename_srf.sh executado com sucesso em 10.238.6.35
    set /A successCount+=1
) else (
    echo ERRO: Falha ao executar script no servidor 20 ^(10.238.6.35^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.6.36...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.36 /home/pcpweb/rename_srf.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Script rename_srf.sh executado com sucesso em 10.238.6.36
    set /A successCount+=1
) else (
    echo ERRO: Falha ao executar script no servidor 21 ^(10.238.6.36^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.6.37...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.37 /home/pcpweb/rename_srf.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Script rename_srf.sh executado com sucesso em 10.238.6.37
    set /A successCount+=1
) else (
    echo ERRO: Falha ao executar script no servidor 22 ^(10.238.6.37^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.6.38...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.38 /home/pcpweb/rename_srf.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Script rename_srf.sh executado com sucesso em 10.238.6.38
    set /A successCount+=1
) else (
    echo ERRO: Falha ao executar script no servidor 23 ^(10.238.6.38^) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo ========================================
echo [GRUPO 4] Renomeando SRF nos servidores 24 a 27
echo Data/Hora:

echo Executando script remoto em pcpweb@10.238.7.12...
echo Script: /home/pcpweb/rename_srf_new_servers.sh
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.7.12 /home/pcpweb/rename_srf_new_servers.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Script remoto executado com sucesso
    echo Servidores 24, 25, 26 e 27 tiveram SRF renomeados
    set /A successCount+=4
) else (
    echo ERRO: Falha ao executar script remoto para servidores 24-27 - ERRORLEVEL: !exitCode!
    set /A failCount+=4
)
echo.

echo ========================================
echo [GRUPO 5] Renomeando SRF nos servidores SVR24, SRV10 e SRV09
echo Data/Hora:

echo Conectando em pcpweb@10.238.6.67 (SVR24)...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.67 /home/pcpweb/rename_srf.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo SVR24: Script rename_srf.sh executado com sucesso em 10.238.6.67
    set /A successCount+=1
) else (
    echo ERRO: Falha ao executar script no SVR24 (10.238.6.67) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.6.66 (SRV10)...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.66 /home/pcpweb/rename_srf.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo SRV10: Script rename_srf.sh executado com sucesso em 10.238.6.66
    set /A successCount+=1
) else (
    echo ERRO: Falha ao executar script no SRV10 (10.238.6.66) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo Conectando em pcpweb@10.238.6.65 (SRV09)...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.6.65 /home/pcpweb/rename_srf.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo SRV09: Script rename_srf.sh executado com sucesso em 10.238.6.65
    set /A successCount+=1
) else (
    echo ERRO: Falha ao executar script no SRV09 (10.238.6.65) - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo ========================================
echo RESUMO DO RENAME DE ARQUIVOS SRF
echo ========================================
echo Total de servidores: %totalServers%
echo Scripts executados com sucesso: !successCount!
echo Scripts com falha: !failCount!
echo Data/Hora:

if !failCount! GTR 0 (
    echo AVISO: Processo concluido com falhas
    echo AVISO: Verifique os logs dos servidores que falharam
    echo AVISO: Alguns servidores podem ter arquivos SRF com nome antigo
    echo.
    echo Script finalizado com codigo de erro
    exit /B 1
) else (
    echo SUCESSO: Todos os scripts de rename foram executados com sucesso
    echo Arquivos SRF renomeados em todos os 18 servidores
    echo Os servidores estao prontos para restart com novo SRF
    echo.
    echo Script finalizado com sucesso
    exit /B 0
)
