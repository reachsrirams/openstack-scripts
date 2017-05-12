echo "Running: $0 $@"

node_type=`bash $(dirname $0)/detect-nodetype.sh`
echo "Node Type detected as: $node_type"
sleep 3

if [ $# -lt 2 ]
	then
		echo "Correct Syntax: $0 <mgmt-interface-name> <controller-host-name> <controller-ip-address>"
		echo "Second parameter required only for Network and Compute Node"
		exit 1;
fi

function get-ip-address() {
        ip_address_val=''
        ubuntu_version=`lsb_release -sr`
        if [ "$ubuntu_version" == "17.04" ]
        then
                ip_address_val=`ifconfig $1 | grep 'inet ' | cut -d' ' -f10 | awk '{ print $1}'`
        elif [ "$ubuntu_version" == "16.04" ]
        then
                ip_address_val=`ifconfig $1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
        else
                echo "This release is supported only on Zesty (17.04) or Xenial (16.04)"
                exit 1;
        fi
        echo $ip_address_val
}

function update-nova-config-ip() {
	mgmg_interface_ip=$(get-ip-address $1)
	echo "Local Node IP: $mgmg_interface_ip"
	sleep 2

	crudini --set /etc/nova/nova.conf DEFAULT my_ip $mgmg_interface_ip
	crudini --set /etc/nova/nova.conf vnc vncserver_proxyclient_address $mgmg_interface_ip

	if [ "$2" == "controller" ]
		then
			crudini --set /etc/nova/nova.conf vnc vncserver_listen $mgmg_interface_ip
			sleep 2
			service nova-novncproxy restart
		else
			if [ -z "$3" ]
				then	
					echo "Correct syntax for Compute Node: $0 <mgmt-interface> compute <controller-ip-address>"
					exit 1;
				else
					crudini --set /etc/nova/nova.conf vnc vncserver_listen 0.0.0.0
					crudini --set /etc/nova/nova.conf vnc novncproxy_base_url http://$3:6080/vnc_auto.html
					sleep 2
					service nova-compute restart
			fi
	fi
		
	echo "Updated Nova Config file for $node_type"
}

case $node_type in
	controller) 
		bash $(dirname $0)/update-etc-hosts.sh $1 $2
		update-nova-config-ip $1 controller
		bash $(dirname $0)/manage-services.sh all restart
		;;
	compute)
		bash $(dirname $0)/update-etc-hosts.sh $1 $2 $3
		update-nova-config-ip $1 compute $3
		bash $(dirname $0)/manage-services.sh all restart
		;;
	networknode)
		bash $(dirname $0)/update-etc-hosts.sh $1 $2 $3
		bash $(dirname $0)/manage-services.sh all restart
		;;
	*)
		echo "Unsupported node type for $0: $node_type"
		exit 1
esac
