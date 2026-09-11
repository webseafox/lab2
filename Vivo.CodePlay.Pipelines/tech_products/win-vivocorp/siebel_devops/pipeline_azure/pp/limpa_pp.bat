@echo on

set datetime=%date:~-4%_%date:~3,2%_%date:~0,2%_%time:~0,2%_%time:~3,2%_%time:~6,2%
set "timestamp=%datetime: =0%"
echo %timestamp%


git config --global user.email "dev.crm.b2b.br@telefonicati.onmicrosoft.com"
git config --global user.name "devops_b2b-vivocorp"
rem set GIT_PATH="C:\Program Files\Git\bin\git.exe"
set BRANCH = "origin"

cd C:\Siebel_Devops\PROD\limpa

git clone http://$(GITUSER):$(GITPASS)@10.129.178.173/vivocorp/src/src-vivocorp-pp.git


cd C:\Siebel_Devops\PROD\limpa\src-vivocorp-pp

git tag -a release-%timestamp% -m "Versionamento DevOps"
git push origin release-%timestamp%

xcopy C:\Siebel_Devops\PROD\limpa\src-vivocorp-pp\scripts C:\Siebel_Devops\PROD\limpa\stage\scripts\ /E /Y
xcopy C:\Siebel_Devops\PROD\limpa\src-vivocorp-pp\pipeline C:\Siebel_Devops\PROD\limpa\stage\pipeline\ /E /Y
xcopy C:\Siebel_Devops\PROD\limpa\src-vivocorp-pp\VERSION C:\Siebel_Devops\PROD\limpa\stage\ /E /Y
xcopy C:\Siebel_Devops\PROD\limpa\src-vivocorp-pp\srf C:\Siebel_Devops\PROD\limpa\stage\ /E /Y

FOR /d %%a IN ("C:\Siebel_Devops\PROD\limpa\src-vivocorp-pp\*") DO IF /i NOT "%%~nxa"==".git" RD /S /Q "%%a"
del /f /q "C:\Siebel_Devops\PROD\limpa\src-vivocorp-pp\*"
 
echo F|xcopy C:\Siebel_Devops\PROD\limpa\stage\scripts C:\Siebel_Devops\PROD\limpa\src-vivocorp-pp\scripts\ /E /Y
echo F|xcopy C:\Siebel_Devops\PROD\limpa\stage\pipeline C:\Siebel_Devops\PROD\limpa\src-vivocorp-pp\pipeline\ /E /Y
echo F|xcopy C:\Siebel_Devops\PROD\limpa\stage\VERSION C:\Siebel_Devops\PROD\limpa\src-vivocorp-pp\ /E /Y
echo F|xcopy C:\Siebel_Devops\PROD\limpa\stage\srf C:\Siebel_Devops\PROD\limpa\src-vivocorp-pp\ /E /Y

cd C:\Siebel_Devops\PROD\limpa\src-vivocorp-pp
 
git add .
git commit -m "Limpa Repositório"
git push

cd C:\Siebel_Devops\PROD\limpa\
RD /S /Q "C:\Siebel_Devops\PROD\limpa\src-vivocorp-pp"
del /f /q "C:\Siebel_Devops\PROD\limpa\stage\*"
FOR /d %%a IN ("C:\Siebel_Devops\PROD\limpa\stage\*") DO IF /i NOT "%%~nxa"==".git" RD /S /Q "%%a"

exit 0