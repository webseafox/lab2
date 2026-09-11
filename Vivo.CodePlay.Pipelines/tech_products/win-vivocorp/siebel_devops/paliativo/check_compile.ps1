git config --global user.email "dev.crm.b2b.br@telefonica.com"
git config --global user.name "devops_b2b-vivocorp"

$tempPath = "C:\Siebel_Devops\temp\nao_compilar.txt"
if (Test-Path -Path $tempPath) {
    Remove-Item -Path "C:\Siebel_Devops\temp\*" -Force -Recurse
} else {
    Start-Process -FilePath "C:\Siebel\8.1\Tools_1\BIN\siebdev.exe" `
                  -ArgumentList "/c C:\Siebel\8.1\Tools_1\BIN\ENU\DEV2.cfg", "/s DEV1", "/u $(siebeluser)", "/p $(siebelpass)", "/tl PTB", "/bc Siebel Repository", "C:\Siebel_Devops\srf\siebel_sia_new3.srf" `
                  -NoNewWindow -Wait
}

exit 0
