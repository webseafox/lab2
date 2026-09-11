rem Stop 20 a 23
ssh pcpweb@10.238.6.35 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log &"
ssh pcpweb@10.238.6.36 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log &"
ssh pcpweb@10.238.6.37 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log &"
ssh pcpweb@10.238.6.38 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log &"

rem Stop 1 e 2
ssh pcpweb@10.238.7.12 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebelsrv1/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log &"
rem ssh pcpweb@10.238.7.12 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebelsrv2/siebsrvr/scripts/stop_srv.sh > /opt/web/siebel/siebel811/siebelsrv2/siebsrvr/scripts/stop_devops.log &"
ssh pcpweb@10.238.7.13 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebelsrv2/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log &"
rem ssh pcpweb@10.238.7.13 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebelsrv2/siebsrvr/scripts/stop_srv.sh > /opt/web/siebel/siebel811/siebelsrv2/siebsrvr/scripts/stop_devops.log &"

rem Start 3 a 8
ssh pcpweb@10.238.5.32 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log &"
ssh pcpweb@10.238.5.33 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log &"
ssh pcpweb@10.238.5.34 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log &"
ssh pcpweb@10.238.5.35 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log &"
ssh pcpweb@10.238.5.36 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log &"
ssh pcpweb@10.238.5.37 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log &"

rem SDANGELIS [Adicionados novos servidores] 20240620
rem Server 24 a 27

ssh pcpweb@10.238.7.12 /home/pcpweb/stop_new_servers.sh

rem ssh pcpweb@10.238.6.67 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log &"
rem ssh pcpweb@10.238.6.68 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log &"
rem ssh pcpweb@10.238.6.65 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log &"
rem ssh pcpweb@10.238.6.66 "nohup sudo -u supweb /opt/web/siebel/siebel811/siebsrvr/scripts/stop_srv.sh > /tmp/devops/stop_devops.log &"


exit 0