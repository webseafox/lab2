$sourcePath = "C:\Siebel_Devops\ambientes\dev1\src-vivocorp-dev1\"
$destinationPath = "C:\Siebel_Devops\temp\"
$logFile = "C:\Siebel_Devops\ambientes\dev1\new_sifs.log"

if (Test-Path $logFile) {
    Get-Content $logFile | ForEach-Object {
        $fileName = $_.Trim()
        Write-Output "Processando arquivo: $fileName"
        $sourceFile = Join-Path $sourcePath $fileName
        $destinationFile = Join-Path $destinationPath $fileName
        if (Test-Path $sourceFile) {
            Copy-Item -Path $sourceFile -Destination $destinationFile -Force
            Write-Output "Arquivo copiado: $fileName"
        } else {
            Write-Output "Arquivo não encontrado: $fileName"
        }
    }
} else {
    Write-Output "Arquivo de log não encontrado: $logFile"
}
