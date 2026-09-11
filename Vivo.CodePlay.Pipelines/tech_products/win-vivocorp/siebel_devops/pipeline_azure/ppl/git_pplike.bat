@echo off

set datetime=%date:~-4%%date:~3,2%%date:~0,2%%time:~0,2%%time:~3,2%%time:~6,2%
set "timestamp=%datetime: =0%"
rem echo %timestamp%

git config --global user.email "dev.crm.b2b.br@telefonicati.onmicrosoft.com"
git config --global user.name "devops_b2b-vivocorp"

set pwd = "n2@WuWkD2"
set BRANCH = "origin"
cd C:\Siebel_Devops\PPL\ambientes\

git clone http://$(GITUSER):$(GITPASS)@10.129.178.173/vivocorp/src/src-vivocorp-prod.git C:\Siebel_Devops\PPL\ambientes\src-vivocorp-pplike

git@10.129.178.173:vivocorp/src/src-vivocorp-pplike.git

cd C:\Siebel_Devops\PPL\ambientes\src-vivocorp-pplike

git describe --abbrev=0 --tags > C:\Siebel_Devops\PPL\ambientes\VERSION.log

cd C:\Siebel_Devops\PPL\ambientes\
set /p VERSION_old=<VERSION.log 

cd C:\Siebel_Devops\PPL\ambientes\src-vivocorp-pplike

git tag -a %timestamp% -m "Versionamento DevOps"
git push origin %timestamp%

git diff %VERSION_old% %timestamp% --name-only > C:\Siebel_Devops\PPL\ambientes\new_sifs.log

cd C:\Siebel_Devops\PPL\ambientes\
powershell.exe -file "C:\Siebel_Devops\scripts\replace_ppl.ps1"

for /f "tokens=*" %%a in (new_sifs.log) do (
echo %%a
echo F|xcopy C:\Siebel_Devops\PPL\ambientes\src-vivocorp-pplike\"%%a" C:\Siebel_Devops\PPL\temp\"%%a"
)

cd C:\Siebel_Devops\PPL\ambientes\src-vivocorp-pplike

cd C:\Siebel_Devops\PPL\ambientes\
RD /S /Q "C:\Siebel_Devops\PPL\ambientes\src-vivocorp-pplike"

