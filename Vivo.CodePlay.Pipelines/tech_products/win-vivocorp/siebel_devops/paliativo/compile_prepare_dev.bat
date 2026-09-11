@echo off

set datetime=%date:~-4%%date:~3,2%%date:~0,2%%time:~0,2%%time:~3,2%
%time:~6,2%
set "timestamp=%datetime: =0%"
rem echo %timestamp%

cd C:\Siebel_Devops\ambientes\dev1\src-vivocorp-dev1

git describe --abbrev=0 --tags > C:\Siebel_Devops\ambientes\dev1\VERSION.log
rem git tag --sort=committerdate | tail -1 > C:\Siebel_Devops\ambientes\dev1\VERSION.log

cd C:\Siebel_Devops\ambientes\dev1\
set /p VERSION_old=<VERSION.log 
rem set /p VERSION_new=%timestamp%

cd C:\Siebel_Devops\ambientes\dev1\src-vivocorp-dev1

git tag -a %timestamp% -m "Versionamento DevOps"
git push origin %timestamp%

rem git diff %VERSION_old% %V
ERSION_new% --name-only > C:\Siebel_Devops\ambientes\new_sifs.log
git diff %VERSION_old% %timestamp% --name-only > C:\Siebel_Devops\ambientes\new_sifs.log
rem %GIT_PATH% diff 8 9 --name-only > C:\Siebel_Devops\ambientes\new_sifs.log

cd C:\Siebel_Devops\ambientes\
powershell.exe -file "C:\Siebel_Devops\scripts\replace_dev1.ps1"

for /f "tokens=*" %%a in (new_sifs.log) do (
echo %%a
echo F|xcopy C:\Siebel_Devops\ambientes\dev1\src-vivocorp-dev1\"%%a" C:\Siebel_Devops\temp\"%%a"
)

cd C:\Siebel_Devops\ambientes\dev1\src-vivocorp-dev1
rem git push --delete origin %VERSION_old%-temp
cd C:\Siebel_Devops\ambientes\dev1
RD /S /Q "C:\Siebel_Devops\ambientes\dev1\src-vivocorp-dev1"


pause
