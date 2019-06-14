if [ $# -lt 1 ]
	then
		echo "Correct Syntax: $0 <overlay-interface-ip> <physical-interface-mappings> <ml2-type-drivers>"
fi

apt-get purge neutron-plugin-openvswitch-agent -y
apt-get purge openvswitch-switch -y
apt-get autoremove -y
apt-get install neutron-plugin-linuxbridge-agent -y
sleep 5

if [ ! -z "$3" ]
	then
		echo "Setting Linux Bridge ML2 Type Drivers $3"
		sleep 3
		crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers $3
fi

echo "Setting Tenant Network Types to VXLAN for Linux Bridge"
sleep 3
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types vxlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers linuxbridge,l2population

if [ ! -z "$2" ]
	then
		echo "Setting Linux Bridge Physical Interface Mappings $2"
		sleep 3
		crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings $2
fi

crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan True
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population True
if [ ! -z "$1" ]
	then
		echo "Setting Overlay Interface IP: $1"
		sleep 3
		crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini local_ip $1
fi

crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini agent prevent_arp_spoofing True
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group True
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

echo "Setting Linux Bridge drivers for other Agents"
sleep 3
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.BridgeInterfaceDriver
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver neutron.agent.linux.dhcp.Dnsmasq
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT enable_isolated_metadata True
crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.BridgeInterfaceDriver

sleep 3
service neutron-server restart 
sleep 3
service neutron-linuxbridge-agent restart
sleep 3
service neutron-dhcp-agent restart
sleep 3
service neutron-l3-agent restart
