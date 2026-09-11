
cd C:\Siebel_Devops\temp\batch


scp -rp /cygdrive/c/Siebel_Devops/temp/batch sbleim@10.129.178.52:/opt/integracao/predeploy/tags/

ssh sbleim@10.129.178.52 "cp -R /opt/integracao/predeploy/tags/batch/ /opt/integracao/"
ssh sbleim@10.129.178.52 "rm -rf /opt/integracao/predeploy/tags/batch/*"
ssh sbleim@10.129.178.52 "chmod -R 775 /opt/integracao/batch"

RD /S /Q "C:\Siebel_Devops\temp\batch"


pause