for /R C:\Siebel_Devops\temp\ADM %%f in (*.xml) do copy %%f C:\Siebel_Devops\temp\stage_xml


sftp -b C:\Siebel_Devops\scripts\sftp_xmls.txt supweb@10.129.178.52 22

 exit 0