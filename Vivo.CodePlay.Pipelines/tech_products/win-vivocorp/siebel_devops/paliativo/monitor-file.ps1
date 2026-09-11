$filePath = 'C:\Siebel_Devops\srf\siebel_sia_new2.srf'
$checkCount = 0
$maxNoChange = 4
$lastSize = 0

Write-Host "Monitoring file: $filePath"

if (!(Test-Path -Path $filePath)) {
    Write-Host "File does not exist."
    exit 1
}

while ($checkCount -lt $maxNoChange) {
    $currentSize = (Get-Item $filePath).Length

    if ($currentSize -ne $lastSize) {
        Write-Host "Arquivo sendo escrito: $currentSize bytes"
        $checkCount = 0
    } else {
        Write-Host "Nenhum processo escrevendo no arquivo no momento..."
        $checkCount++
    }

    $lastSize = $currentSize
    Start-Sleep -Seconds 80
}

Write-Host "Não foi detectada alteração no arquivo após $maxNoChange verificações consecutivas. Considerando como finalizado o processo de compilação."
exit 0