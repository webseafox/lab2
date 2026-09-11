@echo off
setlocal enabledelayedexpansion

echo ==================================================
echo === INICIO DO SCRIPT active_rs_az.bat ===
echo ==================================================

echo Script: active_rs_az.bat
echo Propósito: Ativar rulesets Siebel
echo Data/Hora: %date% %time%
echo.
echo Iniciando processo de ativação de rulesets...
echo.

set successCount=0
set failCount=0

echo Ativando rulesets Siebel...
echo.

echo Conectando em pcpweb@10.238.7.12...
echo Executando: /home/pcpweb/active_ruleset.sh
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.7.12 /home/pcpweb/active_ruleset.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Script active_ruleset.sh executado com sucesso
    echo Rulesets ativados no servidor
    set /A successCount+=1
) else (
    echo ERRO: Falha ao executar active_ruleset.sh - ERRORLEVEL: !exitCode!
    echo ERRO: Rulesets podem nao estar ativados
    set /A failCount+=1
)
echo.

echo ==================================================
echo RESUMO DA ATIVACAO DE RULESETS
echo ==================================================
echo Total de operacoes: 1
echo Operacoes bem-sucedidas: !successCount!
echo Operacoes com falha: !failCount!
echo ==================================================
echo.

if !failCount! GTR 0 (
    echo AVISO: Processo concluído com falhas
    echo AVISO: Rulesets podem não estar ativos
    echo AVISO: Verifique manualmente o status dos rulesets
    echo AVISO: Consulte logs em /home/pcpweb/ no servidor
    echo.
    echo Script finalizado com código de erro
    echo ==================================================
    echo === FIM DO SCRIPT active_rs_az.bat ===
    echo ==================================================
    exit /B 1
) else (
    echo SUCESSO: Script active_ruleset.sh executado com sucesso
    echo Rulesets Siebel foram ativados
    echo Regras de negócio devem estar operacionais
    echo Recomendação: Validar rulesets na Aplicação Siebel
    echo.
    echo Script finalizado com sucesso
    echo ==================================================
    echo === FIM DO SCRIPT active_rs_az.bat ===
    echo ==================================================
    exit /B 0
)
