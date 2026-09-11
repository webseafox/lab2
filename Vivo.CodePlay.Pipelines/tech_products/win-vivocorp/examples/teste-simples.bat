@echo off
REM Script simples para teste do pipeline win-vivocorp/prod-new.yml

echo ========================================
echo TESTE DE DIRETORIO E VALIDACAO
echo ========================================
echo Data/Hora: %date% %time%
echo Diretorio atual: %CD%
echo.

echo Listando arquivos no diretorio atual:
dir /B

echo.
echo Verificando se estamos no ambiente correto...

REM Verifica se estamos no diretorio Siebel
echo %CD% | findstr /I "Siebel" >nul
if %ERRORLEVEL% == 0 (
    echo [OK] Ambiente Siebel detectado
    exit /b 0
) else (
    echo [INFO] Ambiente generico - teste OK
    exit /b 0
)
