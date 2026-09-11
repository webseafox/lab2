@echo off

rem Lista todos os arquivos do diretório e salva em new_sifs.log
del "C:\Siebel_Devops\PP\ambientes\new_sifs.log"

pwd

dir /b /s "C:\Siebel_Devops\PP\ambientes\src-vivocorp-pp" > "C:\Siebel_Devops\PP\ambientes\new_sifs.log"

cd "C:\Siebel_Devops\PP\ambientes"

rem Executa o script PowerShell
powershell.exe -file "C:\Siebel_Devops\scripts\replace_pp.ps1"

rem Loop para copiar os arquivos listados no log
for /f "tokens=*" %%a in ("C:\Siebel_Devops\PP\ambientes\new_sifs.log") do (
    echo f | xcopy "%%a" "C:\Siebel_Devops\PP\temp\%%~nxa"
)

rem Remove o diretório src-vivocorp-pp
RD /S /Q "C:\Siebel_Devops\PP\ambientes\src-vivocorp-pp"
