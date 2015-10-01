function install-common-packages() {
	echo "About to install crudini"
	apt-get install crudini -y
	sleep 3

	echo "About to install NTP Server"
	sleep 3
	apt-get install ntp -y
	service ntp restart
	
	echo "About to configure Packages for KILO"
	sleep 3
	apt-get install ubuntu-cloud-keyring -y
	echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu" \
  	"trusty-updates/kilo main" > /etc/apt/sources.list.d/cloudarchive-kilo.list
	echo "Doing full system update"
	sleep 3
	apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y
	apt-get autoremove -y
}

function install-controller-packages() {
	echo "Installing MariaDB..."
	sleep 3
	apt-get install mariadb-server python-mysqldb -y
	
	echo "Installing RabbitMQ..." 
	sleep 3
	apt-get install rabbitmq-server -y
	
	echo "Installing Keystone..."
	sleep 3
	apt-get install keystone python-keystoneclient -y
	
	echo "Installing Glance..."
	sleep 2
	apt-get install glance python-glanceclient -y
	
	echo "Installing Nova for Controller"
	sleep 2
	apt-get install nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient -y
	
	echo "Installing Neutron for Controller"
	sleep 2
	apt-get install neutron-server neutron-plugin-ml2 python-neutronclient -y
	
	echo "Installing Horizon..."
	sleep 2
	apt-get install openstack-dashboard apache2 libapache2-mod-wsgi memcached python-memcache -y
	
	echo "Installing Ceilometer for Controller"
	sleep 2
	apt-get install mongodb-server -y
	sleep 2
	apt-get install ceilometer-api ceilometer-collector ceilometer-agent-central ceilometer-agent-notification ceilometer-alarm-evaluator ceilometer-alarm-notifier python-ceilometerclient -y

	apt-get autoremove -y
}

function install-compute-packages() {
	echo "About to install Nova for Compute"
	sleep 3
	apt-get install nova-compute sysfsutils -y

	echo "About to install Neutron for Compute"
	sleep 2
	apt-get install neutron-plugin-ml2 neutron-plugin-openvswitch-agent -y
	
	echo "About to install Ceilometer for Compute"
	sleep 2
	apt-get install ceilometer-agent-compute -y
	
	apt-get autoremove -y
}

function install-networknode-packages() {
	echo "About to install Neutron for Network Node..."
	sleep 2
	apt-get install neutron-plugin-ml2 neutron-plugin-openvswitch-agent neutron-l3-agent neutron-dhcp-agent -y
	apt-get autoremove -y
}



if [ $# -ne 2 ]
	then
		echo "Correct Syntax: $0 [ allinone | controller | compute | networknode | controller_networknode | common ] [ juno | kilo ]"
		exit 1;
fi

if [ "$1" == "allinone" ]
	then
		echo "Installing packages for All-in-One"
		sleep 5
		install-common-packages $2
		install-controller-packages
		install-compute-packages
		install-networknode-packages
elif [ "$1" == "controller" ] || [ "$1" == "compute" ] || [ "$1" == "networknode" ]
	then
		install-common-packages $2
		echo "Installing packages for: "$1
		sleep 5
		install-$1-packages
elif [ "$1" == "controller_networknode" ]
	then
		echo "Installing packages for Controller and Network Node"
		sleep 5
		install-common-packages $2
		install-controller-packages
		install-networknode-packages
elif [ "$1" == "common" ]
	then
		echo "Installing common packages"
		sleep 5
		install-common-packages $2
else
	
	echo "Correct Syntax: $0 [ allinone | controller | compute | networknode | controller_networknode | common ]"
	exit 1;
fi

