@echo on

set datetime=%date:~-4%_%date:~3,2%_%date:~0,2%_%time:~0,2%_%time:~3,2%_%time:~6,2%
set "timestamp=%datetime: =0%"
echo %timestamp%


git config --global user.email "dev.crm.b2b.br@telefonicati.onmicrosoft.com"
git config --global user.name "devops_b2b-vivocorp"
rem set GIT_PATH="C:\Program Files\Git\bin\git.exe"
set BRANCH = "origin"

cd C:\Siebel_Devops\HOTFIX\limpa

git clone https://$(GITUSER):$(GITPASS)@dev.azure.com/telefonica-vivo-brasil/VVCP%%20-%%20VIVOCORP/_git/src.src-vivocorp-hotfix


cd C:\Siebel_Devops\HOTFIX\limpa\src.src-vivocorp-hotfix

git tag -a release-%timestamp% -m "Versionamento DevOps"
git push origin release-%timestamp%

FOR /d %%a IN ("C:\Siebel_Devops\HOTFIX\limpa\src.src-vivocorp-hotfix\*") DO IF /i NOT "%%~nxa"==".git" RD /S /Q "%%a"
del /f /q "C:\Siebel_Devops\HOTFIX\limpa\src.src-vivocorp-hotfix\*"
 

cd C:\Siebel_Devops\HOTFIX\limpa\src.src-vivocorp-hotfix
 
git add .
git commit -m "Limpa Repositorio"
git push

cd C:\Siebel_Devops\HOTFIX\limpa\
RD /S /Q "C:\Siebel_Devops\HOTFIX\limpa\src.src-vivocorp-hotfix"
del /f /q "C:\Siebel_Devops\HOTFIX\limpa\stage\*"
FOR /d %%a IN ("C:\Siebel_Devops\HOTFIX\limpa\stage\*") DO IF /i NOT "%%~nxa"==".git" RD /S /Q "%%a"

exit 0