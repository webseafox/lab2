@echo off
setlocal enabledelayedexpansion

echo ==================================================
echo === INICIO DO SCRIPT active_task_az.bat ===
echo ==================================================

echo Script: active_task_az.bat
echo Propósito: Ativar tasks Siebel
echo Data/Hora: %date% %time%
echo.
echo Iniciando processo de ativação de tasks...
echo.

set successCount=0
set failCount=0

echo Ativando tasks Siebel...
echo.

echo Conectando em pcpweb@10.238.7.12...
echo Executando: /home/pcpweb/active_task.sh
ssh -i C:\id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes pcpweb@10.238.7.12 /home/pcpweb/active_task.sh >nul 2>&1
set "exitCode=!ERRORLEVEL!"
if "!exitCode!"=="0" (
    echo Script active_task.sh executado com sucesso
    echo Tasks ativadas no servidor
    set /A successCount+=1
) else (
    echo ERRO: Falha ao executar active_task.sh - ERRORLEVEL: !exitCode!
    echo ERRO: Tasks podem nao estar ativadas
    set /A failCount+=1
)
echo.

echo ==================================================
echo RESUMO DA ATIVACAO DE TASKS
echo ==================================================
echo Total de operacoes: 1
echo Operacoes bem-sucedidas: !successCount!
echo Operacoes com falha: !failCount!
echo ==================================================
echo.

if !failCount! GTR 0 (
    echo AVISO: Processo concluído com falhas
    echo AVISO: Tasks podem não estar ativas
    echo AVISO: Verifique manualmente o status das tasks
    echo AVISO: Consulte logs em /home/pcpweb/ no servidor
    echo.
    echo Script finalizado com código de erro
    echo ==================================================
    echo === FIM DO SCRIPT active_task_az.bat ===
    echo ==================================================
    exit /B 1
) else (
    echo SUCESSO: Script active_task.sh executado com sucesso
    echo Tasks Siebel foram ativadas
    echo Tarefas agendadas devem estar operacionais
    echo Recomendação: Validar tasks no Siebel Server Manager
    echo.
    echo Script finalizado com sucesso
    echo ==================================================
    echo === FIM DO SCRIPT active_task_az.bat ===
    echo ==================================================
    exit /B 0
)
