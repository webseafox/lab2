@echo off

echo === INICIO DO SCRIPT import_az.bat ===

echo Inicializando variáveis de timestamp...
set datetime=%date:~-4%_%date:~3,2%_%date:~0,2%_%time:~0,2%_%time:~3,2%_%time:~6,2%
set "timestamp=%datetime: =0%"
echo Timestamp definido: %timestamp%
echo Inicialização concluída

echo Verificando existência de arquivos SIF em C:\Siebel_Devops\PROD\temp\...
if exist C:\Siebel_Devops\PROD\temp\*.sif (
    echo Arquivos SIF encontrados em C:\Siebel_Devops\PROD\temp\
    echo Iniciando processo de importação...
    
    echo Entrando no diretório de scripts...
    cd /d C:\Siebel_Devops\scripts\
    echo Diretório atual: %CD%
    
    echo Executando atualização de projetos no servidor remoto sbleim@10.238.7.12...
    ssh -i C:\id_rsa sbleim@10.238.7.12 /home/sbleim/devops/atualiza_projetos.sh
    if %ERRORLEVEL% EQU 0 (
        echo Atualização de projetos concluída com sucesso
    ) else (
        echo AVISO: Atualização de projetos retornou código de erro %ERRORLEVEL%
    )
    
    echo Executando limpeza de empflag no servidor remoto sbleim@10.238.7.12...
    ssh -i C:\id_rsa sbleim@10.238.7.12 /home/sbleim/devops/limpa_empflag.sh
    if %ERRORLEVEL% EQU 0 (
        echo Limpeza de empflag concluída com sucesso
    ) else (
        echo AVISO: Limpeza de empflag retornou código de erro %ERRORLEVEL%
    )
    
    echo Iniciando importação de SIFs no repositório Siebel...
    echo Configuração: PROD.cfg
    echo Servidor: PROD
    echo Usuário: sbleim
    echo Modo: batchimport com overwrite
    echo Origem: C:\Siebel_Devops\PROD\temp
    echo Log: C:\Siebel_Devops\log\import_PROD_%timestamp%.log
    
    C:\Siebel\8.1\Tools_1\BIN\siebdev.exe /c "C:\Siebel\8.1\Tools_1\BIN\ENU\PROD.cfg" /s PROD /u sbleim /p SiebCarga2010 /batchimport "Siebel Repository" overwrite "C:\Siebel_Devops\PROD\temp" "C:\Siebel_Devops\log\import_PROD_%timestamp%.log"
    
    if %ERRORLEVEL% EQU 0 (
        echo Importação concluída com sucesso
        echo Log salvo em: C:\Siebel_Devops\log\import_PROD_%timestamp%.log
    ) else (
        echo ERRO: Importação falhou com código %ERRORLEVEL%
        echo Verifique o log em: C:\Siebel_Devops\log\import_PROD_%timestamp%.log
    )
    
    echo Restaurando empflag no servidor remoto sbleim@10.238.7.12...
    ssh -i C:\id_rsa sbleim@10.238.7.12 /home/sbleim/devops/volta_empflag.sh
    if %ERRORLEVEL% EQU 0 (
        echo Restauração de empflag concluída com sucesso
    ) else (
        echo AVISO: Restauração de empflag retornou código de erro %ERRORLEVEL%
    )
    
    echo Removendo arquivos temporários de C:\Siebel_Devops\PROD\temp\...
    del "C:\Siebel_Devops\PROD\temp\*" /f /q
    if %ERRORLEVEL% EQU 0 (
        echo Limpeza de arquivos temporários concluída com sucesso
    ) else (
        echo AVISO: Limpeza de arquivos temporários retornou código de erro %ERRORLEVEL%
    )
    
    echo === FIM DO SCRIPT import_az.bat ===
    EXIT /B 0
    
) else (
    echo Nenhum arquivo SIF encontrado em C:\Siebel_Devops\PROD\temp\
    echo Nada a importar. Script finalizado sem operações.
    echo === FIM DO SCRIPT import_az.bat ===
    EXIT /B 0
)
