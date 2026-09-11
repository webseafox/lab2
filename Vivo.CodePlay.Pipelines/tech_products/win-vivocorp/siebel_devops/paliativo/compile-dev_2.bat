@echo off
setlocal enabledelayedexpansion

:: Captura a data e hora atuais para criar o nome do log
for /f "tokens=1-5 delims=/: " %%a in ("%date% %time%") do (
    set "ano=%%c"
    set "mes=%%a"
    set "dia=%%b"
    set "hora=%%d"
    set "minuto=%%e"
)

set "nome_log=Compile_%ano%_%mes%_%dia%_%hora%_%minuto%.log"
set "caminho_log=C:\Siebel_Devops\log\%nome_log%"

:: Início da compilação
echo Inicio Compilacao >> "%caminho_log%"
echo %ano%_%mes%_%dia%_%hora%_%minuto% >> "%caminho_log%"

:: Simula um processo longo
timeout /t 600 >nul

:: Captura a data e hora finais após o processo
for /f "tokens=1-5 delims=/: " %%a in ("%date% %time%") do (
    set "ano=%%c"
    set "mes=%%a"
    set "dia=%%b"
    set "hora=%%d"
    set "minuto=%%e"
)

:: Fim da compilação
echo Fim Compilacao >> "%caminho_log%"
echo %ano%_%mes%_%dia%_%hora%_%minuto% >> "%caminho_log%"

:: Log criado com sucesso
echo Log criado com sucesso: %caminho_log%
exit /b 0
