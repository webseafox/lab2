@echo off

echo 'Exibe o conteudo do new_sifs.log'

REM Define o diretório de trabalho
cd C:\Siebel_Devops\ambientes\ppl

REM Remove todos os arquivos do diretório temp
del /f /q "C:\Siebel_Devops\PPL\temp\*.*"

REM Ler o arquivo new_sifs.log linha por linha
for /f "tokens=*" %%a in (new_sifs.log) do (
    echo %%a
    echo F|xcopy C:\Siebel_Devops\ambientes\ppl\src-vivocorp-ppl\"%%a" C:\Siebel_Devops\PPL\temp\"%%a"
)
