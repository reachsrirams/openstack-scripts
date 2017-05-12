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
		echo "Configuring MySQL for Nova API..."
		mysql_command="CREATE DATABASE IF NOT EXISTS nova_api; GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY '$5'; GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY '$5';"
		echo "MySQL Command is:: "$mysql_command
		mysql -u "$6" -p"$7" -e "$mysql_command"
		
		echo "Configuring MySQL for Nova..."
		mysql_command="CREATE DATABASE IF NOT EXISTS nova; GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$5'; GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$5';"
		echo "MySQL Command is:: "$mysql_command
		mysql -u "$6" -p"$7" -e "$mysql_command"
		
		echo_and_sleep "Configuring MySQL for Nova Cells..." 2
		mysql_command="CREATE DATABASE IF NOT EXISTS nova_cell0; GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY '$5'; GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY '$5';"
		echo "MySQL Command is:: "$mysql_command 
		mysql -u "$6" -p"$7" -e "$mysql_command"

		create-user-service nova $3 nova OpenStackCompute compute
		
		create-api-endpoints compute http://$2:8774/v2.1
		echo_and_sleep "Created Endpoint for Nova" 2

		echo_and_sleep "OCATA: Creating Placement User and Service" 2
		create-user-service placement placement placement OpenStackPlacementAPI placement
		create-api-endpoints placement http://$2:8778
		echo_and_sleep "Created Endpoint for Nova Placement API" 2
		
		crudini --set /etc/nova/nova.conf api_database connection mysql+pymysql://nova:$5@$2/nova_api
		crudini --set /etc/nova/nova.conf database connection mysql+pymysql://nova:$5@$2/nova
		echo_and_sleep "Configured NOVA DB Connection" 2

fi

echo_and_sleep "Updating NOVA Configuration File" 1
echo_and_sleep "RabbitMQ config changed for Newton" 1
crudini --set /etc/nova/nova.conf DEFAULT transport_url rabbit://openstack:$4@$2

crudini --set /etc/nova/nova.conf api auth_strategy keystone

configure-keystone-authentication /etc/nova/nova.conf $2 nova $3

mgmt_interface_ip=$(get-ip-address $mgmt_interface)
echo "Mgmt Interface IP Address: $mgmt_interface_ip"
sleep 5
crudini --set /etc/nova/nova.conf DEFAULT my_ip $mgmt_interface_ip
crudini --set /etc/nova/nova.conf DEFAULT use_neutron True
crudini --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver

crudini --set /etc/nova/nova.conf vnc vncserver_proxyclient_address $mgmt_interface_ip

crudini --set /etc/nova/nova.conf placement os_region_name RegionOne
crudini --set /etc/nova/nova.conf placement project_domain_name Default
crudini --set /etc/nova/nova.conf placement project_name service
crudini --set /etc/nova/nova.conf placement auth_type password
crudini --set /etc/nova/nova.conf placement user_domain_name Default
crudini --set /etc/nova/nova.conf placement auth_url http://$2:35357/v3
crudini --set /etc/nova/nova.conf placement username placement
crudini --set /etc/nova/nova.conf placement password placement

if [ "$1" == "controller" ]
	then
		crudini --set /etc/nova/nova.conf vnc vncserver_listen $mgmt_interface_ip
elif [ "$1" == "compute" ]
	then
		controller_ip=`getent hosts $2 | awk '{ print $1 }'`
		echo_and_sleep "Controller IP is: $controller_ip" 2
		crudini --set /etc/nova/nova.conf vnc enabled True
		crudini --set /etc/nova/nova.conf vnc vncserver_listen 0.0.0.0
		crudini --set /etc/nova/nova.conf vnc novncproxy_base_url http://$controller_ip:6080/vnc_auto.html

		echo_and_sleep "OCATA: Setting cell autodisovery time interval" 2
		crudini --set /etc/nova/nova.conf scheduler discover_hosts_in_cells_interval 10
fi

crudini --set /etc/nova/nova.conf glance api_servers http://$2:9292
crudini --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
echo_and_sleep "Updated NOVA Configuration File" 2

if [ "$1" == "controller" ]
	then
		echo_and_sleep "Populate Image Nova Database" 1
		nova-manage api_db sync
		echo_and_sleep "OCATA: Mapping Nova Cells" 2
		nova-manage cell_v2 map_cell0
		echo_and_sleep "OCATA: Creating Cell..." 2
		nova-manage cell_v2 create_cell --name=cell1 --verbose
		nova-manage db sync
		echo_and_sleep "Restarting Nova Service" 2
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

echo_and_sleep "Removing Nova MySQL-Lite Database" 2
rm -f /var/lib/nova/nova.sqlite

if [ "$1" == "controller" ]
	then
		print_keystone_service_list
		nova service-list
		echo_and_sleep "Listing Nova Cells" 1
		nova-manage cell_v2 list_cells
		echo_and_sleep "Verify Nova Service List"
fi
