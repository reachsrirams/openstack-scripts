echo "Running: $0 $@"
sleep 4
source $(dirname $0)/config-parameters.sh

if [ $# -lt 1 ]
	then
		echo "Correct syntax: $0 <controller | compute | allinone> [ external ] [ external_bridge_name ]"
		exit 1;
fi

node_type=$1

if [ "$2" == external ]
	then
		echo "Setting L3 Agent for external bridge"
		crudini --set /etc/neutron/l3_agent.ini DEFAULT external_network_bridge $3
fi

echo_and_sleep "About to remove Linux Bridge and install OVS in Controller" 5
apt-get purge -y neutron-linuxbridge-agent
apt-get install -y neutron-openvswitch-agent
apt-get autoremove -y
if [ "$node_type" == "controller" ] || [ "node_type" == "allinone" ]
	then
		echo_and_sleep "Configuring ML2 INI file" 5
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers flat,vlan,vxlan
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types vlan
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers openvswitch,l2population
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers port_security
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks public
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan vni_ranges 1:1000
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup firewall_driver iptables_hybrid

		echo_and_sleep "Configuring L3 and DHCP Agent Information" 2
                crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
                crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
                crudini --set /etc/neutron/dhcp_agent.ini DEFAULT enable_isolated_metadata True
                crudini --set /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_ip controller
                crudini --set /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret METADATA_SECRET
fi
overlay_interface_ip=$(get-ip-address $data_interface)
echo "Overlay Interface IP Address: $overlay_interface_ip"
sleep 7
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs local_ip $overlay_interface_ip
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs integration_bridge br-int
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs tunnel_bridge br-tun

crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent tunnel_types vxlan
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent l2_population True
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent prevent_arp_spoofing True

crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini securitygroup firewall_driver iptables_hybrid

echo_and_sleep "About to restart OVS" 3
service openvswitch-switch restart

if [ "$node_type" == "controller" ] || [ "node_type" == "allinone" ]
	then
		service neutron-server restart
		service neutron-openvswitch-agent restart
fi

sleep 1

if [ "$node_type" == "networknode" ] || [ "node_type" == "controller" ] || [ "node_type" == "allinone" ]
	then
		service neutron-l3-agent restart
		service neutron-dhcp-agent restart
fi

if [ "$node_type" == "compute" ]
	then
		service neutron-openvswitch-agent restart
fi
