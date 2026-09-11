@echo off
set datetime=%date:~-4%_%date:~3,2%_%date:~0,2%_%time:~0,2%_%time:~3,2%_%time:~6,2%
set "timestamp=%datetime: =0%"
echo %timestamp%


if exist C:\Siebel_Devops\QA1\temp\*.sif (
echo file exists 

C:\Siebel\8.1\Tools_1\BIN\siebdev.exe /c "C:\Siebel\8.1\Tools_1\BIN\ENU\QA1.cfg" /s QA1 /u $(siebeluser) /p $(siebelpass) /batchimport "Siebel Repository" overwrite "C:\Siebel_Devops\QA1\temp" C:\Siebel_Devops\log\import_qa1_%timestamp%.log

del "C:\Siebel_Devops\QA1\temp\*" /f /q

EXIT /B 0

) else (

echo file sifs doesn't exists
echo "file sifs doesn't exists">C:\Siebel_Devops\QA1\temp\nao_compilar.txt

)

exit 0




