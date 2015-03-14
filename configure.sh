node_type=`bash $(dirname $0)/detect-nodetype.sh`
echo "Node Type detected as: $node_type"

if [ "$node_type" == "allinone" ]
	then
		echo "Configuring packages for All-in-one"
		sleep 5
		bash lib/configure-packages.sh controller 
		bash lib/configure-packages.sh networknode
		bash lib/configure-packages.sh compute 
elif [ "$node_type" == "controller" ] || [ "$node_type" == "compute" ] || [ "$node_type" == "networknode" ]
	then
		echo "Configuring packages for: "$node_type
		sleep 5
		bash lib/configure-packages.sh $node_type 
elif [ "$node_type" == "controller_networknode" ]
	then
		echo "Configuring packages for Controller and Network Node"
		sleep 5
		bash lib/configure-packages.sh controller 
		bash lib/configure-packages.sh networknode
else
	echo "Unsupported Node Type for $0: $node_type"
	exit 1;
fi
