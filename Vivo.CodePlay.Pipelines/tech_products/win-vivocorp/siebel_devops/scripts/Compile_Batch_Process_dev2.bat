echo %DATE%
echo %TIME%
set datetimei=%date:~-4%_%date:~3,2%_%date:~0,2%_%time:~0,2%_%time:~3,2%_%time:~6,2%

echo Inicio Compilação > C:\Siebel_Devops\log\Compile_DEV2_%datetimei%.log
echo %datetimei% >> C:\Siebel_Devops\log\Compile_DEV2_%datetimei%.log

C:\Siebel\8.1\Tools_1\BIN\siebdev.exe /c "C:\Siebel\8.1\Tools_1\BIN\ENU\DEV2.cfg" /s DEV2 /u $(siebeluser) /p $(siebelpass) /tl PTB /bc "Siebel Repository" C:\Siebel_Devops\DEV2\srf\siebel_sia_new.srf

set datetimef=%date:~-4%_%date:~3,2%_%date:~0,2%_%time:~0,2%_%time:~3,2%_%time:~6,2%

echo Fim Compilação >> C:\Siebel_Devops\log\Compile_DEV2_%datetimei%.log
echo %datetimef% >> C:\Siebel_Devops\log\Compile_DEV2_%datetimei%.log

del "C:\Windows\System32\config\systemprofile\AppData\Local\Jenkins\.jenkins\workspace\SFTP_DEV2\*.srf"  /f /q /s
move C:\Siebel_Devops\DEV2\srf\siebel_sia_new.srf "C:\Windows\System32\config\systemprofile\AppData\Local\Jenkins\.jenkins\workspace\SFTP_DEV2\siebel_sia_new.srf" 
