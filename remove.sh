if [ $# -lt 1 ]
	then
		echo "Correct Syntax: $0 [ controller | compute | networknode ]"
		exit 1;
fi

if [ "$1" == "controller" ]
	then
		apt-get purge mariadb-server python-mysqldb -y
		apt-get purge rabbitmq-server -y
		apt-get purge keystone python-keystoneclient -y
		apt-get purge glance python-glanceclient -y
		apt-get purge nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient -y
		apt-get purge neutron-server neutron-plugin-ml2 python-neutronclient -y
		apt-get purge openstack-dashboard apache2 libapache2-mod-wsgi memcached python-memcache -y
		apt-get purge mongodb-server -y
		apt-get purge ceilometer-api ceilometer-collector ceilometer-agent-central ceilometer-agent-notification ceilometer-alarm-evaluator ceilometer-alarm-notifier python-ceilometerclient -y
		apt-get autoremove -y
elif [ "$1" == "compute" ]
	then
		echo "About to remove packages for Compute Node"
		sleep 2
		apt-get purge nova-compute sysfsutils -y
		apt-get purge neutron-plugin-ml2 neutron-plugin-openvswitch-agent -y
		apt-get purge ceilometer-agent-compute -y
		apt-get autoremove -y
elif [ "$1" == "networknode" ]
	then
		echo "About to remove packages for Network Node"
		sleep 2
		apt-get purge neutron-plugin-ml2 neutron-plugin-openvswitch-agent neutron-l3-agent neutron-dhcp-agent neutron-plugin-linuxbridge-agent -y
		apt-get autoremove -y
else
	echo "Correct Syntax: $0 [ controller | compute | networknode ]"
	exit 1;
fi
