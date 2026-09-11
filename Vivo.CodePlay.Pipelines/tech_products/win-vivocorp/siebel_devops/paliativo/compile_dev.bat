@echo off

echo %DATE%
echo %TIME%

set datetimei=%date:~-4%_%date:~3,2%_%date:~0,2%_%time:~0,2%_%time:~3,2%_%time:~6,2%

echo Inicio Compilação > C:\Siebel_Devops\log\Compile_%datetimei%.log
echo %datetimei% >> C:\Siebel_Devops\log\Compile_%datetimei%.log

if exist C:\Siebel_Devops\DEV2\temp\nao_compilar.txt (
    echo Não existem objetos para serem compilados
    del "C:\Siebel_Devops\DEV2\temp\*" /f /q
) else (
    echo Existem objetos para serem compilados! Compilando...
    C:\Siebel\8.1\Tools_1\BIN\siebdev.exe /c "C:\Siebel\8.1\Tools_1\BIN\ENU\DEV2.cfg" /s DEV2 /u $(siebeluser) /p $(siebelpass) /tl PTB /bc "Siebel Repository" C:\Siebel_Devops\srf\siebel_sia_new2.srf
)

set datetimef=%date:~-4%_%date:~3,2%_%date:~0,2%_%time:~0,2%_%time:~3,2%_%time:~6,2%

echo Fim Compilação >> C:\Siebel_Devops\log\Compile_%datetimei%.log
echo %datetimef% >> C:\Siebel_Devops\log\Compile_%datetimei%.log

exit 0
