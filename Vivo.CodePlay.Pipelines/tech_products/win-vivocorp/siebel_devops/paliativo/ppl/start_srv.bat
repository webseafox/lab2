@echo off
setlocal enableextensions
ssh supweb@10.129.173.29 "/opt/web/siebel/scripts/administration/bin/devops_start.sh &>/dev/null &"
exit