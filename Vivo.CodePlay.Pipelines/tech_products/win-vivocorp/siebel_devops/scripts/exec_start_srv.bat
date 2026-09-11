@echo off
setlocal enableextensions
ssh supweb@10.129.170.69 "/opt/web/siebel/scripts/administration/bin/devops_start.sh &>/dev/null &"
echo "euu"
pause