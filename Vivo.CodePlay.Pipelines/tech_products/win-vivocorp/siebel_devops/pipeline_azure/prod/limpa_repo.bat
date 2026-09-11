@echo on

set datetime=%date:~-4%_%date:~3,2%_%date:~0,2%_%time:~0,2%_%time:~3,2%_%time:~6,2%
set "timestamp=%datetime: =0%"
echo %timestamp%


git config --global user.email "dev.crm.b2b.br@telefonicati.onmicrosoft.com"
git config --global user.name "devops_b2b-vivocorp"
rem set GIT_PATH="C:\Program Files\Git\bin\git.exe"
set BRANCH = "origin"

cd C:\Siebel_Devops\PROD\limpa

git clone http://$(GITUSER):$(GITPASS)@10.129.178.173/vivocorp/src/src-vivocorp-prod.git

xcopy C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod\scripts C:\Siebel_Devops\PROD\limpa\stage\scripts\ /E /Y
xcopy C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod\pipeline C:\Siebel_Devops\PROD\limpa\stage\pipeline\ /E /Y
xcopy C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod\VERSION C:\Siebel_Devops\PROD\limpa\stage\ /E /Y
xcopy C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod\srf C:\Siebel_Devops\PROD\limpa\stage\ /E /Y

FOR /d %%a IN ("C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod\*") DO IF /i NOT "%%~nxa"==".git" RD /S /Q "%%a"
del /f /q "C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod\*"
 
echo F|xcopy C:\Siebel_Devops\PROD\limpa\stage\scripts C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod\scripts\ /E /Y
echo F|xcopy C:\Siebel_Devops\PROD\limpa\stage\pipeline C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod\pipeline\ /E /Y
echo F|xcopy C:\Siebel_Devops\PROD\limpa\stage\VERSION C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod\ /E /Y
echo F|xcopy C:\Siebel_Devops\PROD\limpa\stage\srf C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod\ /E /Y


cd C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod
 
git add .
git commit -m "Limpa Repositorio"
git push

cd C:\Siebel_Devops\PROD\limpa\
RD /S /Q "C:\Siebel_Devops\PROD\limpa\src-vivocorp-prod"
del /f /q "C:\Siebel_Devops\PROD\limpa\stage\*"

exit 0