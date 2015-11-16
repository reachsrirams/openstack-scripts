echo "Running: $0 $@"

node_type=`bash $(dirname $0)/detect-nodetype.sh`
echo "Node Type detected as: $node_type"
sleep 3

if [ $# -lt 1 ]
	then
		echo "Correct Syntax: $0 <controller-host-name> <controller-ip-address>"
		echo "Second parameter required only for Network and Compute Node"
		exit 1;
fi


function update-nova-config-ip() {
	mgmg_interface_ip=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
	echo "Local Node IP: $mgmg_interface_ip"
	sleep 2

	crudini --set /etc/nova/nova.conf DEFAULT my_ip $mgmg_interface_ip
	crudini --set /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address $mgmg_interface_ip

	if [ "$1" == "controller" ]
		then
			crudini --set /etc/nova/nova.conf DEFAULT vncserver_listen $mgmg_interface_ip
			sleep 2
			service nova-novncproxy restart
		else
			if [ -z "$2" ]
				then	
					echo "Correct syntax for Compute Node: $0 <controller-ip-address>"
					exit 1;
				else
					crudini --set /etc/nova/nova.conf DEFAULT vncserver_listen 0.0.0.0
					crudini --set /etc/nova/nova.conf DEFAULT novncproxy_base_url http://$2:6080/vnc_auto.html
					sleep 2
					service nova-compute restart
			fi
	fi
		
	echo "Updated Nova Config file for $node_type"
}

case $node_type in
	controller) 
		bash $(dirname $0)/update-etc-hosts.sh $1
		update-nova-config-ip controller
		bash $(dirname $0)/manage-services.sh all restart
		;;
	compute)
		bash $(dirname $0)/update-etc-hosts.sh $1 $2
		update-nova-config-ip compute $2
		bash $(dirname $0)/manage-services.sh all restart
		;;
	networknode)
		bash $(dirname $0)/update-etc-hosts.sh $1 $2
		bash $(dirname $0)/manage-services.sh all restart
		;;
	controller_networknode)
		bash $(dirname $0)/update-etc-hosts.sh $1
		update-nova-config-ip controller
		bash $(dirname $0)/manage-services.sh all restart
		;;
	*)
		echo "Unsupported node type for $0: $node_type"
		exit 1
esac
