@echo off
setlocal enabledelayedexpansion

echo ==================================================
echo === INICIO DO SCRIPT sftp_srf_new_az.bat ===
echo ==================================================

echo Script de distribuição de arquivo SRF para servidores Siebel PROD
echo Propósito: Copiar arquivo SRF para múltiplos servidores via SFTP
echo Inicialização concluída
echo.

set /a totalServers=0
set /a successCount=0
set /a failCount=0
echo Contadores inicializados: Total=0, Sucesso=0, Falha=0
echo.

echo Verificando existência do arquivo SRF em C:\Siebel_Devops\PROD\srf\...

if not exist C:\Siebel_Devops\PROD\srf\siebel_sia_new.srf (
    echo Arquivo siebel_sia_new.srf não encontrado em PROD
    echo Copiando arquivo de C:\Siebel_Devops\PP\srf\ para C:\Siebel_Devops\PROD\srf\...
    
    copy "C:\Siebel_Devops\PP\srf\siebel_sia_new.srf" "C:\Siebel_Devops\PROD\srf\" > nul 2>&1
    
    if !ERRORLEVEL! EQU 0 (
        echo Arquivo SRF copiado com sucesso de PP para PROD
        exit /B 0
    ) else (
        echo ERRO: Falha ao copiar arquivo SRF (código !ERRORLEVEL!)
        echo Verifique se o arquivo existe em C:\Siebel_Devops\PP\srf\
        echo ==================================================
        echo === FIM DO SCRIPT sftp_srf_new_az.bat ===
        echo ==================================================
        exit /B 1
    )
) else (
    echo Arquivo siebel_sia_new.srf já existe em PROD, prosseguindo com distribuição
)
echo.

echo Verificação e preparação do arquivo SRF concluída
echo.

echo Iniciando distribuição para Grupo 1: Servidores 3 a 8...
echo.

echo Transferindo para Servidor 3 (10.238.5.32)...
set /a totalServers+=1
sftp -i C:\id_rsa -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.5.32 22
if !ERRORLEVEL! EQU 0 (
    set /a successCount+=1
    echo   - Servidor 3: Transferência concluída com sucesso
) else (
    set /a failCount+=1
    echo   - AVISO: Servidor 3: Falha na transferência (código !ERRORLEVEL!)
)

echo Transferindo para Servidor 4 (10.238.5.33)...
set /a totalServers+=1
sftp -i C:\id_rsa -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.5.33 22
if !ERRORLEVEL! EQU 0 (
    set /a successCount+=1
    echo   - Servidor 4: Transferência concluída com sucesso
) else (
    set /a failCount+=1
    echo   - AVISO: Servidor 4: Falha na transferência (código !ERRORLEVEL!)
)

echo Transferindo para Servidor 5 (10.238.5.34)...
set /a totalServers+=1
sftp -i C:\id_rsa -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.5.34 22
if !ERRORLEVEL! EQU 0 (
    set /a successCount+=1
    echo   - Servidor 5: Transferência concluída com sucesso
) else (
    set /a failCount+=1
    echo   - AVISO: Servidor 5: Falha na transferência (código !ERRORLEVEL!)
)

echo Transferindo para Servidor 6 (10.238.5.35)...
set /a totalServers+=1
sftp -i C:\id_rsa -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.5.35 22
if !ERRORLEVEL! EQU 0 (
    set /a successCount+=1
    echo   - Servidor 6: Transferência concluída com sucesso
) else (
    set /a failCount+=1
    echo   - AVISO: Servidor 6: Falha na transferência (código !ERRORLEVEL!)
)

echo Transferindo para Servidor 7 (10.238.5.36)...
set /a totalServers+=1
sftp -i C:\id_rsa -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.5.36 22
if !ERRORLEVEL! EQU 0 (
    set /a successCount+=1
    echo   - Servidor 7: Transferência concluída com sucesso
) else (
    set /a failCount+=1
    echo   - AVISO: Servidor 7: Falha na transferência (código !ERRORLEVEL!)
)

echo Transferindo para Servidor 8 (10.238.5.37)...
set /a totalServers+=1
sftp -i C:\id_rsa -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.5.37 22
if !ERRORLEVEL! EQU 0 (
    set /a successCount+=1
    echo   - Servidor 8: Transferência concluída com sucesso
) else (
    set /a failCount+=1
    echo   - AVISO: Servidor 8: Falha na transferência (código !ERRORLEVEL!)
)
echo.

echo Distribuição para Grupo 1 concluída (6 servidores processados)
echo.

echo Iniciando distribuição para Grupo 2: Servidores 1 e 2...
echo.

echo Transferindo para Servidor 1 (10.238.7.12)...
set /a totalServers+=1
sftp -i C:\id_rsa -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.7.12 22
if !ERRORLEVEL! EQU 0 (
    set /a successCount+=1
    echo   - Servidor 1: Transferência concluída com sucesso
) else (
    set /a failCount+=1
    echo   - AVISO: Servidor 1: Falha na transferência (código !ERRORLEVEL!)
)

echo Transferindo para Servidor 2 (10.238.7.13)...
set /a totalServers+=1
sftp -i C:\id_rsa -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.7.13 22
if !ERRORLEVEL! EQU 0 (
    set /a successCount+=1
    echo   - Servidor 2: Transferência concluída com sucesso
) else (
    set /a failCount+=1
    echo   - AVISO: Servidor 2: Falha na transferência (código !ERRORLEVEL!)
)
echo.

echo Distribuição para Grupo 2 concluída (2 servidores processados)
echo.

echo Iniciando distribuição para Grupo 3: Servidores 20 a 23...
echo.

echo Transferindo para Servidor 20 (10.238.6.35)...
set /a totalServers+=1
sftp -i C:\id_rsa -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.6.35 22
if !ERRORLEVEL! EQU 0 (
    set /a successCount+=1
    echo   - Servidor 20: Transferência concluída com sucesso
) else (
    set /a failCount+=1
    echo   - AVISO: Servidor 20: Falha na transferência (código !ERRORLEVEL!)
)

echo Transferindo para Servidor 21 (10.238.6.36)...
set /a totalServers+=1
sftp -i C:\id_rsa -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.6.36 22
if !ERRORLEVEL! EQU 0 (
    set /a successCount+=1
    echo   - Servidor 21: Transferência concluída com sucesso
) else (
    set /a failCount+=1
    echo   - AVISO: Servidor 21: Falha na transferência (código !ERRORLEVEL!)
)

echo Transferindo para Servidor 22 (10.238.6.37)...
set /a totalServers+=1
sftp -i C:\id_rsa -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.6.37 22
if !ERRORLEVEL! EQU 0 (
    set /a successCount+=1
    echo   - Servidor 22: Transferência concluída com sucesso
) else (
    set /a failCount+=1
    echo   - AVISO: Servidor 22: Falha na transferência (código !ERRORLEVEL!)
)

echo Transferindo para Servidor 23 (10.238.6.38)...
set /a totalServers+=1
sftp -i C:\id_rsa -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.6.38 22
if !ERRORLEVEL! EQU 0 (
    set /a successCount+=1
    echo   - Servidor 23: Transferência concluída com sucesso
) else (
    set /a failCount+=1
    echo   - AVISO: Servidor 23: Falha na transferência (código !ERRORLEVEL!)
)
echo.

echo Distribuição para Grupo 3 concluída (4 servidores processados)
echo.

echo Iniciando distribuição para Servidores 24 a 27 via script remoto...
echo Executando script remoto em 10.238.7.12: /home/pcpweb/sftp_srf_new_servers.sh
echo Nota: Script remoto distribui SRF para servidores 24-27 (adicionados em 20240620)
ssh -i C:\id_rsa pcpweb@10.238.7.12 /home/pcpweb/sftp_srf_new_servers.sh
if !ERRORLEVEL! EQU 0 (
    echo Distribuição remota para servidores 24-27 concluída com sucesso
) else (
    echo AVISO: Distribuição remota para servidores 24-27 retornou código de erro !ERRORLEVEL!
    echo Verifique o log do script remoto no servidor 10.238.7.12
)
echo.

echo Iniciando distribuição para servidores SVR24, SRV10 e SRV09...

echo Transferindo para SVR24 (10.238.6.67)...
set /a totalServers+=1
sftp -i C:\id_rsa -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.6.67 22
if !ERRORLEVEL! EQU 0 (
    set /a successCount+=1
    echo   - SVR24: Transferência concluída com sucesso
) else (
    set /a failCount+=1
    echo   - AVISO: SVR24: Falha na transferência (código !ERRORLEVEL!)
)

echo Transferindo para SRV10 (10.238.6.66)...
set /a totalServers+=1
sftp -i C:\id_rsa -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.6.66 22
if !ERRORLEVEL! EQU 0 (
    set /a successCount+=1
    echo   - SRV10: Transferência concluída com sucesso
) else (
    set /a failCount+=1
    echo   - AVISO: SRV10: Falha na transferência (código !ERRORLEVEL!)
)

echo Transferindo para SRV09 (10.238.60.126)...
set /a totalServers+=1
sftp -i C:\id_rsa -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.60.126 22
if !ERRORLEVEL! EQU 0 (
    set /a successCount+=1
    echo   - SRV09: Transferência concluída com sucesso
) else (
    set /a failCount+=1
    echo   - AVISO: SRV09: Falha na transferência (código !ERRORLEVEL!)
)
echo.

echo Distribuição para servidores adicionados concluída
echo.

echo Removendo arquivo SRF local de C:\Siebel_Devops\PROD\srf\...

del "C:\Siebel_Devops\PROD\srf\siebel_sia_new.srf" /f /q > nul 2>&1

if !ERRORLEVEL! EQU 0 (
    echo Arquivo siebel_sia_new.srf removido com sucesso
) else (
    echo AVISO: Falha ao remover arquivo siebel_sia_new.srf (código !ERRORLEVEL!)
)
echo.

echo Limpeza concluída
echo.

echo ====================================================
echo RESUMO DA DISTRIBUIÇÃO DE SRF
echo ====================================================
echo Total de servidores SFTP processados: !totalServers!
echo Transferências bem-sucedidas: !successCount!
echo Transferências com falha: !failCount!
echo.
echo Nota: Servidores 24-27 foram processados via script remoto.
echo       SVR24 e SRV10 também foram processados individualmente e estão incluídos nas estatísticas acima.
echo ====================================================
echo.

if !failCount! GTR 0 (
    echo ATENÇÃO: Algumas transferências falharam. Verifique os logs acima.
    echo ==================================================
    echo === FIM DO SCRIPT sftp_srf_new_az.bat ===
    echo ==================================================
    exit /B 1
) else (
    echo Todas as transferências SFTP foram concluídas com sucesso!
    echo ==================================================
    echo === FIM DO SCRIPT sftp_srf_new_az.bat ===
    echo ==================================================
    exit /B 0
)

endlocal
