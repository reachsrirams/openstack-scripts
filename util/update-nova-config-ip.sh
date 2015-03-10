if [ $# -lt 1 ]
	then
		echo "Correct syntax: $0 [ controller | compute ] <controller_ip>"
		exit 1;
fi
eth0_ip=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "eth0 IP Address: $eth0_ip"
sleep 2
crudini --set /etc/nova/nova.conf DEFAULT my_ip $eth0_ip
crudini --set /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address $eth0_ip
if [ "$1" == "controller" ]
	then
		crudini --set /etc/nova/nova.conf DEFAULT vncserver_listen $eth0_ip
		sleep 3
		service nova-novncproxy restart
	else
		if [ -z "$2" ]
			then	
				echo "Controller IP required to configure Compute Nova"
				exit 1;
			else
				crudini --set /etc/nova/nova.conf DEFAULT vncserver_listen 0.0.0.0
				crudini --set /etc/nova/nova.conf DEFAULT novncproxy_base_url http://$2:6080/vnc_auto.html
				service nova-compute restart
		fi
fi
	
echo "Upadted Nova Config file with Correct IP Addresses"
