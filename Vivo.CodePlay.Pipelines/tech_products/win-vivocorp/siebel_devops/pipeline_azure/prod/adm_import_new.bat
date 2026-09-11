ssh pcpweb@10.238.7.12 "chmod 777 /opt/web/siebel/siebelfs/deploy/*"

ssh pcpweb@10.238.7.12 /home/pcpweb/import_adm.sh

if exist C:\Siebel_Devops\PROD\temp\batch\* (
	scp -rp /cygdrive/c/Siebel_Devops/PROD/temp/batch sbleim@10.238.7.12:/opt/integracao/predeploy/tags/

	cd /opt/integracao/predeploy/tags/batch
	ssh sbleim@10.238.7.12 "cd /opt/integracao/predeploy/tags/batch;find . -type f -print0 | xargs -0 dos2unix"
	ssh sbleim@10.238.7.12 "cp -R /opt/integracao/predeploy/tags/batch/ /opt/integracao/"
	ssh sbleim@10.238.7.12 /opt/integracao/predeploy/chmod_batch.sh
	ssh sbleim@10.238.7.12 "rm -rf /opt/integracao/predeploy/tags/batch/*"
	
	RD /S /Q "C:\Siebel_Devops\PROD\temp\batch"
)
exit 0