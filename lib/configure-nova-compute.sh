source config-parameters.sh
if [ $# -lt 4 ]
	then
		echo "Correct Syntax: $0 <conroller-host-name> <nova-password> <rabbitmq-password> <compute_ip>"
		exit 1
fi

echo_and_sleep "Local IP: $4. Configuring NOVA Conf File..."

crudini --set /etc/nova/nova.conf DEFAULT rpc_backend rabbit
crudini --set /etc/nova/nova.conf DEFAULT rabbit_host $1
crudini --set /etc/nova/nova.conf DEFAULT rabbit_password $3
crudini --set /etc/nova/nova.conf DEFAULT auth_strategy keystone

crudini --set /etc/nova/nova.conf keystone_authtoken auth_uri http://$1:5000/v2.0
crudini --set /etc/nova/nova.conf keystone_authtoken identity_uri http://$1:35357
crudini --set /etc/nova/nova.conf keystone_authtoken admin_tenant_name service
crudini --set /etc/nova/nova.conf keystone_authtoken admin_user nova
crudini --set /etc/nova/nova.conf keystone_authtoken admin_password $2

eth0_ip=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "eth0 IP Address: $eth0_ip"
sleep 2
crudini --set /etc/nova/nova.conf DEFAULT my_ip $eth0_ip
crudini --set /etc/nova/nova.conf DEFAULT vnc_enabled True
crudini --set /etc/nova/nova.conf DEFAULT vncserver_listen 0.0.0.0
crudini --set /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address $eth0_ip
crudini --set /etc/nova/nova.conf DEFAULT novncproxy_base_url http://$1:6080/vnc_auto.html

crudini --set /etc/nova/nova.conf glance host $1
crudini --set /etc/nova/nova.conf DEFAULT verbose True
echo_and_sleep "Configured Nova Parameters"

echo "Restarting Nova Service..."
service nova-compute restart

echo_and_sleep "Removing Nova MySQL-Lite Database..."
rm -f /var/lib/nova/nova.sqlite
