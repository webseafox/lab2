for /R C:\Siebel_Devops\PPL\temp\ADM %%f in (*.xml) do copy "%%f" C:\Siebel_Devops\PPL\temp\stage_xml


sftp -b C:\Siebel_Devops\scripts\sftp_xmls_ppl.txt supweb@10.129.173.29 22

exit 0
