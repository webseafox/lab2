@echo off
cd  C:\Siebel_Devops\PP\ambientes\src-vivocorp-pp
del /f /q "C:\Siebel_Devops\PP\temp\*.*"

REM Ler o arquivo new_sifs.log linha por linha
for /f "tokens=*" %%a in (new_sifs.log) do (
    echo %%a
    echo F|xcopy C:\Siebel_Devops\PP\ambientes\src-vivocorp-pp\"%%a" C:\Siebel_Devops\PP\temp\"%%a"
)