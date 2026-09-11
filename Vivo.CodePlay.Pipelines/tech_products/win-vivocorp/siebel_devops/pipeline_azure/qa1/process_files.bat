@echo off
cd  C:\Siebel_Devops\ambientes
del /f /q "C:\Siebel_Devops\QA1\temp\*.*"
REM Ler o arquivo new_sifs.log linha por linha
for /f "tokens=*" %%a in (new_sifs.log) do (
echo %%a
echo f | xcopy C:\Siebel_Devops\ambientes\qa1\src-vivocorp-qa1\"%%a" C:\Siebel_Devops\QA1\temp\"%%a"
)