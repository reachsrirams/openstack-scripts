if [ $# -lt 4]
	then
		echo "Correct Syntax: $0 <conroller-host-name> <nova-password> <rabbitmq-password> <management-ip>"
		exit 1
fi


apt-get install nova-compute sysfsutils
if [ $? eq 0 ]
	then
		echo "Configuring NOVA Conf File..."

		crudini --set /etc/nova/nova.conf DEFAULT rpc_backend rabbit
		crudini --set /etc/nova/nova.conf DEFAULT rabbit_host $1
		crudini --set /etc/nova/nova.conf DEFAULT rabbit_password $3
		crudini --set /etc/nova/nova.conf DEFAULT auth_strategy keystone

		crudini --set /etc/nova/nova.conf keystone_authtoken auth_uri http://$1:5000/v2.0
		crudini --set /etc/nova/nova.conf keystone_authtoken identity_uri http://$1:35357
		crudini --set /etc/nova/nova.conf keystone_authtoken admin_tenant_name service
		crudini --set /etc/nova/nova.conf keystone_authtoken admin_user nova
		crudini --set /etc/nova/nova.conf keystone_authtoken admin_password $2

		crudini --set /etc/nova/nova.conf DEFAULT my_ip $4
		crudini --set /etc/nova/nova.conf DEFAULT vncserver_listen 0.0.0.0
		crudini --set /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address $4
		crudini --set /etc/nova/nova.conf DEFAULT novncproxy_base_url http://$1:6080/vnc_auto.html

		crudini --set /etc/nova/nova.conf glance host $1

		echo "Restarting Nova Service..."
		service nova-compute restart

		echo "Removing Nova MySQL-Lite Database..."
		rm -f /var/lib/nova/nova.sqlite
fi
