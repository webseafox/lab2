@echo off

set datetime=%date:~-4%%date:~3,2%%date:~0,2%%time:~0,2%%time:~3,2%%time:~6,2%
set "timestamp=%datetime: =0%"
rem echo %timestamp%

git config --system --unset http.proxy
git config --system --unset https.proxy
git config --system http.proxy http://10.240.58.39:3128
git config --system https.proxy http://10.240.58.39:3128

git config --global user.email "dev.crm.b2b.br@telefonicati.onmicrosoft.com"
git config --global user.name "devops_b2b-vivocorp"
rem set GIT_PATH="C:\Program Files\Git\bin\git.exe"
set BRANCH = "origin"
cd C:\Siebel_Devops\QA2

git clone https://$(GITUSER):$(GITPASS)@dev.azure.com/telefonica-vivo-brasil/VVCP%%20-%%20VIVOCORP/_git/src.src-vivocorp-qa2 C:\Siebel_Devops\QA2\ambientes\src-vivocorp-qa2

cd C:\Siebel_Devops\QA2\ambientes\src-vivocorp-qa2

git describe --abbrev=0 --tags > C:\Siebel_Devops\QA2\ambientes\VERSION.log
rem git tag --sort=committerdate | tail -1 > C:\Siebel_Devops\QA2\ambientes\VERSION.log

cd C:\Siebel_Devops\QA2\ambientes\
set /p VERSION_old=<VERSION.log 
rem set /p VERSION_new=%timestamp%

cd C:\Siebel_Devops\QA2\ambientes\src-vivocorp-qa2

git tag -a %timestamp% -m "Versionamento DevOps"
git push origin %timestamp%

rem git diff %VERSION_old% %VERSION_new% --name-only > C:\Siebel_Devops\ambientes\new_sifs.log
git diff %VERSION_old% %timestamp% --name-only > C:\Siebel_Devops\QA2\ambientes\new_sifs.log
rem %GIT_PATH% diff 8 9 --name-only > C:\Siebel_Devops\ambientes\new_sifs.log

cd C:\Siebel_Devops\QA2\ambientes\
powershell.exe -file "C:\Siebel_Devops\scripts\replace_qa2.ps1"

for /f "tokens=*" %%a in (new_sifs.log) do (
echo %%a
echo F|xcopy C:\Siebel_Devops\QA2\ambientes\src-vivocorp-qa2\"%%a" C:\Siebel_Devops\QA2\temp\"%%a"
)

cd C:\Siebel_Devops\QA2\ambientes\src-vivocorp-qa2
rem git push --delete origin %VERSION_old%-temp
cd C:\Siebel_Devops\QA2\ambientes\
RD /S /Q "C:\Siebel_Devops\QA2\ambientes\src-vivocorp-qa2"


