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

set BRANCH = "origin"
cd C:\Siebel_Devops\PROD\ambientes\

git clone https://$(GITUSER):$(GITPASS)@dev.azure.com/telefonica-vivo-brasil/VVCP%%20-%%20VIVOCORP/_git/src.src-vivocorp-prod C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod

cd C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod

git describe --abbrev=0 --tags > C:\Siebel_Devops\PROD\ambientes\VERSION.log

cd C:\Siebel_Devops\PROD\ambientes\
set /p VERSION_old=<VERSION.log 

cd C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod

git tag -a %timestamp% -m "Versionamento DevOps"
git push origin %timestamp%

git diff %VERSION_old% %timestamp% --name-only > C:\Siebel_Devops\PROD\ambientes\new_sifs.log

cd C:\Siebel_Devops\PROD\ambientes\
powershell.exe -file "C:\Siebel_Devops\scripts\replace_prod.ps1"

for /f "tokens=*" %%a in (new_sifs.log) do (
echo %%a
echo F|xcopy C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod\"%%a" C:\Siebel_Devops\PROD\temp\"%%a"
echo F|xcopy C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod\"%%a" C:\Siebel_Devops\PPL\temp\"%%a" 
)

cd C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod

cd C:\Siebel_Devops\PROD\ambientes\
RD /S /Q "C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod"

