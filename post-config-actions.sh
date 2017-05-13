echo "Running: $0 $@"
dir_path=$(dirname $0)
node_type=`bash $dir_path/util/detect-nodetype.sh`
echo "Node Type detected as: $node_type"

if [ "$node_type" == "allinone" ] || [ "$node_type" == "controller" ] 
	then
		echo -n "Do you want to enable Web based access to Logs? [y/n]: "
		read enable_web_log_view
		if [ "$enable_web_log_view" == "y" ]
		then
			mkdir /var/www/html/oslogs
			chmod a+rx /var/log/nova
			chmod a+rx /var/log/neutron
			chmod a+rx /var/log/apache2
			chmod a+rx /var/log/keystone
			ln -s /var/log/nova /var/www/html/oslogs/nova
			ln -s /var/log/neutron /var/www/html/oslogs/neutron
			ln -s /var/log/apache2 /var/www/html/oslogs/apache2
			ln -s /var/log/keystone /var/www/html/oslogs/keystone
			echo "Visit http://<controller_ip>/oslogs"
		fi
		echo -n "Do you want to setup Cirros Image? [y/n]: "
		read setup_cirros_image
		if [ "$setup_cirros_image" == "y" ]
		then
			sleep 2
			bash $dir_path/lib/setup-cirros-image.sh Cirros
			sleep 2
		fi
		echo -n "Do you want to setup a Flavor to start instances? [y/n]: "
		read setup_flavor
		if [ "$setup_flavor" == "y" ]
		then
			source $dir_path/lib/admin_openrc.sh
			echo "Setting up Flavor called 'myflavor' with 1 vCPU, 256MB RAM and 500MB disk"
			sleep 1
			openstack flavor create --public myflavor --id auto --ram 256 --disk 1 --vcpus 1 --rxtx-factor 1
			sleep 1

		fi
		echo -n "Do you want to setup OpenStack Network, Subnet and Router? [y/n]: "
		read setup_openstack_network
		if [ "$setup_openstack_network" == "y" ]
		then
			source $dir_path/lib/admin_openrc.sh
			echo "About to execute OpenStack commands for some basic Network/Subnet/Router etc"
			openstack network create network1
			sleep 2
			openstack subnet create --network network1 --subnet-range 20.20.20.0/24 subnet1
			sleep 2
			openstack network create network2
			sleep 2
			openstack subnet create --network network2 --subnet-range 192.168.150.0/24 subnet2
			echo "About to create Router and Add Subnets"
			sleep 2
			openstack router create router1
			sleep 2
			openstack router add subnet router1 subnet1
			sleep 2
			openstack router add subnet router1 subnet2
		fi
else
        echo "This command works only on the controller"
	exit 1
fi

