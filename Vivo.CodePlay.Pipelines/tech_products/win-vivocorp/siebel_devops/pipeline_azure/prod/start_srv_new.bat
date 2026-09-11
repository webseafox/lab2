@echo off
setlocal enableextensions

rem starting server 1 e 2
ssh pcpweb@10.238.7.12 "sudo -u supweb /opt/web/siebel/siebel811/siebelsrv1/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.12 "sleep 260"
ssh pcpweb@10.238.7.13 "sudo -u supweb /opt/web/siebel/siebel811/siebelsrv2/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.13 "sleep 260"

exit 0