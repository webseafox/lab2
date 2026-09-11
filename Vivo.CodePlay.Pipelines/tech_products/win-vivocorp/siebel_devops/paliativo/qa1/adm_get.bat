for /R C:\Siebel_Devops\QA1\temp\ADM %%f in (*.xml) do copy "%%f" C:\Siebel_Devops\QA1\temp\stage_xml


sftp -b C:\Siebel_Devops\scripts\sftp_xmls_qa1.txt supweb@10.129.194.122 22

exit 0
