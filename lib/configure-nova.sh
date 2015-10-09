echo "Running: $0 $@"
source $(dirname $0)/config-parameters.sh

if [ "$1" != "controller" ] && [ "$1" != "compute" ]
	then
		echo "Correct Syntax: $0 [ controller | compute ] <controller-host-name> <nova-password> <rabbitmq-password> <nova-db-password> <mysql-username> <mysql-password>"
		exit 1;
fi

if [ "$1" == "controller" ] && [ $# -ne 7 ]
	then
		echo "Correct Syntax: $0 controller <controller-host-name> <nova-password> <rabbitmq-password> <nova-db-password> <mysql-username> <mysql-password>"
		exit 1;
fi
		
if [ "$1" == "compute" ] && [ $# -ne 4 ]
	then
		echo "Correct Syntax: $0 compute <controller-host-name> <nova-password> <rabbitmq-password>"
		exit 1;
fi
		
source $(dirname $0)/admin_openrc.sh

if [ "$1" == "controller" ]
	then
		echo "Configuring MySQL for Nova..."
		mysql_command="CREATE DATABASE IF NOT EXISTS nova; GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$5'; GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$5';"
		echo "MySQL Command is:: "$mysql_command
		mysql -u "$6" -p"$7" -e "$mysql_command"
		
		keystone user-create --name nova --pass $3
		echo_and_sleep "Creating Nova User in KeyStone"
		keystone user-role-add --user nova --tenant service --role admin
		echo_and_sleep "Created Nova Tenant"
		
		keystone service-create --name nova --type compute --description "OpenStack Compute"
		echo_and_sleep "Called service-create for Nova Compute"
		
		keystone endpoint-create \
		--service-id $(keystone service-list | awk '/ compute / {print $2}') \
		--publicurl http://$2:8774/v2/%\(tenant_id\)s \
		--internalurl http://$2:8774/v2/%\(tenant_id\)s \
		--adminurl http://$2:8774/v2/%\(tenant_id\)s \
		--region RegionOne
		
		echo_and_sleep "Configuring NOVA DB Connection"
		crudini --set /etc/nova/nova.conf database connection mysql://nova:$5@$2/nova

fi

echo_and_sleep "Updating NOVA Configuration File"

crudini --set /etc/nova/nova.conf DEFAULT rpc_backend rabbit

crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_host $2

##TBD - Fix hardcoding of Rabbit USER ID
crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_password $4

crudini --set /etc/nova/nova.conf DEFAULT auth_strategy keystone

crudini --set /etc/nova/nova.conf keystone_authtoken auth_uri http://$4:5000
crudini --set /etc/nova/nova.conf keystone_authtoken auth_url http://$4:35357
crudini --set /etc/nova/nova.conf keystone_authtoken auth_plugin password
crudini --set /etc/nova/nova.conf keystone_authtoken project_domain_id default
crudini --set /etc/nova/nova.conf keystone_authtoken user_domain_id default
crudini --set /etc/nova/nova.conf keystone_authtoken project_name service
crudini --set /etc/nova/nova.conf keystone_authtoken username glance
crudini --set /etc/nova/nova.conf keystone_authtoken password $6
crudini --set /etc/nova/nova.conf keystone_authtoken admin_password $3

eth0_ip=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "eth0 IP Address: $eth0_ip"
sleep 2
crudini --set /etc/nova/nova.conf DEFAULT my_ip $eth0_ip
crudini --set /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address $eth0_ip

if [ "$1" == "controller" ]
	then
		crudini --set /etc/nova/nova.conf DEFAULT vncserver_listen $eth0_ip
		crudini --set /etc/nova/nova.conf DEFAULT scheduler_default_filters AllHostsFilter
elif [ "$1" == "compute" ]
	then
		crudini --set /etc/nova/nova.conf DEFAULT vnc_enabled True
		crudini --set /etc/nova/nova.conf DEFAULT vncserver_listen 0.0.0.0
		crudini --set /etc/nova/nova.conf DEFAULT novncproxy_base_url http://$2:6080/vnc_auto.html
fi

crudini --set /etc/nova/nova.conf glance host $2
crudini --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
crudini --set /etc/nova/nova.conf DEFAULT verbose True
echo_and_sleep "Updated NOVA Configuration File" 2

echo_and_sleep "Removing Nova MySQL-Lite Database" 3
rm -f /var/lib/nova/nova.sqlite

if [ "$1" == "controller" ]
	then
		echo_and_sleep "Populate Image Nova Database" 
		nova-manage db sync
		echo_and_sleep "Restarting Nova Service"
		service nova-api restart
		service nova-cert restart
		service nova-consoleauth restart
		service nova-scheduler restart
		service nova-conductor restart
		service nova-novncproxy restart
elif [ "$1" == "compute" ]
	then
		echo "Restarting Nova Service"
		service nova-compute restart
fi

if [ "$1" == "controller" ]
	then
		print_keystone_service_list
		nova service-list
		echo_and_sleep "Verify Nova Service List" 5
fi
