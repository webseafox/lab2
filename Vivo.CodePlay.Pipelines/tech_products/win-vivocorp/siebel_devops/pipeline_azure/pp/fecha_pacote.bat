@echo on

git config --global user.email "dev.crm.b2b.br@telefonicati.onmicrosoft.com"
git config --global user.name "devops_b2b-vivocorp"
rem set GIT_PATH="C:\Program Files\Git\bin\git.exe"
set BRANCH = "origin"

cd C:\Siebel_Devops\fecha_pacote_prd

git clone http://$(GITUSER):$(GITPASS)@10.129.178.173/vivocorp/src/src-vivocorp-pp.git
git clone http://$(GITUSER):$(GITPASS)@10.129.178.173/vivocorp/src/src-vivocorp-prod.git

xcopy C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod\scripts C:\Siebel_Devops\fecha_pacote_prd\temp\scripts\ /E /Y
xcopy C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod\pipeline C:\Siebel_Devops\fecha_pacote_prd\temp\pipeline\ /E /Y
xcopy C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod\VERSION C:\Siebel_Devops\fecha_pacote_prd\temp\ /E /Y
xcopy C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod\.azuredevops C:\Siebel_Devops\fecha_pacote_prd\temp\ /E /Y

echo F|xcopy C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-pp C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod /E /Y

echo F|xcopy C:\Siebel_Devops\fecha_pacote_prd\temp\scripts C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod\scripts\ /E /Y
echo F|xcopy C:\Siebel_Devops\fecha_pacote_prd\temp\pipeline C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod\pipeline\ /E /Y
echo F|xcopy C:\Siebel_Devops\fecha_pacote_prd\temp\VERSION C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod\ /E /Y
echo F|xcopy C:\Siebel_Devops\fecha_pacote_prd\temp\.azuredevops C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod\ /E /Y

cd C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod

git add .
git commit -m "devops"
git push

cd C:\Siebel_Devops\fecha_pacote_prd\

RD /S /Q "C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-pp"
RD /S /Q "C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod"


ssh sbleim@10.238.7.12 /home/sbleim/Mail/mailx_hotfix.sh
