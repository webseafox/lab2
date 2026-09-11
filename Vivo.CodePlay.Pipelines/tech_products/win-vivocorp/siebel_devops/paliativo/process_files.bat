@echo off
REM C:\Siebel_Devops\DEV1\temp
REM C:\Siebel_Devops\temp <- A pasta temp no ambiente de DEV1 não tem o diretótio DEV1

cd  C:\Siebel_Devops\DEV1\ambientes\src-vivocorp-dev1
del /f /q "C:\Siebel_Devops\temp\*.*"
REM Ler o arquivo new_sifs.log linha por linha
for /f "tokens=*" %%a in (new_sifs.log) do (
echo %%a
    echo F|xcopy C:\Siebel_Devops\DEV1\ambientes\src-vivocorp-dev1\"%%a" C:\Siebel_Devops\temp\"%%a"
)