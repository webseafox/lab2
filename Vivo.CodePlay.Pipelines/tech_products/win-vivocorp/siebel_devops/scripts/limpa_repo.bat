@echo on

git config --global user.email "dev.crm.b2b.br@telefonicati.onmicrosoft.com"
git config --global user.name "devops_b2b-vivocorp"
rem set GIT_PATH="C:\Program Files\Git\bin\git.exe"
set BRANCH = "origin"

cd C:\Siebel_Devops\PROD\limpa

rem git clone http://$(GITUSER):$(GITPASS)@10.129.178.173/vivocorp/src/src-vivocorp-pp.git
git clone http://$(GITUSER):$(GITPASS)@10.129.178.173/vivocorp/src/src-vivocorp-prod.git

xcopy C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod\scripts C:\Siebel_Devops\PROD\limpa\stage\scripts\ /E /Y
xcopy C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod\pipeline C:\Siebel_Devops\PROD\limpa\stage\pipeline\ /E /Y
xcopy C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod\VERSION C:\Siebel_Devops\PROD\limpa\stage\ /E /Y

FOR /d %%a IN ("C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod\*") DO IF /i NOT "%%~nxa"==".git" RD /S /Q "%%a"
del /f /q "C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod\*"
 
echo F|xcopy C:\Siebel_Devops\PROD\limpa\temp\scripts C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod\scripts\ /E /Y
echo F|xcopy C:\Siebel_Devops\PROD\limpa\temp\pipeline C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod\pipeline\ /E /Y
echo F|xcopy C:\Siebel_Devops\PROD\limpa\temp\VERSION C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod\ /E /Y


cd C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod
 
git add .
git commit -m "Limpa Repositório"
git push

rem rem cd C:\Siebel_Devops\fecha_pacote_prd\

rem RD /S /Q "C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-pp"
rem RD /S /Q "C:\Siebel_Devops\fecha_pacote_prd\src-vivocorp-prod"

pause