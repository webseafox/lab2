# C:\Siebel_Devops\DEV1\temp
# C:\Siebel_Devops\temp

$sourceDir = "C:\Siebel_Devops\paliativo\temp\ADM"

$destinationDir = "C:\Siebel_Devops\DEV1\temp"

if (Test-Path -Path $destinationDir) {
    Write-Output "Conteúdo de $destinationDir antes da execução:"
    Get-ChildItem -Path $destinationDir | ForEach-Object { $_.FullName }
} else {
    Write-Output "O diretório $destinationDir não existe."
}

if (!(Test-Path -Path $destinationDir)) {
    New-Item -ItemType Directory -Path $destinationDir
}

Get-ChildItem -Path $sourceDir -Recurse -Filter "*.xml" | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $destinationDir
}