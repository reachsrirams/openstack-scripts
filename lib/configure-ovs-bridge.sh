echo "Running: $0 $@"
sleep 5
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

if [ "$node_type" == "compute" ] || [ "node_type" == "controller_networknode" ] || [ "node_type" == "allinone" ] || [ "node_type" == "networknode" ]
	then
		sleep 1
		ovs-vsctl add-br $bridge_name
		sleep 1
		ovs-vsctl add-port $bridge_name $1
		sleep 1
		ovs-vsctl show
		sleep 1
		service openvswitch-switch restart
fi

if [ "$node_type" == "controller" ] || [ "node_type" == "controller_networknode" ] || [ "node_type" == "allinone" ]
	then
		service neutron-server restart
fi

sleep 1

if [ "$node_type" == "networknode" ] || [ "node_type" == "controller_networknode" ] || [ "node_type" == "allinone" ]
	then
		service neutron-l3-agent restart
fi

if [ "$node_type" == "controller" ] || [ "node_type" == "controller_networknode" ] || [ "node_type" == "allinone" ]
	then
		service neutron-plugin-openvswitch-agent restart
fi
