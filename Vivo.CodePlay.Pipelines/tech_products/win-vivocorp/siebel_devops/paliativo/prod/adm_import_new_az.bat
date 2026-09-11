@echo off
setlocal enabledelayedexpansion

echo ==================================================
echo === INICIO DO SCRIPT adm_import_new_az.bat
echo ===
echo ==================================================

echo Script: Importar ADM e processar scripts batch
echo Propósito: %date% %time%
echo Data/Hora:

echo Iniciando processo de import ADM e deploy de scripts batch...
echo.

set successCount=0
set failCount=0
set batchFilesExist=0

echo ========================================
echo [SECAO 1] Ajustando permissoes em /opt/web/siebel/siebelfs/deploy
echo Data/Hora:

echo [Deploy] Conectando em pcpweb@10.238.7.12...
echo [Deploy] Executando: chmod 777 /opt/web/siebel/siebelfs/deploy/*
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.7.12 "test -d /opt/web/siebel/siebelfs/deploy && find /opt/web/siebel/siebelfs/deploy -maxdepth 1 -type f -exec chmod 777 {} \; 2>/dev/null || true" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo [Deploy] Permissoes ajustadas com sucesso
    set /A successCount+=1
) else (
    echo ERRO: Falha ao ajustar permissoes - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo ========================================
echo [SECAO 2] Executando import ADM
echo Data/Hora:

echo [Import ADM] Conectando em pcpweb@10.238.7.12...
echo [Import ADM] Executando: /home/pcpweb/import_adm.sh
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.7.12 /home/pcpweb/import_adm.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo [Import ADM] Script import_adm.sh executado com sucesso
    set /A successCount+=1
) else (
    echo ERRO: Falha ao executar import_adm.sh - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo ========================================
echo [SECAO 3] Verificando arquivos batch locais
echo Data/Hora:

echo [Batch Check] Verificando diretorio: C:\Siebel_Devops\PROD\temp\batch\
if exist "C:\Siebel_Devops\PROD\temp\batch\*" (
    echo [Batch Check] Arquivos batch encontrados - prosseguindo com deploy
    set batchFilesExist=1
) else (
    echo Nenhum arquivo batch encontrado em C:\Siebel_Devops\PROD\temp\batch\
    echo Pulando secoes de deploy de batch
    goto :resumo
)
echo.

echo ========================================
echo [SECAO 4] Upload de arquivos batch via SCP
echo Data/Hora:

echo [SCP Upload] Origem: C:\Siebel_Devops\PROD\temp\batch\
echo [SCP Upload] Destino: sbleim@10.238.7.12:/opt/integracao/predeploy/tags/
echo [SCP Upload] Iniciando transferencia...
scp -i C:\id_rsa -rp -o StrictHostKeyChecking=no -o BatchMode=yes /cygdrive/c/Siebel_Devops/PROD/temp/batch sbleim@10.238.7.12:/opt/integracao/predeploy/tags/ >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo [SCP Upload] Arquivos transferidos com sucesso
    set /A successCount+=1
) else (
    echo ERRO: Falha no upload SCP - ERRORLEVEL: !exitCode!
    set /A failCount+=1
    goto :cleanup
)
echo.

echo ========================================
echo [SECAO 5] Convertendo arquivos para formato Unix
echo Data/Hora:

echo [dos2unix] Conectando em sbleim@10.238.7.12...
echo [dos2unix] Diretorio: /opt/integracao/predeploy/tags/batch
echo [dos2unix] Convertendo todos os arquivos...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes sbleim@10.238.7.12 "cd /opt/integracao/predeploy/tags/batch;find . -type f -print0 | xargs -0 dos2unix" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo [dos2unix] Conversao concluida com sucesso
    set /A successCount+=1
) else (
    echo ERRO: Falha na conversao dos2unix - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo ========================================
echo [SECAO 6] Copiando batch para diretorio de integracao
echo Data/Hora:

echo [Copy Batch] Conectando em sbleim@10.238.7.12...
echo [Copy Batch] Origem: /opt/integracao/predeploy/tags/batch/
echo [Copy Batch] Destino: /opt/integracao/
echo [Copy Batch] Executando copia recursiva...
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes sbleim@10.238.7.12 "cp -R /opt/integracao/predeploy/tags/batch/ /opt/integracao/" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo [Copy Batch] Arquivos copiados com sucesso
    set /A successCount+=1
) else (
    echo ERRO: Falha ao copiar arquivos - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo ========================================
echo [SECAO 7] Ajustando permissoes dos scripts batch
echo Data/Hora:

echo [chmod_batch] Conectando em sbleim@10.238.7.12...
echo [chmod_batch] Executando: /opt/integracao/predeploy/chmod_batch.sh
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes sbleim@10.238.7.12 /opt/integracao/predeploy/chmod_batch.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo [chmod_batch] Permissoes ajustadas com sucesso
    set /A successCount+=1
) else (
    echo ERRO: Falha ao ajustar permissoes batch - ERRORLEVEL: !exitCode!
    set /A failCount+=1
)
echo.

echo ========================================
echo [SECAO 8] Limpeza do diretorio remoto tags/batch
echo Data/Hora:

echo [Cleanup Remote] Conectando em sbleim@10.238.7.12...
echo [Cleanup Remote] Removendo: /opt/integracao/predeploy/tags/batch/*
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes sbleim@10.238.7.12 "rm -rf /opt/integracao/predeploy/tags/batch/*" >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo [Cleanup Remote] Diretorio remoto limpo com sucesso
    set /A successCount+=1
) else (
    echo AVISO: Falha ao limpar diretorio remoto - ERRORLEVEL: !exitCode!
    echo AVISO: Limpeza manual pode ser necessaria
)
echo.

:cleanup
echo ========================================
echo [SECAO 9] Limpeza do diretorio local
echo Data/Hora:

echo [Cleanup Local] Verificando diretorio: C:\Siebel_Devops\PROD\temp\batch
if exist "C:\Siebel_Devops\PROD\temp\batch" (
    echo [Cleanup Local] Removendo diretorio local...
    RD /S /Q "C:\Siebel_Devops\PROD\temp\batch"
    if !ERRORLEVEL! EQU 0 (
        echo [Cleanup Local] Diretorio local removido com sucesso
        set /A successCount+=1
    ) else (
        echo AVISO: Falha ao remover diretorio local - ERRORLEVEL: !ERRORLEVEL!
        echo AVISO: Remocao manual pode ser necessaria
    )
) else (
    echo [Cleanup Local] Diretorio local nao existe, nenhuma limpeza necessaria
)
echo.

:resumo
echo ========================================
echo RESUMO DO PROCESSO ADM IMPORT
echo ========================================
echo Operacoes bem-sucedidas: !successCount!
echo Operacoes com falha: !failCount!

if !batchFilesExist! EQU 1 (
    echo Arquivos batch: Encontrados e processados
) else (
    echo Arquivos batch: Nenhum arquivo encontrado
)
echo Data/Hora:

if !failCount! GTR 0 (
    echo AVISO: Processo concluido com falhas
    echo AVISO: Verifique os logs das operacoes que falharam
    echo AVISO: Import ADM ou deploy batch podem estar incompletos
    echo.
    echo Script finalizado com codigo de erro
    exit /B 1
) else (
    echo SUCESSO: Todas as operacoes foram executadas com sucesso
    echo Import ADM concluido
    
    if !batchFilesExist! EQU 1 (
        echo Scripts batch deployados e configurados em /opt/integracao/
    )
    
    echo Processo finalizado com sucesso
    echo.
    exit /B 0
)
