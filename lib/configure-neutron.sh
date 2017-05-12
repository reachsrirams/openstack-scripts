echo "Running: $0 $@"
source $(dirname $0)/config-parameters.sh
source $(dirname $0)/admin_openrc.sh

if [ "$1" != "compute" -a "$1" != "networknode" -a "$1" != "controller" ]
	then
		echo "Invalid node type: $1"
		echo "Correct syntax: $0 [ controller | compute | networknode ]  <controller-host-name> <rabbitmq-password> <neutron-password> <neutron-db-password> <mysql-username> <mysql-password>"
		exit 1;
fi

if [ "$1" == "controller" ] && [ $# -ne 7 ]
        then
		echo "Correct syntax: $0 controller <controller-host-name> <rabbitmq-password> <neutron-password> <neutron-db-password> <mysql-username> <mysql-password>"
                exit 1;
elif [ "$1" == "compute" ] || [ "$1" == "networknode" ] && [ $# -ne 4 ]
	then
		echo "Correct syntax: $0 [ compute | networknode ] <controller-host-name> <rabbitmq-password> <neutron-password>"
		exit 1;
fi

if [ "$1" == "controller" ]
	then
		echo "Configuring MySQL for Neutron..."
mysql_command="CREATE DATABASE IF NOT EXISTS neutron; GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '$5'; GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '$5';"
		echo "MySQL Command is:: "$mysql_command
		mysql -u "$6" -p"$7" -e "$mysql_command"

		create-user-service neutron $4 neutron OpenStackNetworking network
		
		create-api-endpoints network http://$2:9696
		
		echo_and_sleep "Created Neutron Endpoint in Keystone. About to Neutron Conf File" 5
		crudini --set /etc/neutron/neutron.conf database connection mysql+pymysql://neutron:$5@$2/neutron

		echo_and_sleep "Configuring Neutron Conf File" 2
		crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin ml2
		crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins router,firewall
		crudini --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips True
fi

echo_and_sleep "RabbitMQ config changed for Newton" 1
crudini --set /etc/neutron/neutron.conf DEFAULT transport_url rabbit://openstack:$3@$2

crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone
configure-keystone-authentication /etc/neutron/neutron.conf $2 neutron $4

crudini --set /etc/neutron/neutron.conf DEFAULT verbose True

if [ "$1" == "networknode" -o "$1" == "controller" ]
	then
		crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes True
		crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes True
		crudini --set /etc/neutron/neutron.conf DEFAULT nova_url http://$2:8774/v2

		crudini --set /etc/neutron/neutron.conf nova auth_url http://$2:35357/
		crudini --set /etc/neutron/neutron.conf nova auth_type password
		crudini --set /etc/neutron/neutron.conf nova project_domain_name default
		crudini --set /etc/neutron/neutron.conf nova user_domain_name default
		crudini --set /etc/neutron/neutron.conf nova region_name RegionOne
		crudini --set /etc/neutron/neutron.conf nova project_name service
		crudini --set /etc/neutron/neutron.conf nova username nova
		crudini --set /etc/neutron/neutron.conf nova password $4

		echo_and_sleep "Configuring ML2 INI file"
		crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers flat,vlan,vxlan
		crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types vxlan
		crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers linuxbridge,l2population
		crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers port_security
		crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks provider
		crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan vni_ranges 1:1000
		echo_and_sleep "Configured VNI Range."
		
		crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_security_group True
		crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset True
		
		crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings $neutron_linuxbridge_physical_interface_mappings
		crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan True
		crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population True
		overlay_interface_ip=$(get-ip-address $neutron_linuxbridge_overlay_interface)
		echo "Overlay Interface IP Address: $overlay_interface_ip"
		sleep 5
		crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip $overlay_interface_ip
		crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini agent prevent_arp_spoofing True
		crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group True
		crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

sleep 3

		echo_and_sleep "Configuring L3 Agent Information" 2
		crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.BridgeInterfaceDriver
		crudini --set /etc/neutron/l3_agent.ini DEFAULT verbose True
		echo_and_sleep "Configured L3 Agent Information" 2
		
		echo_and_sleep "Configuring DHCP Agent Information" 1
		crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.BridgeInterfaceDriver
		crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver neutron.agent.linux.dhcp.Dnsmasq
		crudini --set /etc/neutron/dhcp_agent.ini DEFAULT verbose True
		echo_and_sleep "Configured DHCP Agent Information" 2

		echo_and_sleep "Configuring Firewall Information" 2
		crudini --set /etc/neutron/fwaas_driver.ini fwaas enabled True
		crudini --set /etc/neutron/fwaas_driver.ini fwaas driver neutron_fwaas.services.firewall.drivers.linux.iptables_fwaas.IptablesFwaasDriver
		echo_and_sleep "Configured Firewall Information" 2
		
		echo_and_sleep "Configuring Metadata Agent Information" 1
		crudini --set /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_ip $2
		crudini --set /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret password
		echo_and_sleep "Configured Metadata Agent Information" 2
fi

if [ "$1" == "compute" ]
	then
		crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings $neutron_linuxbridge_physical_interface_mappings
		crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan True
		crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population True
		overlay_interface_ip=$(get-ip-address $neutron_linuxbridge_overlay_interface)
		echo "Overlay Interface IP Address: $overlay_interface_ip"
		sleep 5
		crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip $overlay_interface_ip
		crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini agent prevent_arp_spoofing True
		crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group True
		crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
fi

sleep 3


if [ "$1" == "compute" -o "$1" == "controller" ]
	then
		crudini --set /etc/nova/nova.conf neutron url http://$2:9696
		crudini --set /etc/nova/nova.conf neutron auth_url http://$2:35357
		crudini --set /etc/nova/nova.conf neutron auth_type password
		crudini --set /etc/nova/nova.conf neutron project_domain_name default
		crudini --set /etc/nova/nova.conf neutron user_domain_name default
		crudini --set /etc/nova/nova.conf neutron region_name RegionOne
		crudini --set /etc/nova/nova.conf neutron project_name service
		crudini --set /etc/nova/nova.conf neutron username neutron
		crudini --set /etc/nova/nova.conf neutron password $4
		crudini --set /etc/nova/nova.conf neutron service_metadata_proxy True
		crudini --set /etc/nova/nova.conf neutron metadata_proxy_shared_secret password
		echo_and_sleep "Configured Nova to use Neutron - neutron section" 2

fi
		
if [ "$1" == "controller" ]
	then
		echo_and_sleep "Configured Security Group for ML2. About to Upgrade Neutron DB..."
		neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head
		echo_and_sleep "Restarting Services..."
		service nova-api restart
		service neutron-server restart
		service neutron-linuxbridge-agent restart
		service neutron-l3-agent restart
		service neutron-dhcp-agent restart
		service neutron-metadata-agent restart
		service neutron-lbaas-agent stop
		service nova-scheduler restart
		service nova-conductor restart
		print_keystone_service_list
		openstack network agent list
		echo_and_sleep "Printed Neutron Agent List" 2
		rm -f /var/lib/neutron/neutron.sqlite
elif [ "$1" == "compute" ]
	then
		service nova-compute restart
		service neutron-linuxbridge-agent restart
elif [ "$1" == "networknode" ]
	then
		service neutron-linuxbridge-agent restart
		service neutron-l3-agent restart
		service neutron-dhcp-agent restart
		service neutron-metadata-agent restart
fi
