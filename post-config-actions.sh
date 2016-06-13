echo "Running: $0 $@"
dir_path=$(dirname $0)
node_type=`bash $dir_path/util/detect-nodetype.sh`
echo "Node Type detected as: $node_type"

if [ "$node_type" == "allinone" ] || [ "$node_type" == "controller" ] 
	then
		echo "Setting Up Cirros Image..."
		sleep 5
		bash $dir_path/lib/setup-cirros-image.sh Cirros
		sleep 3
		bash $dir_path/lib/admin_openrc.sh
		echo "About to execute OpenStack commands for some basic Network/Subnet etc"
		neutron net-create network1
		neutron subnet-create network1 20.20.20.0/24 -name subnet1
		sleep 3
		neutron net-create network2
		neutron subnet-create network2 192.168.150.0/24 -name subnet2
else
        echo "This command works only on the controller"
	exit 1
fi

