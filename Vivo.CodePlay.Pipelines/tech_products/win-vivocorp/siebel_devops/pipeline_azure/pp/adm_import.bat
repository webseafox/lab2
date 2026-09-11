ssh supweb@10.129.178.54 /opt/web/siebel/siebelfs/scripts/import_adm.sh

if exist C:\Siebel_Devops\PP\temp\stage_xml\*.xml (
echo ADMs foram importados! Necessario novo restart. 

dir /b /a-d C:\Siebel_Devops\PP\temp\stage_xml\*.xml

ssh supweb@10.129.178.54 /opt/web/siebel/scripts/administration/bin/devops_stop.sh

echo Iniciando Siebel Server....
setlocal enableextensions
ssh supweb@10.129.178.54 "/opt/web/siebel/scripts/administration/bin/devops_start.sh &>/dev/null &"

) else (
echo Nenhum ADM importado. Terminando processo...

)


cd C:\Siebel_Devops\PP\temp\ADM
del /s /q *.xml

cd C:\Siebel_Devops\PP\temp\stage_xml
del /s /q *.xml


scp -rp /cygdrive/c/Siebel_Devops/PP/temp/batch sbleim@10.129.178.54:/opt/integracao/predeploy/tags/

cd /opt/integracao/predeploy/tags/batch
ssh sbleim@10.129.178.54 "cd /opt/integracao/predeploy/tags/batch;find . -type f -print0 | xargs -0 dos2unix"

ssh sbleim@10.129.178.54 "cp -R /opt/integracao/predeploy/tags/batch/ /opt/integracao/"
ssh sbleim@10.129.178.54 "rm -rf /opt/integracao/predeploy/tags/batch/*"
rem ssh sbleim@10.129.178.54 "chmod -R 775 /opt/integracao/batch"

RD /S /Q "C:\Siebel_Devops\PP\temp\batch"

exit 0