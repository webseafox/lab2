@echo on

git config --system --unset http.proxy
git config --system --unset https.proxy
git config --system http.proxy http://10.240.58.39:3128
git config --system https.proxy http://10.240.58.39:3128

git config --global user.email "dev.crm.b2b.br@telefonicati.onmicrosoft.com"
git config --global user.name "devops_b2b-vivocorp"
rem set GIT_PATH="C:\Program Files\Git\bin\git.exe"
set BRANCH = "origin"

cd C:\Siebel_Devops\fecha_pacote_prd

git clone https://$(GITUSER):$(GITPASS)@dev.azure.com/telefonica-vivo-brasil/VVCP%%20-%%20VIVOCORP/_git/src.src-vivocorp-hotfix
git clone https://$(GITUSER):$(GITPASS)@dev.azure.com/telefonica-vivo-brasil/VVCP%%20-%%20VIVOCORP/_git/src.src-vivocorp-prod


xcopy C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod\scripts C:\Siebel_Devops\fecha_pacote_prd\temp\scripts\ /E /Y
xcopy C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod\pipeline C:\Siebel_Devops\fecha_pacote_prd\temp\pipeline\ /E /Y
xcopy C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod\VERSION C:\Siebel_Devops\fecha_pacote_prd\temp\ /E /Y

echo F|xcopy C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-hotfix C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod /E /Y

echo F|xcopy C:\Siebel_Devops\fecha_pacote_prd\temp\scripts C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod\scripts\ /E /Y
echo F|xcopy C:\Siebel_Devops\fecha_pacote_prd\temp\pipeline C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod\pipeline\ /E /Y
echo F|xcopy C:\Siebel_Devops\fecha_pacote_prd\temp\VERSION C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod\ /E /Y

cd C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod

git add .
git commit -m "devops"
git push

cd C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-hotfix

git ls-files  >   objetos.txt

sftp -b C:\Siebel_Devops\scripts\hotfix.txt sbleim@10.238.7.12 22

ssh sbleim@10.238.7.12 /home/sbleim/Mail/mailx_hotfix.sh


RD /S /Q "C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-hotfix"
RD /S /Q "C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod"

exit 





