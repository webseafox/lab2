for /R C:\Siebel_Devops\PROD\temp\ADM %%f in (*.xml) do copy "%%f" C:\Siebel_Devops\PROD\temp\stage_xml

sftp -b C:\Siebel_Devops\scripts\sftp_xmls_prod.txt pcpweb@10.238.7.12 22


if exist C:\Siebel_Devops\PROD\temp\stage_xml\* (
echo Existem ADMs, subindo server... 

ssh pcpweb@10.238.7.12 "sudo -u supweb /opt/web/siebel/siebel811/siebelsrv1/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.12 "sleep 240"
ssh pcpweb@10.238.5.32 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.12 "sleep 120"


) else (
echo Nenhum ADM importado. Terminando processo...

)

cd C:\Siebel_Devops\PROD\temp\ADM
del /s /q *.xml

cd C:\Siebel_Devops\PROD\temp\stage_xml
del /s /q *.xml

exit 0
