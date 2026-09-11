@echo off
echo ==================================================
echo === INICIO DO SCRIPT git_prod.bat ===
echo ==================================================

set datetime=%date:~-4%%date:~3,2%%date:~0,2%%time:~0,2%%time:~3,2%%time:~6,2%
set "timestamp=%datetime: =0%"
echo Timestamp definido: %timestamp%
echo.

echo Configurando Git...
git config --global credential.helper ""
git config --system --unset http.proxy
git config --system --unset https.proxy
git config --system http.proxy http://10.240.58.39:3128
git config --system https.proxy http://10.240.58.39:3128
git config --global user.email "dev.crm.b2b.br@telefonicati.onmicrosoft.com"
git config --global user.name "devops_b2b-vivocorp"
echo Configuração Git concluída
echo.

echo Entrando no diretório de ambientes...
cd /d C:\Siebel_Devops\PROD\ambientes\
echo Diretório atual: %CD%
echo.

echo Clonando repositório...
git clone "https://%GITUSER%:%GITPASS%@dev.azure.com/telefonica-vivo-brasil/VVCP%%20-%%20VIVOCORP/_git/src.src-vivocorp-prod" "C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod"

cd /d C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod
echo Diretório atual após clone: %CD%
git remote set-url origin "https://%GITUSER%:%GITPASS%@dev.azure.com/telefonica-vivo-brasil/VVCP%%20-%%20VIVOCORP/_git/src.src-vivocorp-prod"
echo Clone e configuração remota concluídos
echo.

echo Obtendo última tag do Git...
git fetch --tags
git describe --tags --abbrev=0 --always > "C:\Siebel_Devops\PROD\ambientes\VERSION.log"
set /p VERSION_old=<C:\Siebel_Devops\PROD\ambientes\VERSION.log
echo Última tag salva em VERSION.log
echo Versão antiga: %VERSION_old%
echo.

echo Criando nova tag: %timestamp%
git tag -a %timestamp% -m "Versionamento DevOps"
git push origin %timestamp%
echo Nova tag enviada ao repositório
echo.

echo Gerando lista de arquivos modificados entre %VERSION_old% e %timestamp%...
git diff %VERSION_old% %timestamp% --name-only > "C:\Siebel_Devops\PROD\ambientes\new_sifs.log"
echo Arquivos modificados salvos em new_sifs.log
echo.

cd /d C:\Siebel_Devops\PROD\ambientes\
echo Executando replace_prod.ps1...
powershell.exe -file "C:\Siebel_Devops\scripts\replace_prod.ps1"
echo Script PowerShell concluído
echo.

echo Copiando arquivos modificados...
for /f "usebackq tokens=*" %%a in ("C:\Siebel_Devops\PROD\ambientes\new_sifs.log") do (
    echo Copiando %%a para temp e PPL/temp...
    echo F|xcopy "C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod\%%a" "C:\Siebel_Devops\PROD\temp\%%a"
    echo F|xcopy "C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod\%%a" "C:\Siebel_Devops\PPL\temp\%%a"
)
echo Copia de arquivos concluída
echo.

cd /d C:\Siebel_Devops\PROD\ambientes\
RD /S /Q "C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod"
echo Repositório clonado removido
echo.

echo ==================================================
echo === FIM DO SCRIPT git_prod.bat ===
echo ==================================================