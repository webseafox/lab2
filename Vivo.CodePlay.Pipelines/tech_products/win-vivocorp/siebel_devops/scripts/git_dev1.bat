@echo on

rem set GIT_PATH="C:\Program Files\Git\bin\git.exe"
set BRANCH = "origin"
cd C:\Siebel_Devops\ambientes\dev1

git clone http://$(GITUSER):$(GITPASS)@10.129.178.173/vivocorp/src/src-vivocorp-dev1.git C:\Siebel_Devops\ambientes\dev1\src-vivocorp-dev1

cd C:\Siebel_Devops\ambientes\dev1\src-vivocorp-dev1

rem git describe --abbrev=0 --tags > C:\Siebel_Devops\ambientes\dev1\VERSION.log
git tag --sort=committerdate | tail -1 > C:\Siebel_Devops\ambientes\dev1\VERSION.log

cd C:\Siebel_Devops\ambientes\dev1\
set /p VERSION_old=<VERSION.log 
rem SET /A VERSION_new=%VERSION_old%+1

cd C:\Siebel_Devops\ambientes\dev1\src-vivocorp-dev1

git tag -a temp -m "Versionamento DevOps"
git push origin temp


rem git diff %VERSION_old% %VERSION_new% --name-only > C:\Siebel_Devops\ambientes\new_sifs.log
git diff %VERSION_old% temp --name-only > C:\Siebel_Devops\ambientes\new_sifs.log
rem %GIT_PATH% diff 8 9 --name-only > C:\Siebel_Devops\ambientes\new_sifs.log

cd C:\Siebel_Devops\ambientes\
powershell.exe -file "C:\Siebel_Devops\scripts\replace_dev1.ps1"

for /f "tokens=*" %%a in (new_sifs.log) do (
echo %%a
echo F|xcopy C:\Siebel_Devops\ambientes\dev1\src-vivocorp-dev1\%%a C:\Siebel_Devops\temp\%%a
)

cd C:\Siebel_Devops\ambientes\dev1\src-vivocorp-dev1
git push --delete origin temp
RD /S /Q "C:\Siebel_Devops\ambientes\dev1\src-vivocorp-dev1"


