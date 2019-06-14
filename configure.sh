dir_path=$(dirname $0)
node_type=`bash $dir_path/util/detect-nodetype.sh`
echo "Node Type detected as: $node_type"
echo "Sourcing config-parameters..."
source $dir_path/lib/config-parameters.sh
echo "Management interface: "$mgmt_interface
echo "Data Path interface: "$data_interface
echo "Controller Host Name: "$controller_host_name

bash $dir_path/util/backup-restore-config-files.sh backup $dir_path/config_file_backup/
echo "Backed up Config files"
sleep 5

if [ $# -ne 1 ]
then
       	echo "Correct Syntax: $0 <controller_ip_address>"
	exit 1
fi

if [ "$node_type" == "allinone" ] || [ "$node_type" == "controller" ] 
then
	echo "Executing Update /etc/hosts for Controller"
	sleep 5
	bash $dir_path/util/update-etc-hosts.sh $mgmt_interface $controller_host_name
else
	echo "Executing Update /etc/hosts for Other Nodes"
	sleep 5
	bash $dir_path/util/update-etc-hosts.sh $mgmt_interface $controller_host_name $1
fi

if [ "$node_type" == "allinone" ]
	then
		echo "Configuring packages for All-in-one"
		sleep 5
		bash $dir_path/lib/configure-packages.sh controller $1
		bash $dir_path/lib/configure-packages.sh networknode
		bash $dir_path/lib/configure-packages.sh compute 
elif [ "$node_type" == "compute" ] || [ "$node_type" == "networknode" ]
	then
		echo "Configuring packages for: "$node_type
		sleep 5
		bash $dir_path/lib/configure-packages.sh $node_type 
elif [ "$node_type" == "controller" ] || [ "$node_type" == "controller_networknode" ]
	then
		echo "Configuring packages for Controller and Network Node"
		sleep 5
		bash $dir_path/lib/configure-packages.sh controller $1
else
	echo "Unsupported Node Type for $0: $node_type"
	exit 1;
fi

if [ "$node_type" == "allinone" ] || [ "$node_type" == "controller" ]
	then
		echo "************************************"
		echo "** Execute post-config-actions.sh **"
		echo "************************************"
fi
