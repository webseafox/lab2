@echo off
REM =========================================================================
REM Script de exemplo para validacao de diretorio
REM Compativel com pipeline win-vivocorp/prod-new.yml
REM =========================================================================

echo [INFO] Iniciando validacao do diretorio atual...
echo [INFO] Data/Hora: %date% %time%
echo.

REM Obtem o diretorio atual
set CURRENT_DIR=%CD%
echo [INFO] Diretorio atual: %CURRENT_DIR%

REM Executa DIR para listar conteudo
echo.
echo [INFO] Listando conteudo do diretorio atual:
echo -------------------------------------------------------------------------
dir /B
echo -------------------------------------------------------------------------

REM Valida se estamos no diretorio esperado
echo.
echo [INFO] Validando diretorio...

REM Testa caminhos conhecidos do Siebel_Devops (evita busca lenta)
echo [INFO] Verificando caminhos conhecidos do Siebel_Devops...

REM Primeiro verifica se ja estamos no diretorio correto
echo %CURRENT_DIR% | findstr /I "Siebel_Devops" >nul
if %ERRORLEVEL% == 0 (
    echo [SUCCESS] Ja estamos no diretorio Siebel_Devops: %CURRENT_DIR%
    set VALIDATION_RESULT=SUCCESS
    goto :end_validation
)

REM Testa caminhos comuns (mais rapido que busca recursiva)
if exist "C:\Siebel_Devops" (
    echo [INFO] Diretorio encontrado em: C:\Siebel_Devops
    cd /d "C:\Siebel_Devops"
    goto :found_siebel
)

if exist "D:\Siebel_Devops" (
    echo [INFO] Diretorio encontrado em: D:\Siebel_Devops
    cd /d "D:\Siebel_Devops"
    goto :found_siebel
)

if exist "%USERPROFILE%\Siebel_Devops" (
    echo [INFO] Diretorio encontrado em: %USERPROFILE%\Siebel_Devops
    cd /d "%USERPROFILE%\Siebel_Devops"
    goto :found_siebel
)

REM Se nao encontrou nos caminhos comuns
echo [WARNING] Diretorio Siebel_Devops nao encontrado nos caminhos comuns
echo [INFO] Continuando validacao no diretorio atual: %CURRENT_DIR%
set VALIDATION_RESULT=WARNING
goto :end_validation

:found_siebel
REM Atualiza o diretorio atual apos navegacao
set CURRENT_DIR=%CD%
echo [INFO] Novo diretorio atual: %CURRENT_DIR%

REM Verifica se estamos no diretorio base do Siebel
echo %CURRENT_DIR% | findstr /I "Siebel_Devops" >nul
if %ERRORLEVEL% == 0 (
    echo [SUCCESS] Diretorio validado - Estamos no ambiente Siebel DevOps
    set VALIDATION_RESULT=SUCCESS
) else (
    echo [WARNING] Diretorio nao reconhecido como ambiente Siebel DevOps
    set VALIDATION_RESULT=WARNING
)

:end_validation

REM Verifica se existem arquivos de configuracao importantes
echo.
echo [INFO] Verificando arquivos de configuracao...

if exist "*.bat" (
    echo [INFO] Encontrados arquivos .bat no diretorio
    dir *.bat /B
)

if exist "*.cmd" (
    echo [INFO] Encontrados arquivos .cmd no diretorio
    dir *.cmd /B
)

if exist "*.ps1" (
    echo [INFO] Encontrados arquivos PowerShell no diretorio
    dir *.ps1 /B
)

REM Valida espaco em disco
echo.
echo [INFO] Verificando espaco em disco...
for /f "tokens=3" %%a in ('dir /-c %CURRENT_DIR% ^| find "bytes free"') do set FREE_SPACE=%%a
echo [INFO] Espaco livre no disco: %FREE_SPACE% bytes

REM Resultado final
echo.
echo =========================================================================
echo [RESULTADO] Validacao concluida com status: %VALIDATION_RESULT%
echo [INFO] Diretorio: %CURRENT_DIR%
echo [INFO] Arquivos encontrados: 
dir /B | find /C /V "" > temp_count.txt
set /p FILE_COUNT=<temp_count.txt
del temp_count.txt
echo [INFO] Total de arquivos/pastas: %FILE_COUNT%
echo =========================================================================

REM Define codigo de saida baseado na validacao
if "%VALIDATION_RESULT%"=="SUCCESS" (
    echo [INFO] Script executado com sucesso
    exit /b 0
) else (
    echo [WARNING] Script executado com avisos
    exit /b 1
)
