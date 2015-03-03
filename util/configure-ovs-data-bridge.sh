if [ $# -lt 1 ]
	then
		echo "Correct syntax: $0 <data-path-interface>"
		exit 1;
fi


crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs bridge_mappings physnet1:br-eth1
ovs-vsctl add-br br-eth1
ovs-vsctl add-port br-eth1 $1
ovs-vsctl show
service openvswitch-switch restart
service neutron-l3-agent restart
service neutron-plugin-openvswitch-agent restart

