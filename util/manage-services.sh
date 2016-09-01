echo "Running: $0 $@"

node_type=`bash $(dirname $0)/detect-nodetype.sh`
echo "Node Type detected as: $node_type"

function manage-controller-horizon() {
	service apache2 $1
	sleep 2
	service memcached $1
	sleep 2
}

function manage-controller-nova() {
	service nova-api $1
	sleep 3
	service nova-cert $1
	sleep 3
	service nova-consoleauth $1 
	sleep 3
	service nova-scheduler $1 
	sleep 3
	service nova-conductor $1 
	sleep 3
	service nova-novncproxy $1
}

function manage-controller-glance() {
	service glance-api $1
	sleep 2
	service glance-registry $1
}

function manage-networknode-services() {
	echo "Restarting Network Node Services"
	service openvswitch-switch $1
	sleep 2
	service neutron-plugin-openvswitch-agent $1 
	sleep 2
	service neutron-l3-agent $1
	sleep 2
	service neutron-dhcp-agent $1
	sleep 2
	service neutron-metadata-agent $1
	sleep 2
	service neutron-linuxbridge-agent $1
	sleep 2
}

function manage-controller-neutron() {
	service neutron-server $1
	sleep 2
}

function manage-controller-services() {
	echo "Restarting Controller Services $1"
	if [ "$1" == "nova" ]
		then
			manage-controller-nova $2
	elif [ "$1" == "horizon" ]
		then
			manage-controller-horizon $2
	elif [ "$1" == "neutron" ]
		then
			manage-controller-neutron $2
	else
		service mysql $2
		sleep 5
		service rabbitmq-server $2
		sleep 3
		manage-controller-horizon $2
		sleep 2
		manage-controller-glance $2
		sleep 2
		manage-controller-nova $2
		sleep 2
		manage-controller-neutron $2
		sleep 2
		service ceilometer-api $2
	fi
}

function manage-compute-services() {
	echo "Restarting Compute Services"
	service nova-compute $1
	sleep 2
	service openvswitch-switch $1
	sleep 2
	service neutron-plugin-openvswitch-agent $1 
	sleep 2
	service ceilometer-agent-compute $1
}


if [ $# -ne 2 ]
	then
		echo "Correct Syntax: $0 [ all | nova | horizon | neutron ] [ start | stop | restart ]"
		exit 1;
fi

case $node_type in 
	controller) 
		manage-controller-services $1 $2
		manage-networknode-services $2
		;;
	compute) manage-compute-services $2;;
	networknode) manage-networknode-services $2;;
	allinone)
		manage-controller-services $1 $2
		manage-networknode-services $2
		manage-compute-services $2
		;;
	*)
		echo "Invalid node type: $node_type."
		exit 1;
esac 


