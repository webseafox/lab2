@echo off
setlocal enableextensions
ssh supweb@10.129.178.54 "/opt/web/siebel/scripts/administration/bin/devops_start.sh &>/dev/null &"
exit