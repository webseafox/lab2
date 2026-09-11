@echo off

git config --global user.email "dev.crm.b2b.br@telefonicati.onmicrosoft.com"
git config --global user.name "devops_b2b-vivocorp"
rem set GIT_PATH="C:\Program Files\Git\bin\git.exe"
set BRANCH = "origin"
cd C:\Siebel_Devops\PP\ambientes

git clone http://devops_b2b-vivocorp:Vectra123@10.129.178.173/vivocorp/src/src-vivocorp-pp.git C:\Siebel_Devops\PP\ambientes\src-vivocorp-pp

cd C:\Siebel_Devops\PP\ambientes\src-vivocorp-pp

rem git describe --abbrev=0 --tags > C:\Siebel_Devops\ambientes\dev1\VERSION.log
git tag --sort=committerdate | tail -1 > C:\Siebel_Devops\PP\ambientes\VERSION.log

cd C:\Siebel_Devops\PP\ambientes
set /p VERSION_old=<VERSION.log 
rem SET /A VERSION_new=%VERSION_old%+1

cd C:\Siebel_Devops\PP\ambientes\src-vivocorp-pp

git tag -a %VERSION_old%-temp -m "Versionamento DevOps"
git push origin %VERSION_old%-temp

rem git diff %VERSION_old% %VERSION_new% --name-only > C:\Siebel_Devops\ambientes\new_sifs.log
git diff %VERSION_old% %VERSION_old%-temp --name-only > C:\Siebel_Devops\PP\ambientes\new_sifs.log
rem %GIT_PATH% diff 8 9 --name-only > C:\Siebel_Devops\ambientes\new_sifs.log

cd C:\Siebel_Devops\PP\ambientes\
powershell.exe -file "C:\Siebel_Devops\scripts\replace_pp.ps1"

for /f "tokens=*" %%a in (new_sifs.log) do (
echo %%a
echo F|xcopy C:\Siebel_Devops\PP\ambientes\src-vivocorp-pp\"%%a" C:\Siebel_Devops\PP\temp\"%%a"
)

cd C:\Siebel_Devops\PP\ambientes\src-vivocorp-pp
git push --delete origin %VERSION_old%-temp
cd C:\Siebel_Devops\PP\ambientes\
RD /S /Q "C:\Siebel_Devops\PP\ambientes\src-vivocorp-pp"

