@echo off

rem Lista todos os arquivos do diretório e salva em new_sifs.log
del "C:\Siebel_Devops\ambientes\qa2\new_sifs.log"

dir /b /s "C:\Siebel_Devops\ambientes\qa2\src-vivocorp-qa2" > "C:\Siebel_Devops\ambientes\qa2\new_sifs.log"

rem Exibe diretórios para verificar se os caminhos existem
dir "C:\Siebel_Devops\ambientes"
dir "C:\Siebel_Devops\ambientes\qa2"

cd "C:\Siebel_Devops\ambientes\qa2"

rem Executa o script PowerShell
powershell.exe -file "C:\Siebel_Devops\scripts\replace_qa2.ps1"

rem Loop para copiar os arquivos listados no log
for /f "tokens=*" %%a in ("C:\Siebel_Devops\ambientes\qa2\new_sifs.log") do (
    echo f | xcopy "%%a" "C:\Siebel_Devops\QA2\temp\%%~nxa"
)

rem Remove o diretório src-vivocorp-qa2
RD /S /Q "C:\Siebel_Devops\ambientes\qa2\src-vivocorp-qa2"
