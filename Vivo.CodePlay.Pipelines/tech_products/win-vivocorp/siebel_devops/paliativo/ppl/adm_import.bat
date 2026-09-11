ssh supweb@10.129.173.29 /opt/web/siebel/siebelfs/scripts/import_adm.sh

if exist C:\Siebel_Devops\PPL\temp\stage_xml\*.xml (
echo ADMs foram importados! Necessario novo restart. 

dir /b /a-d C:\Siebel_Devops\PPL\temp\stage_xml\*.xml

ssh supweb@10.129.173.29 /opt/web/siebel/scripts/administration/bin/devops_stop.sh
echo Iniciando Siebel Server....
setlocal enableextensions
ssh supweb@10.129.173.29 "/opt/web/siebel/scripts/administration/bin/devops_start.sh &>/dev/null &"

) else (
echo Nenhum ADM importado. Terminando processo...

)

cd C:\Siebel_Devops\PPL\temp\ADM
del /s /q *.xml

cd C:\Siebel_Devops\PPL\temp\stage_xml
del /s /q *.xml


scp -rp /cygdrive/c/Siebel_Devops/PPL/temp/batch sbleim@10.129.173.29:/opt/integracao/predeploy/tags/

cd /opt/integracao/predeploy/tags/batch
ssh sbleim@10.129.173.29 "cd /opt/integracao/predeploy/tags/batch;find . -type f -print0 | xargs -0 dos2unix"

ssh sbleim@10.129.173.29 "cp -R /opt/integracao/predeploy/tags/batch/ /opt/integracao/"
ssh sbleim@10.129.173.29 "rm -rf /opt/integracao/predeploy/tags/batch/*"


RD /S /Q "C:\Siebel_Devops\PPL\temp\batch"

exit 0