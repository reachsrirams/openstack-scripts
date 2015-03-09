if [ $# -lt 3 ]
	then
		echo "Correct syntax: $0 <data-path-interface> <bridge-name> <physical-network-alias> [ external ]"
		exit 1;
fi

if [ "$4" == external ]
	then
		echo "Setting L3 Agent for external bridge"
		crudini --set /etc/neutron/l3_agent.ini DEFAULT external_network_bridge $2
else
	echo "Setting OVS Bridge Mapping"
	crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs bridge_mappings $3:$2
fi

sleep 1
ovs-vsctl add-br $2
sleep 1
ovs-vsctl add-port $2 $1
sleep 1
ovs-vsctl show
sleep 1
service neutron-server restart
sleep 1
service openvswitch-switch restart
sleep 1
service neutron-l3-agent restart
service neutron-plugin-openvswitch-agent restart
