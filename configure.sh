function is-networknode() {
	neutron_dhcp_installed=false
	dpkg --list | grep neutron-dhcp-agent | grep -q ii
	if [ $? -eq 0 ]
	then
        	neutron_dhcp_installed=true
	fi
	echo $neutron_dhcp_installed
}

dir_path=$(dirname $0)
node_type=`bash $dir_path/util/detect-nodetype.sh`
echo "Node Type detected as: $node_type"

is_networknode=`is-networknode`
echo "Is Network Node: "$is_networknode

if [ "$node_type" == "allinone" ]
	then
		echo "Configuring packages for All-in-one"
		sleep 5
		bash $dir_path/lib/configure-packages.sh controller 
		bash $dir_path/lib/configure-packages.sh networknode
		bash $dir_path/lib/configure-packages.sh compute 
elif [ "$node_type" == "controller" ] || [ "$node_type" == "compute" ] 
	then
		echo "Configuring packages for: "$node_type
		sleep 5
		bash $dir_path/lib/configure-packages.sh $node_type 
		if [ "$is_networknode" == "true" ]
		then
			echo "Seems to be $node_type and a Network Node"
			sleep 5
			bash $dir_path/lib/configure-packages.sh networknode
		fi
elif [ "$node_type" == "networknode" ]
	then
		echo "Configuring packages for: "$node_type
		sleep 5
		bash $dir_path/lib/configure-packages.sh $node_type 
elif [ "$node_type" == "controller_networknode" ]
	then
		echo "Configuring packages for Controller and Network Node"
		sleep 5
		bash $dir_path/lib/configure-packages.sh controller 
		bash $dir_path/lib/configure-packages.sh networknode
else
	echo "Unsupported Node Type for $0: $node_type"
	exit 1;
fi

