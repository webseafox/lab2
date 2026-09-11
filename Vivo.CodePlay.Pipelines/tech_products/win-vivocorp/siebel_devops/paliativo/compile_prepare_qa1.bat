cd C:\Siebel_Devops\ambientes\qa1

rem Lista todos os arquivos do diretório e salva em new_sifs.log
del C:\Siebel_Devops\ambientes\qa1\new_sifs.log

dir /b /s src-vivocorp-qa1 > new_sifs.log
dir C:\Siebel_Devops\ambientes\
dir C:\Siebel_Devops\ambientes\qa1

cd C:\Siebel_Devops\ambientes\qa1
powershell.exe -file "C:\Siebel_Devops\scripts\replace_qa1.ps1"

for /f "tokens=*" %%a in (new_sifs.log) do (
    echo F|xcopy "%%a" C:\Siebel_Devops\QA1\temp\%%~nxa
)

cd C:\Siebel_Devops\ambientes\qa1
RD /S /Q "C:\Siebel_Devops\ambientes\qa1\src-vivocorp-qa1"