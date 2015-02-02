crudini --set /etc/nova/nova.conf DEFAULT my_ip `hostname -I`
crudini --set /etc/nova/nova.conf DEFAULT vncserver_listen `hostname -I`
crudini --set /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address `hostname -I`
echo "Upadted Nova Config file with Correct IP Addresses"
