@echo off
git config --global user.email "dev.crm.b2b.br@telefonicati.onmicrosoft.com"
git config --global user.name "devops_b2b-vivocorp"

echo %DATE%
echo %TIME%
set datetimei=%date:~-4%_%date:~3,2%_%date:~0,2%_%time:~0,2%_%time:~3,2%_%time:~6,2%

echo Inicio Compilação > C:\Siebel_Devops\log\Compile_%datetimei%.log
echo %datetimei% >> C:\Siebel_Devops\log\Compile_%datetimei%.log

if exist C:\Siebel_Devops\temp\nao_compilar.txt (
echo não existem objetos para serem compilados 


del "C:\Siebel_Devops\temp\*" /f /q


) else (
echo existem objetos para serem compilados
C:\Siebel\8.1\Tools_1\BIN\siebdev.exe /c "C:\Siebel\8.1\Tools_1\BIN\ENU\DEV2.cfg" /s DEV1 /u $(siebeluser) /p $(siebelpass) /tl PTB /bc "Siebel Repository" C:\Siebel_Devops\srf\siebel_sia_new2.srf


)


set datetimef=%date:~-4%_%date:~3,2%_%date:~0,2%_%time:~0,2%_%time:~3,2%_%time:~6,2%

echo Fim Compilação >> C:\Siebel_Devops\log\Compile_%datetimei%.log
echo %datetimef% >> C:\Siebel_Devops\log\Compile_%datetimei%.log

exit 0