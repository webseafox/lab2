# Define o caminho base dos logs
$logPath = "C:\Siebel_Devops\log"

# Captura a data e hora atuais para criar o nome do log
$timestamp = Get-Date -Format "yyyy_MM_dd_HH_mm"
$logFile = Join-Path -Path $logPath -ChildPath "Compile_$timestamp.log"

# Início da compilação
Add-Content -Path $logFile -Value "Inicio Compilacao"
Add-Content -Path $logFile -Value $timestamp

# Simula um processo longo (600 segundos = 10 minutos)
Start-Sleep -Seconds 600

# Captura a data e hora finais após o processo
$endTimestamp = Get-Date -Format "yyyy_MM_dd_HH_mm"

# Fim da compilação
Add-Content -Path $logFile -Value "Fim Compilacao"
Add-Content -Path $logFile -Value $endTimestamp

# Log criado com sucesso
Write-Host "Log criado com sucesso: $logFile"
