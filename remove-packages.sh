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
		apt-get autoremove -y
fi

if [ "$1" == "compute" ]
	then
		apt-get purge nova-compute sysfsutils -y
		apt-get purge neutron-plugin-ml2 neutron-plugin-openvswitch-agent -y
		apt-get autoremove -y
fi
