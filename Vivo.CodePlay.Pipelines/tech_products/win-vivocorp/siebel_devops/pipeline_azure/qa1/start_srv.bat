@echo off
setlocal enableextensions
ssh supweb@10.129.194.122 "/opt/web/siebel/scripts/administration/bin/devops_start.sh &>/dev/null &"
rem ssh supweb@10.129.194.122 "/opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &"
exit