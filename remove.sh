function stop-controller-services() {
	service apache2 stop
}

function remove-common-packages() {
	apt-get purge chrony -y
	apt-get purge python-openstackclient -y
	ubuntu_version=`lsb_release -sr`
        if [ "$ubuntu_version" == "14.04" ]
        then
		echo "About to remove cloud-archive:mitaka"
		sleep 2
		add-apt-repository --remove cloud-archive:mitaka
		sleep 2
	fi
	echo "Doing full system update"
        sleep 2
        apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y
        apt-get autoremove -y
	
}

function remove-compute-packages() {
	echo "About to remove packages for Compute Node"
	sleep 2
	apt-get purge nova-compute sysfsutils -y
	apt-get purge neutron-plugin-linuxbridge-agent conntrack -y
	apt-get purge ceilometer-agent-compute -y
	apt-get autoremove -y
}

function remove-controller-packages() {
	stop-controller-services
	echo "About to remove packages for Controller Node"
	sleep 2
	apt-get purge mariadb-server python-mysqldb -y
	apt-get purge rabbitmq-server -y
	apt-get purge keystone python-keystoneclient -y
	apt-get purge glance python-glanceclient -y
	apt-get purge nova-api nova-cert nova-conductor nova-consoleauth \
	nova-novncproxy nova-scheduler python-novaclient -y
	apt-get purge neutron-server neutron-plugin-ml2 python-neutronclient neutron-linuxbridge-agent neutron-dhcp-agent -y
	apt-get purge cinder-api cinder-scheduler python-cinderclient -y
	apt-get purge openstack-dashboard apache2 libapache2-mod-wsgi \
	memcached python-memcache -y
	apt-get purge mongodb-server mongodb-clients python-pymongo -y
	apt-get purge ceilometer-api ceilometer-collector ceilometer-agent-central \
	ceilometer-agent-notification ceilometer-alarm-evaluator \
	ceilometer-alarm-notifier python-ceilometerclient -y
	apt-get autoremove -y
}

function remove-networknode-packages() {
	echo "About to remove packages for Network Node"
	sleep 2
	apt-get purge neutron-plugin-ml2 neutron-plugin-openvswitch-agent \
	neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent -y
	apt-get autoremove -y
}


node_type=`bash $(dirname $0)/util/detect-nodetype.sh`
echo "Node Type detected as: $node_type"
sleep 5
case $node_type in
	allinone)
		remove-controller-packages
		remove-compute-packages
		remove-networknode-packages
		;;
	controller)
		remove-controller-packages
		;;
	compute)
		remove-compute-packages
		;;
	networknode)
		remove-networknode-packages
		;;
	controller_networknode)
		remove-controller-packages
		remove-networknode-packages
		;;
	*)
		echo "Unsupported Node type for $0: $node_type"
		exit 1;
esac
remove-common-packages
