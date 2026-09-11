for /R C:\Siebel_Devops\PROD\temp\ADM %%f in (*.xml) do copy "%%f" C:\Siebel_Devops\PROD\temp\stage_xml

if exist C:\Siebel_Devops\PROD\temp\stage_xml\* (
	echo Existem ADMs
	
	sftp -b C:\Siebel_Devops\scripts\sftp_xmls_prod.txt pcpweb@10.238.7.12 22
	
	cd C:\Siebel_Devops\PROD\temp\stage_xml
	del /s /q *.xml
	
	cd C:\Siebel_Devops\PROD\temp\ADM
	del /s /q *.xml
) else (
	echo Nenhum ADM importado. Terminando processo...
)

exit 0
