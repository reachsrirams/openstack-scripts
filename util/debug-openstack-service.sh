function debug-neutron() {
	echo "About to configure Neutron Debug to "$2
	crudini --set /etc/neutron/neutron.conf DEFAULT verbose $2
	crudini --set /etc/neutron/neutron.conf DEFAULT debug $2
	if [ "$1" == "controller" ]
		then
			service neutron-server restart
	else
		echo "Invalid node type: $1. Only the following node types are supported: compute, controller"
		exit 1;
	fi
}

function debug-nova() {
	echo "About to configure NOVA Debug to "$debug_flag
	crudini --set /etc/nova/nova.conf DEFAULT verbose $debug_flag
	crudini --set /etc/nova/nova.conf DEFAULT debug $debug_flag
	if [ "$1" == "controller" ]
		then
			service nova-api restart
			service nova-conductor restart
			service nova-scheduler restart
	elif [ "$1" == "compute" ]
		then
			service nova-compute restart
	else
		echo "Invalid node type: $1. Only the following node types are supported: compute, controller"
		exit 1;
	fi
}

function debug-keystone() {
	echo "About to configure Keystone Debug to "$debug_flag
	crudini --set /etc/keystone/keystone.conf DEFAULT verbose $debug_flag
	crudini --set /etc/keystone/keystone.conf DEFAULT debug $debug_flag
	if [ "$1" == "controller" ]
		then
			service apache2 restart
	else
		echo "Invalid node type: $1. Only the following node types are supported: compute, controller"
		exit 1;
	fi
}

if [ $# -lt 2 ]
	then
		echo "Correct Syntax: $0 <openstack-service-name> <on|off>"
		exit 1;
fi

debug_flag="False"
if [ "$2" == "on" ]
	then
		debug_flag="True"
fi

node_type=`bash $(dirname $0)/detect-nodetype.sh`
echo "Node Type detected as: $node_type"

case $1 in
	neutron)
		debug-neutron $node_type $debug_flag
		;;
	nova)
		debug-nova $node_type $debug_flag
		;;
	keystone)
		debug-keystone $node_type $debug_flag
		;;
	*)
		echo "Invalid service: $1. Only the following services are supported: nova, neutron, keystone."
		exit 1;
	;;
esac
