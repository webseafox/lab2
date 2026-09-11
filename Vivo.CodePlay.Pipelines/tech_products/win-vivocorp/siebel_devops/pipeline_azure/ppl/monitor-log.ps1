param([string]$logPath = "C:\Siebel_Devops\log")

Start-Sleep -Seconds 180

if (-not (Test-Path -Path $logPath)) {
    Write-Output "Por favor, forneça um caminho de log válido."
    exit 1
}

Write-Output "Caminho dos logs: $logPath"

function Get-LatestLog {
    return Get-ChildItem -Path $logPath -Filter "Compile_PPL_*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
}

$latestFile = Get-LatestLog

if (-not $latestFile) {
    Write-Output "Nenhum arquivo de log encontrado."
    exit 1
}

Write-Output "Monitorando o log: $($latestFile.FullName)"

while ($true) {
    $newSize = (Get-Item $latestFile.FullName).Length
    if (Select-String -Path $latestFile.FullName -Pattern "Fim Compi" -Quiet) {
        Write-Output "Frase 'Fim Compilacao' encontrada no log. Finalizando com sucesso."
        exit 0
    } else {
        Write-Output "Compilando..."
    }
    Start-Sleep -Seconds 20
}
