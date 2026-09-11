git config --global user.email "dev.crm.b2b.br@telefonicati.onmicrosoft.com"
git config --global user.name "devops_b2b-vivocorp"

echo %DATE%
echo %TIME%
set datetimei=%date:~-4%_%date:~3,2%_%date:~0,2%_%time:~0,2%_%time:~3,2%_%time:~6,2%

Compilação Siebel Tools

echo Inicio Compilação > C:\Siebel_Devops\log\Compile_PROD_%datetimei%.log
echo %datetimei% >> C:\Siebel_Devops\log\Compile_PROD_%datetimei%.log

C:\Siebel\8.1\Tools_1\BIN\siebdev.exe /c "C:\Siebel\8.1\Tools_1\BIN\ENU\PROD.cfg" /s PROD /u sbleim /p SiebCarga2010 /tl PTB /bc "Siebel Repository" C:\Siebel_Devops\PROD\srf\siebel_sia_new.srf

set datetimef=%date:~-4%_%date:~3,2%_%date:~0,2%_%time:~0,2%_%time:~3,2%_%time:~6,2%

echo Fim Compilação >> C:\Siebel_Devops\log\Compile_PROD_%datetimei%.log
echo %datetimef% >> C:\Siebel_Devops\log\Compile_PROD_%datetimei%.log

