@echo off
setlocal enableextensions
ssh supweb@10.129.170.12 "/opt/web/siebel/scripts/administration/bin/devops_start.sh &>/dev/null &"
exit