@echo off

rem Lista todos os arquivos do diretório e salva em new_sifs.log
del "C:\Siebel_Devops\ambientes\qa1\new_sifs.log"

dir /b /s "C:\Siebel_Devops\ambientes\qa1\src-vivocorp-qa1" > "C:\Siebel_Devops\ambientes\qa1\new_sifs.log"

rem Exibe diretórios para verificar se os caminhos existem
dir "C:\Siebel_Devops\ambientes"
dir "C:\Siebel_Devops\ambientes\qa1"

cd "C:\Siebel_Devops\ambientes\qa1"

rem Executa o script PowerShell
powershell.exe -file "C:\Siebel_Devops\scripts\replace_qa1.ps1"

rem Loop para copiar os arquivos listados no log
for /f "tokens=*" %%a in ("C:\Siebel_Devops\ambientes\qa1\new_sifs.log") do (
    echo f | xcopy "%%a" "C:\Siebel_Devops\QA1\temp\%%~nxa"
)

rem Remove o diretório src-vivocorp-qa1
RD /S /Q "C:\Siebel_Devops\ambientes\qa1\src-vivocorp-qa1"
