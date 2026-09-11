set datetime=%date:~-4%_%date:~3,2%_%date:~0,2%_%time:~0,2%_%time:~3,2%_%time:~6,2%
set "timestamp=%datetime: =0%"
echo %timestamp%


if exist C:\Siebel_Devops\PROD\temp\*.sif (
echo file exists 

C:\Siebel\8.1\Tools_1\BIN\siebdev.exe /c "C:\Siebel\8.1\Tools_1\BIN\ENU\PROD.cfg" /s PROD /u sbleim /p SiebCarga2010 /batchimport "Siebel Repository" overwrite "C:\Siebel_Devops\PROD\temp" C:\Siebel_Devops\log\import_PROD_%timestamp%.log



EXIT /B 0

) else (
echo file sifs doesn't exists
EXIT /B 1
)



