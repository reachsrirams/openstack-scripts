if [ $# -lt 1 ]
	then
		echo "Correct Syntax: $0 [ common | controller | compute | networknode ]"
		exit 1;
fi

if [ "$1" == "common" ]
	then
		echo "About to install NTP Server"
		sleep 5
		apt-get install ntp -y
		service ntp restart
		
		echo "About to configure Packages for JUNO"
		sleep 5
		apt-get install ubuntu-cloud-keyring -y
		echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu" \
  		"trusty-updates/juno main" > /etc/apt/sources.list.d/cloudarchive-juno.list
		echo "Doing full system update"
		sleep 5
		apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y
		apt-get autoremove -y
fi

if [ "$1" == "controller" ]
	then
		echo "Installing MariaDB..."
		sleep 5
		apt-get install mariadb-server python-mysqldb -y
		
		echo "Installing RabbitMQ..." 
		sleep 5
		apt-get install rabbitmq-server -y
		
		echo "Installing Keystone..."
		sleep 5
		apt-get install keystone python-keystoneclient -y
		
		echo "Installing Glance..."
		sleep 2
		apt-get install glance python-glanceclient -y
		
		echo "Installing Nova..."
		sleep 2
		apt-get install nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient -y
		
		echo "Installing Neutron..."
		sleep 2
		apt-get install neutron-server neutron-plugin-ml2 python-neutronclient -y
		
		echo "Installing Horizon..."
		sleep 2
		apt-get install openstack-dashboard apache2 libapache2-mod-wsgi memcached python-memcache -y
		
		echo "Installing Ceilometer..."
		sleep 2
		apt-get install mongodb-server -y
		apt-get install ceilometer-api ceilometer-collector ceilometer-agent-central ceilometer-agent-notification ceilometer-alarm-evaluator ceilometer-alarm-notifier python-ceilometerclient -y

		apt-get autoremove -y
fi

if [ "$1" == "compute" ]
	then
		echo "About to install Nova for Compute"
		apt-get install nova-compute sysfsutils -y

		echo "About to install Neutron for Compute"
		apt-get install neutron-plugin-ml2 neutron-plugin-openvswitch-agent -y
		
		echo "About to install Ceilometer for Compute"
		apt-get install ceilometer-agent-compute -y
		
		apt-get autoremove -y
fi

if [ "$1" == "networknode" ]
	then
		echo "About to install Neutron for Network Node..."
		sleep 5
		apt-get install neutron-plugin-ml2 neutron-plugin-openvswitch-agent neutron-l3-agent neutron-dhcp-agent neutron-plugin-linuxbridge-agent -y
		apt-get autoremove -y
fi
