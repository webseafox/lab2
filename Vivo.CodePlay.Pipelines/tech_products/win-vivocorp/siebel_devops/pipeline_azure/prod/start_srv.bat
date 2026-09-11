@echo off
setlocal enableextensions

rem Stop 20 a 23
ssh pcpweb@10.238.6.35 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.12 "sleep 260"
ssh pcpweb@10.238.6.36 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.12 "sleep 260"
ssh pcpweb@10.238.6.37 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.12 "sleep 260"
ssh pcpweb@10.238.6.38 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.12 "sleep 260"
rem Stop 1 e 2
ssh pcpweb@10.238.7.12 "sudo -u supweb /opt/web/siebel/siebel811/siebelsrv1/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.12 "sleep 260"
ssh pcpweb@10.238.7.13 "sudo -u supweb /opt/web/siebel/siebel811/siebelsrv2/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.12 "sleep 260"

rem Start 3 a 8
ssh pcpweb@10.238.5.32 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.12 "sleep 260"
ssh pcpweb@10.238.5.33 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.12 "sleep 260"
ssh pcpweb@10.238.5.34 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.12 "sleep 260"
ssh pcpweb@10.238.5.35 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.12 "sleep 260"
ssh pcpweb@10.238.5.36 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.12 "sleep 260"
ssh pcpweb@10.238.5.37 "sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &"


rem SDANGELIS [Adicionados novos servidores] 20240620
rem Server 24 a 27
ssh pcpweb@10.238.6.67"sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.12 "sleep 260"
ssh pcpweb@10.238.6.68"sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.12 "sleep 260"
ssh pcpweb@10.238.6.65"sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.12 "sleep 260"
ssh pcpweb@10.238.6.66"sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/start_srv.sh &>/dev/null &"
ssh pcpweb@10.238.7.12 "sleep 260"

exit 0