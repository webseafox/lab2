for /R C:\Siebel_Devops\PP\temp\ADM %%f in (*.xml) do copy "%%f" C:\Siebel_Devops\PP\temp\stage_xml


sftp -b C:\Siebel_Devops\scripts\sftp_xmls_pp.txt supweb@10.129.178.54 22

exit 0
