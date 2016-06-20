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
			ln -s /var/log/nova /var/www/html/oslogs/nova
			ln -s /var/log/neutron /var/www/html/oslogs/neutron
		fi
		echo -n "Do you want to setup Cirros Image? [y/n]: "
		read setup_cirros_image
		if [ "$setup_cirros_image" == "y" ]
		then
			sleep 2
			bash $dir_path/lib/setup-cirros-image.sh Cirros
		fi
		sleep 3
		echo -n "Do you want to setup OpenStack Network and Subnet? [y/n]: "
		read setup_openstack_network
		if [ "$setup_openstack_network" == "y" ]
		then
			source $dir_path/lib/admin_openrc.sh
			echo "About to execute OpenStack commands for some basic Network/Subnet etc"
			neutron net-create network1
			sleep 2
			neutron subnet-create network1 20.20.20.0/24 --name subnet1
			sleep 2
			neutron net-create network2
			sleep 2
			neutron subnet-create network2 192.168.150.0/24 --name subnet2
		fi
else
        echo "This command works only on the controller"
	exit 1
fi

