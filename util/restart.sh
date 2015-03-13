echo "Running: $0 $@"

node_type=`bash $(dirname $0)/detect-nodetype.sh`
echo "Node Type detected as: $node_type"

function restart-controller-horizon() {
	service apache2 restart
	sleep 2
	service memcached restart
	sleep 2
}

function restart-controller-nova() {
	service nova-api restart
	sleep 3
	service nova-cert restart
	sleep 3
	service nova-consoleauth restart 
	sleep 3
	service nova-scheduler restart 
	sleep 3
	service nova-conductor restart 
	sleep 3
	service nova-novncproxy restart
}

function restart-controller-glance() {
	service glance-api restart
	sleep 2
	service glance-registry restart
}

function restart-controller-services() {
	echo "Restarting Controller Services $1"
	if [ "$1" == "nova" ]
		then
			restart-controller-nova
	elif [ "$1" == "horizon" ]
		then
			restart-controller-horizon
	else
		service mysql restart
		sleep 5
		service rabbitmq-server restart
		sleep 3
		service keystone restart
		sleep 2
		restart-controller-glance
		sleep 2
		restart-controller-nova
		sleep 2
		service neutron-server restart
		sleep 2
		restart-controller-horizon
		sleep 2
		service ceilometer-api restart
	fi
}

function restart-compute-services() {
	echo "Restarting Compute Services $1"
	service nova-compute restart
	sleep 2
	service openvswitch-switch restart
	sleep 2
	service neutron-plugin-openvswitch-agent restart 
	sleep 2
	service ceilometer-agent-compute restart
}

function restart-networknode-services() {
	echo "Restarting Network Node Services $1"
	service openvswitch-switch restart
	sleep 2
	service neutron-plugin-openvswitch-agent restart 
	sleep 2
	service neutron-l3-agent restart
	sleep 2
	service neutron-dhcp-agent restart
	sleep 2
	service neutron-metadata-agent restart
	sleep 2
}

if [ $# -lt 1 ]
	then
		echo "Correct Syntax: $0 [ all | nova | horizon ] [ allinone ]"
		echo "Note: second parameter is optional"
		exit 1;
fi

if [ ! -z $2 ]
	then
		node_type=$2
fi

case $node_type in 
	controller) restart-controller-services $1 ;;
	compute) restart-compute-services $1 ;;
	networknode) restart-networknode-services $1 ;;
	allinone)
		restart-controller-services $1
		restart-networknode-services $1
		restart-compute-services $1
		;;
	*)
		echo "Invalid node type: $node_type."
		exit 1;
esac 


