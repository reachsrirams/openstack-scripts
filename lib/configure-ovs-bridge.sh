echo "Running: $0 $@"
sleep 4
source $(dirname $0)/config-parameters.sh

node_type=`bash $(dirname $0)/detect-nodetype.sh`
echo "Node Type detected as: $node_type"
sleep 3
echo "Bridge Mapping for OVS: "$neutron_ovs_bridge_mappings
bridge_name=`echo $neutron_ovs_bridge_mappings|cut -d: -f2`
sleep 2


if [ $# -lt 1 ]
	then
		echo "Correct syntax: $0 <data-path-interface> [ external ] [ external_bridge_name ]"
		exit 1;
fi

if [ "$2" == external ]
	then
		echo "Setting L3 Agent for external bridge"
		bridge_name=$3
		crudini --set /etc/neutron/l3_agent.ini DEFAULT external_network_bridge $bridge_name
else
	echo "Setting OVS Bridge Mapping"
	crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs bridge_mappings $neutron_ovs_bridge_mappings
fi

if [ "$node_type" == "controller" ] || [ "node_type" == "allinone" ]
	then
		echo_and_sleep "Configuring ML2 INI file"
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers flat,vlan,vxlan
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types vxlan
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers openvswitch,l2population
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers port_security
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks public
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan vni_ranges 1:1000
fi


		crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini linux_bridge physical_interface_mappings $neutron_linuxbridge_physical_interface_mappings
		crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini vxlan enable_vxlan True
                crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini vxlan l2_population True
                overlay_interface_ip=$(get-ip-address $neutron_linuxbridge_overlay_interface)
                echo "Overlay Interface IP Address: $overlay_interface_ip"
                sleep 5
                crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs integration_bridge br-int
                crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs tunnel_bridge br-tun
                crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs local_ip $overlay_interface_ip
                crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent prevent_arp_spoofing True
                crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent tunnel_types vxlan
                crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini securitygroup enable_security_group True
                crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini securitygroup enable_ipset True
                crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver

		echo_and_sleep "Configuring L3 and DHCP Agent Information" 2
                crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
                crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver


sleep 1
ovs-vsctl add-br $bridge_name
sleep 1
ovs-vsctl add-port $bridge_name $1
sleep 1
ovs-vsctl show
sleep 1
service openvswitch-switch restart

if [ "$node_type" == "controller" ] || [ "node_type" == "allinone" ]
	then
		service neutron-server restart
		service neutron-plugin-openvswitch-agent restart
fi

sleep 1

if [ "$node_type" == "networknode" ] || [ "node_type" == "controller" ] || [ "node_type" == "allinone" ]
	then
		service neutron-l3-agent restart
fi

if [ "$node_type" == "compute" ]
	then
		service neutron-plugin-openvswitch-agent restart
fi
