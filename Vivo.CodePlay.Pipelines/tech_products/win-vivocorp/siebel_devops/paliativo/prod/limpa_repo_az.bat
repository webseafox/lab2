@echo off

echo ==================================================
echo === INICIO DO SCRIPT limpa_repo_az.bat ===
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
set GIT_PATH="C:\Program Files\Git\bin\git.exe"
set BRANCH=origin
echo Configuração Git concluída
echo.

echo Entrando no diretório de limpeza...
cd /d C:\Siebel_Devops\PROD\limpa
echo Diretório atual: %CD%
echo.

echo Clonando repositório...
git clone "https://%GITUSER%:%GITPASS%@dev.azure.com/telefonica-vivo-brasil/VVCP%%20-%%20VIVOCORP/_git/src.src-vivocorp-prod" "C:\Siebel_Devops\PROD\limpa\src.src-vivocorp-prod"

:: Entrar no repo clonado
cd /d C:\Siebel_Devops\PROD\limpa\src.src-vivocorp-prod
echo Diretório atual após clone: %CD%
git remote set-url origin "https://%GITUSER%:%GITPASS%@dev.azure.com/telefonica-vivo-brasil/VVCP%%20-%%20VIVOCORP/_git/src.src-vivocorp-prod"
echo Clone e configuração remota concluídos
echo.

echo Copiando arquivos para staging...
echo Copiando pasta .azuredevops...
xcopy C:\Siebel_Devops\PROD\limpa\src.src-vivocorp-prod\.azuredevops C:\Siebel_Devops\PROD\limpa\stage\.azuredevops\ /E /Y > nul 2>&1
echo Copia para staging concluída
echo.

echo Limpando repositório (exceto pasta .git)...
FOR /d %%a IN ("C:\Siebel_Devops\PROD\limpa\src.src-vivocorp-prod\*") DO IF /i NOT "%%~nxa"==".git" (
    echo Removendo diretório: %%~nxa
    RD /S /Q "%%a"
)
echo Removendo arquivos...
del /f /q "C:\Siebel_Devops\PROD\limpa\src.src-vivocorp-prod\*" > nul 2>&1
echo Limpeza concluída
echo.

echo Copiando arquivos do staging de volta para o repositório...
echo Copiando pasta .azuredevops...
echo F|xcopy C:\Siebel_Devops\PROD\limpa\stage\.azuredevops C:\Siebel_Devops\PROD\limpa\src.src-vivocorp-prod\.azuredevops\ /E /Y > nul 2>&1
echo Copia do staging concluída
echo.

echo Entrando no diretório do repositório...
cd C:\Siebel_Devops\PROD\limpa\src.src-vivocorp-prod
echo Diretório atual: %CD%
 
echo Adicionando arquivos ao Git...
git add .
echo Arquivos adicionados ao staging do Git

echo Criando commit...
git commit -m "Limpa Repositorio" > "C:\Siebel_Devops\PROD\limpa\commit.log" 2>&1
echo Commit criado

echo Enviando alterações para o repositório remoto...
git push
echo Push concluído - Repositório limpo enviado ao Azure DevOps
echo.

echo Retornando ao diretório de limpeza...
cd /d C:\Siebel_Devops\PROD\limpa\
echo Diretório atual: %CD%

echo Removendo diretório do repositório clonado...
RD /S /Q "C:\Siebel_Devops\PROD\limpa\src.src-vivocorp-prod"
echo Diretório do repositório removido

echo Limpando arquivos de staging...
del /f /q "C:\Siebel_Devops\PROD\limpa\stage\*" > nul 2>&1
echo Arquivos de staging limpos
echo.

echo ==================================================
echo === FIM DO SCRIPT limpa_repo_az.bat ===
echo ==================================================
exit 0