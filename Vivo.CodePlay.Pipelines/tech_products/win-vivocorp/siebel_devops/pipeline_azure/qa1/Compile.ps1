# Define o caminho base dos logs
$logPath = "C:\Siebel_Devops\log"

# Captura a data e hora atuais para criar o nome do log
$timestamp = Get-Date -Format "yyyy_MM_dd_HH_mm"
$logFile = Join-Path -Path $logPath -ChildPath "Compile_QA1_$timestamp.log"

# Início da compilação
Add-Content -Path $logFile -Value "Inicio Compilacao"
Add-Content -Path $logFile -Value $timestamp

# Caminho do arquivo para verificar
$tempFile = "C:\Siebel_Devops\temp\nao_compilar.txt"

# Verifica se o arquivo nao_compilar.txt existe
if (Test-Path -Path $tempFile) {
    Add-Content -Path $logFile -Value "Nao existem objetos para serem compilados."
    Remove-Item -Path "C:\Siebel_Devops\temp\*" -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Add-Content -Path $logFile -Value "Existem objetos para serem compilados."
    # Executa o comando de compilação em segundo plano
    $process = Start-Process -FilePath "C:\Siebel\8.1\Tools_1\BIN\siebdev.exe" `
        -ArgumentList @(
            '/c "C:\Siebel\8.1\Tools_1\BIN\ENU\QA1.cfg"',
            '/s QA1',
            '/u $(siebeluser)',
            '/p $(siebelpass)',
            '/tl PTB',
            '/bc "Siebel Repository"',
            'C:\Siebel_Devops\QA1\srf\siebel_sia_new.srf'
        ) `
        -PassThru `
        -NoNewWindow

    # Monitora o processo até que finalize
    Write-Host "Aguardando conclusão da compilacao..."
    while (-not $process.HasExited) {
        Start-Sleep -Seconds 5
    }

}

# Captura a data e hora finais após o processo
$endTimestamp = Get-Date -Format "yyyy_MM_dd_HH_mm"

# Fim da compilação
Add-Content -Path $logFile -Value "Fim Compilacao"
Add-Content -Path $logFile -Value $endTimestamp

# Log criado com sucesso
Write-Host "Log criado com sucesso: $logFile"
