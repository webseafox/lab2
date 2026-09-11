if not exist C:\Siebel_Devops\PROD\srf\siebel_sia_new.srf ( copy C:\Siebel_Devops\PP\srf\siebel_sia_new.srf C:\Siebel_Devops\PROD\srf )

rem copy srf 3 a 8
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.5.32 22
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.5.33 22
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.5.34 22
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.5.35 22
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.5.36 22
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.5.37 22
rem 
rem rem copy srf 1 e 2
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.7.12 22
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.7.13 22
rem 
rem rem copy srf 20 a 23
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.6.35 22
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.6.36 22
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.6.37 22
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.6.38 22

rem SDANGELIS [Adicionados novos servidores] 20240620
rem Server 24 a 27
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.6.65 22
sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.6.66 22

ssh $(host) /home/pcpweb/sftp_srf_new_servers.sh

rem sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.6.67 22
rem sftp -b C:\Siebel_Devops\scripts\sftp_put_prod_new.txt pcpweb@10.238.6.68 22

rm C:\Siebel_Devops\PROD\srf\siebel_sia_new.srf

