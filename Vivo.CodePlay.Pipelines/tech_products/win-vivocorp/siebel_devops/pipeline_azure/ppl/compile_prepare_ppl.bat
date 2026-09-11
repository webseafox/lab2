@echo off

rem Lista todos os arquivos do diretório e salva em new_sifs.log
del "C:\Siebel_Devops\ambientes\ppl\new_sifs.log"

dir /b /s "C:\Siebel_Devops\ambientes\ppl\src-vivocorp-ppl" > "C:\Siebel_Devops\ambientes\ppl\new_sifs.log"

cd "C:\Siebel_Devops\ambientes\ppl"

rem Executa o script PowerShell
powershell.exe -file "C:\Siebel_Devops\scripts\replace_ppl.ps1"

rem Loop para copiar os arquivos listados no log
for /f "tokens=*" %%a in ("C:\Siebel_Devops\ambientes\ppl\new_sifs.log") do (
    echo f | xcopy "%%a" "C:\Siebel_Devops\PPL\temp\%%~nxa"
)

rem Remove o diretório src-vivocorp-ppl
RD /S /Q "C:\Siebel_Devops\ambientes\ppl\src-vivocorp-ppl"
