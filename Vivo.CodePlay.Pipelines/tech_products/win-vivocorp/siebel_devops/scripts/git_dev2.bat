@echo on

set GIT_PATH="C:\Program Files\Git\bin\git.exe"
set BRANCH = "origin"
cd C:\Siebel_Devops\DEV2\ambientes\

%GIT_PATH% clone http://$(GITUSER):$(GITPASS)@10.129.178.173/vivocorp/src/src-vivocorp-dev2.git

cd C:\Siebel_Devops\DEV2\ambientes\src-vivocorp-dev2

%GIT_PATH% describe --abbrev=0 --tags > C:\Siebel_Devops\DEV2\ambientes\VERSION.log

cd C:\Siebel_Devops\DEV2\ambientes\
set /p VERSION_old=<VERSION.log 
SET /A VERSION_new=%VERSION_old%+1

cd C:\Siebel_Devops\DEV2\ambientes\src-vivocorp-dev2

%GIT_PATH% tag -a %VERSION_new% -m "Versionamento DevOps"
%GIT_PATH% push origin %VERSION_new%


%GIT_PATH% diff %VERSION_old% %VERSION_new% --name-only > C:\Siebel_Devops\DEV2\ambientes\new_sifs.log
rem %GIT_PATH% diff 8 9 --name-only > C:\Siebel_Devops\ambientes\new_sifs.log

cd C:\Siebel_Devops\DEV2\ambientes

for /f "tokens=*" %%a in (new_sifs.log) do (
echo %%a
xcopy C:\Siebel_Devops\DEV2\ambientes\src-vivocorp-dev2\%%a C:\Siebel_Devops\DEV2\temp\
)

RD /S /Q "C:\Siebel_Devops\DEV2\ambientes\src-vivocorp-dev2"


