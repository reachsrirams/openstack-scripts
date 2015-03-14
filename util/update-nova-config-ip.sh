echo "Running: $0 $@"

node_type=`bash $(dirname $0)/detect-nodetype.sh`
echo "Local Node Type: $node_type"

eth0_ip=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Local Node IP: $eth0_ip"
sleep 2

crudini --set /etc/nova/nova.conf DEFAULT my_ip $eth0_ip
crudini --set /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address $eth0_ip

if [ "$node_type" == "controller" ]
	then
		crudini --set /etc/nova/nova.conf DEFAULT vncserver_listen $eth0_ip
		sleep 2
		service nova-novncproxy restart
	else
		if [ -z "$1" ]
			then	
				echo "Correct syntax for Compute Node: $0 <controller-ip-address>"
				exit 1;
			else
				crudini --set /etc/nova/nova.conf DEFAULT vncserver_listen 0.0.0.0
				crudini --set /etc/nova/nova.conf DEFAULT novncproxy_base_url http://$1:6080/vnc_auto.html
				sleep 2
				service nova-compute restart
		fi
fi
	
echo "Updated Nova Config file for $node_type"
