if [ $# -lt 2 ]
	then
		echo "Correct syntax: $0 <data-path-interface> <physical-network-alias> [ external ]"
		exit 1;
fi

bridge_name="br-"$1
echo "Bridge name: $bridge_name"
sleep 1
if [ "$3" == external ]
	then
		echo "Setting L3 Agent for external bridge"
		crudini --set /etc/neutron/l3_agent.ini DEFAULT external_network_bridge $bridge_name
else
	echo "Setting OVS Bridge Mapping"
	crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs bridge_mappings $2:$bridge_name
fi

ovs-vsctl add-br $bridge_name
ovs-vsctl add-port $bridge_name $1
ovs-vsctl show
service openvswitch-switch restart
service neutron-l3-agent restart
service neutron-plugin-openvswitch-agent restart
