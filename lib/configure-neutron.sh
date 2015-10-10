echo "Running: $0 $@"
source $(dirname $0)/config-parameters.sh
source $(dirname $0)/admin_openrc.sh

if [ "$1" != "compute" -a "$1" != "networknode" -a "$1" != "controller" ]
	then
		echo "Invalid node type: $1"
		echo "Correct syntax: $0 [ controller | compute | networknode ]  <controller-host-name> <rabbitmq-password> <neutron-password> <neutron-db-password> <mysql-username> <mysql-password> <service-tenant-id>"
		exit 1;
fi

if [ "$1" == "controller" ] && [ $# -ne 8 ]
        then
		echo "Correct syntax: $0 controller  <controller-host-name> <rabbitmq-password> <neutron-password> <neutron-db-password> <mysql-username> <mysql-password> <service-tenant-id>"
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

		create-user-service neutron $4 neutron '"OpenStack Networking"' network
		
		openstack endpoint create \
		--publicurl http://$2:9696 \
		--internalurl http://$2:9696 \
		--adminurl http://$2:9696 \
		--region RegionOne
		network
		
		echo_and_sleep "Created Neutron Endpoint in Keystone. About to Neutron Conf File" 7
		crudini --set /etc/neutron/neutron.conf database connection mysql://neutron:$5@$2/neutron
fi

echo_and_sleep "Configuring Neutron Conf File" 3

crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend rabbit
configure-oslo-messaging /etc/neutron/neutron.conf $2 openstack $3
crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone

configure-keystone-authentication /etc/neutron/neutron.conf $2 neutron $4

crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin ml2
crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins router
crudini --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips True
crudini --set /etc/neutron/neutron.conf DEFAULT verbose True

if [ "$1" == "controller" ]
	then
		crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes True
		crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes True
		crudini --set /etc/neutron/neutron.conf DEFAULT nova_url http://$2:8774/v2
		crudini --set /etc/neutron/neutron.conf DEFAULT nova_admin_auth_url http://$2:35357/v2.0
		crudini --set /etc/neutron/neutron.conf DEFAULT nova_region_name RegionOne
		crudini --set /etc/neutron/neutron.conf DEFAULT nova_admin_username nova
		crudini --set /etc/neutron/neutron.conf DEFAULT nova_admin_tenant_id $8
		crudini --set /etc/neutron/neutron.conf DEFAULT nova_admin_password $4
fi

echo_and_sleep "Configuring ML2 INI file"
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers $neutron_ml2_type_drivers
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types $neutron_ml2_tenant_network_types
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers $neutron_ml2_mechanism_drivers

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vlan network_vlan_ranges $neutron_ml2_network_vlan_ranges
echo_and_sleep "Configured VLAN Range."

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_security_group True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs tenant_network_type $neutron_ovs_tenant_network_type
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs bridge_mappings $neutron_ovs_bridge_mappings
echo_and_sleep "Configured OVS Information" 2

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini linux_bridge tenant_network_type $neutron_linuxbridge_tenant_network_type
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini linux_bridge physical_interface_mappings $neutron_linuxbridge_physical_interface_mappings
echo_and_sleep "Configured Linux Bridge" 2

if [ "$1" == "compute" -o "$1" == "controller" ]
	then
		crudini --set /etc/nova/nova.conf DEFAULT network_api_class nova.network.neutronv2.api.API
		crudini --set /etc/nova/nova.conf DEFAULT security_group_api neutron
		crudini --set /etc/nova/nova.conf DEFAULT linuxnet_interface_driver nova.network.linux_net.LinuxOVSIntefaceDriver
		crudini --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
		echo_and_sleep "Configured Nova to use Neutron - DEFAULT section"
		
		crudini --set /etc/nova/nova.conf neutron url http://$2:9696
		crudini --set /etc/nova/nova.conf neutron auth_strategy keystone
		crudini --set /etc/nova/nova.conf neutron admin_auth_url http://$2:35357/v2.0
		crudini --set /etc/nova/nova.conf neutron admin_tenant_name service
		crudini --set /etc/nova/nova.conf neutron admin_username neutron
		crudini --set /etc/nova/nova.conf neutron admin_password $4
		echo_and_sleep "Configured Nova to use Neutron - neutron section"
fi

if [ "$1" == "networknode" ]
	then
		crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks external

		echo_and_sleep "Configuring L3 Agent Information" 2
		crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
		crudini --set /etc/neutron/l3_agent.ini DEFAULT use_namespaces True
		crudini --set /etc/neutron/l3_agent.ini DEFAULT verbose True
		echo_and_sleep "Configured L3 Agent Information" 2
		
		echo_and_sleep "Configuring DHCP Agent Information" 1
		crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
		crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver neutron.agent.linux.dhcp.Dnsmasq
		crudini --set /etc/neutron/dhcp_agent.ini DEFAULT use_namespaces True
		crudini --set /etc/neutron/dhcp_agent.ini DEFAULT verbose True
		echo_and_sleep "Configured DHCP Agent Information" 2
fi
		
echo_and_sleep "Restarting Neutron related services" 2
service openvswitch-switch restart
echo_and_sleep "Restarted OVS Service..." 2

if [ "$1" == "controller" ]
	then
		echo_and_sleep "Configured Security Group for ML2. About to Upgrade Neutron DB..."
		neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade juno
		echo_and_sleep "Restarting Neutron Service..."
		service nova-api restart
		service nova-scheduler restart
		service nova-conductor restart
		service neutron-server restart
		print_keystone_service_list
elif [ "$1" == "compute" ]
	then
		service nova-compute restart
elif [ "$1" == "networknode" ]
	then
		service neutron-plugin-openvswitch-agent restart 
		service neutron-l3-agent restart
		service neutron-dhcp-agent restart
		service neutron-metadata-agent restart
fi
