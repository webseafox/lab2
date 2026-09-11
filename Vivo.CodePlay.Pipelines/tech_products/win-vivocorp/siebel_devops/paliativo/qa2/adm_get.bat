for /R C:\Siebel_Devops\QA2\temp\ADM %%f in (*.xml) do copy "%%f" C:\Siebel_Devops\QA2\temp\stage_xml


sftp -b C:\Siebel_Devops\scripts\sftp_xmls_qa2.txt supweb@10.129.170.12 22

exit 0