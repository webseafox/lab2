$sourceDir = "C:\Siebel_Devops\PP\temp\ADM"

$destinationDir = "C:\Siebel_Devops\PP\temp\stage_xml"

if (!(Test-Path -Path $destinationDir)) {
    New-Item -ItemType Directory -Path $destinationDir
}

Get-ChildItem -Path $sourceDir -Recurse -Filter "*.xml" | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $destinationDir
}