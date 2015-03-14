if [ $# -lt 1 ]
	then
		echo "Correct Syntax: $0 <linux-bridge-tenant-network-type> <physical-interface-mappings> <ml2-type-drivers> <ml2-tenant-network-types>"
fi

apt-get install neutron-plugin-linuxbridge-agent -y
sleep 5
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers linuxbridge
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini linux_bridge tenant_network_type $1

if [ ! -z "$2" ]
	then
		echo "Setting Linux Bridge Physical Interface Mappings $2"
		sleep 3
		crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini linux_bridge physical_interface_mappings $2
fi

if [ ! -z "$3" ]
	then
		echo "Setting Linux Bridge ML2 Type Drivers $3"
		sleep 3
		crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers $3
fi

if [ ! -z "$4" ]
	then
		echo "Setting Linux Bridge Tenant Network Types $4"
		sleep 3
		crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types $4
fi

echo "Setting Linux Bridge drivers for other Agents"
sleep 3
crudini --set /etc/neutron/dhcp_agent.ini interface_driver neutron.agent.linux.interface.BridgeInterfaceDriver
crudini --set /etc/neutron/l3_agent.ini interface_driver neutron.agent.linux.interface.BridgeInterfaceDriver

sleep 3
service neutron-server restart 
sleep 3
service neutron-plugin-linuxbridge-agent restart
sleep 3
service neutron-dhcp-agent restart
sleep 3
service neutron-l3-agent restart
