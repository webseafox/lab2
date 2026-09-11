@echo off
setlocal enabledelayedexpansion

echo ==================================================
echo === INICIO DO SCRIPT adm_get_new_az.bat ===
echo ==================================================

echo Script de processamento de arquivos ADM (XML) para ambiente PROD
echo Propósito: Copiar XMLs, transferir via SFTP e limpar diretórios temporários
echo Inicialização concluída
echo.

echo Procurando arquivos XML em C:\Siebel_Devops\PROD\temp\ADM...
set /a xmlCount=0

for /R C:\Siebel_Devops\PROD\temp\ADM %%f in (*.xml) do (
    set /a xmlCount+=1
    echo Copiando arquivo !xmlCount!: %%~nxf
    copy "%%f" "C:\Siebel_Devops\PROD\temp\stage_xml" > nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        echo   - Copiado com sucesso
    ) else (
        echo   - AVISO: Falha ao copiar (código !ERRORLEVEL!)
    )
)

if !xmlCount! EQU 0 (
    echo Nenhum arquivo XML encontrado em C:\Siebel_Devops\PROD\temp\ADM
) else (
    echo Total de arquivos XML processados: !xmlCount!
)
echo Cópia de arquivos concluída
echo.

echo Verificando existência de arquivos em C:\Siebel_Devops\PROD\temp\stage_xml...

set "stageDir=C:\Siebel_Devops\PROD\temp\stage_xml"
set "foundFiles=0"

for %%f in ("%stageDir%\*.xml") do set "foundFiles=1"

if !foundFiles! EQU 1 (
    echo Arquivos ADM encontrados no diretório de staging
    echo Iniciando processo de transferência e limpeza...

    echo Iniciando transferência SFTP para pcpweb@10.238.7.12:22...
    echo Arquivo de comandos: C:\Siebel_Devops\scripts\sftp_xmls_prod.txt

    echo Diretório atual: %CD%
    cd /d %stageDir%
    echo Diretório atual: %CD%
    sftp -v -i C:\id_rsa -b C:\Siebel_Devops\scripts\sftp_xmls_prod.txt pcpweb@10.238.7.12 22
    if !ERRORLEVEL! EQU 0 (
        echo Transferência SFTP concluída com sucesso
    ) else (
        echo AVISO: Transferência SFTP retornou código de erro !ERRORLEVEL!
    )

    echo Entrando no diretório de staging...
    cd /d %stageDir%
    echo Diretório atual: %CD%

    echo Removendo arquivos XML do diretório de staging...
    del /s /q *.xml > nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        echo Limpeza do diretório stage_xml concluída com sucesso
    ) else (
        echo AVISO: Limpeza do diretório stage_xml retornou código de erro !ERRORLEVEL!
    )

    echo Entrando no diretório ADM...
    cd /d C:\Siebel_Devops\PROD\temp\ADM
    echo Diretório atual: %CD%

    echo Removendo arquivos XML do diretório ADM...
    del /s /q *.xml > nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        echo Limpeza do diretório ADM concluída com sucesso
    ) else (
        echo AVISO: Limpeza do diretório ADM retornou código de erro !ERRORLEVEL!
    )

    echo Processo de transferência e limpeza concluído
    echo ==================================================
    echo === FIM DO SCRIPT adm_get_new_az.bat ===
    echo ==================================================
    exit /B 0

) else (
    echo Nenhum arquivo ADM encontrado no diretório de staging
    echo Nada a transferir. Script finalizado sem operações de SFTP/limpeza.
    echo ==================================================
    echo === FIM DO SCRIPT adm_get_new_az.bat ===
    echo ==================================================
    exit /B 0
)

endlocal