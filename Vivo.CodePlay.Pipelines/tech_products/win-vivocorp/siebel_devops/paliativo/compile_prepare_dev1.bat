@echo off

rem Lista todos os arquivos do diretório e salva em new_sifs.log
REM del "C:\Siebel_Devops\DEV1\ambientes\new_sifs.log"

pwd

REM dir /b /s "C:\Siebel_Devops\DEV1\ambientes\src-vivocorp-dev1" > "C:\Siebel_Devops\DEV1\ambientes\new_sifs.log"


cd "C:\Siebel_Devops\DEV1\ambientes"

rem Executa o script PowerShell
powershell.exe -file "C:\Siebel_Devops\scripts\replace_dev1.ps1"

rem Loop para copiar os arquivos listados no log
for /f "tokens=*" %%a in ("C:\Siebel_Devops\DEV1\ambientes\new_sifs.log") do (
    echo f | xcopy  /Y "%%a" "C:\Siebel_Devops\DEV1\temp\%%~nxa"
)

dir "C:\Siebel_Devops\DEV1\temp\new_sifs.log"

rem Remove o diretório src-vivocorp-dev1
RD /S /Q "C:\Siebel_Devops\DEV1\ambientes\src-vivocorp-dev1"
