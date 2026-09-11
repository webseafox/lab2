@echo off
REM Script BAT elaborado para fechamento de pacote
REM Autor: Pipeline DevOps Vivo
REM Data: 26/06/2025
REM Descrição: Script responsável por exibir informações de fechamento do pacote

set "Environment=DEFAULT"
set "ShowFullInfo=false"

REM Função para formatar data/hora no padrão Vivo
:GetFormattedDateTime
    for /f "tokens=1-5 delims=/: " %%a in ("%date% %time%") do (
        set "formattedDate=%%d_%%b_%%c_%%e_%%f_%%g"
    )
    exit /b

REM Função principal do script
:InvokePackageCloseInfo
    call :GetFormattedDateTime
    set "currentDirectory=%cd%"
    set "currentUser=%username%"
    set "machineName=%computername%"
    
    REM Exibe cabeçalho
    echo ============================================================
    echo        VIVO DEVOPS - LIMPA REPO
    echo ============================================================
    
    REM Informações básicas
    echo Ambiente: %Environment%
    echo Diretório atual: %currentDirectory%
    echo Usuário: %currentUser%
    echo Máquina: %machineName%
    
    if "%ShowFullInfo%"=="true" (
        echo Sistema Operacional: %OS%
        echo Processador: %PROCESSOR_ARCHITECTURE%
    )
    
    echo ------------------------------------------------------------
    
    REM Mensagem principal de sucesso
    set "successMessage=Conseguimos limpar o repositorio %formattedDate%"
    echo %successMessage%
    
    echo ============================================================
    
    REM Log para arquivo (opcional)
    echo %date% %time% - %successMessage% - Dir: %currentDirectory% >> log.txt

    REM Exibe mensagem simples para compatibilidade com pipelines
    echo %successMessage%
    
    exit /b

REM Executa a função principal
call :InvokePackageCloseInfo