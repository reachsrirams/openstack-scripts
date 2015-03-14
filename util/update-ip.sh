echo "Running: $0 $@"

node_type=`bash $(dirname $0)/detect-nodetype.sh`
echo "Node Type detected as: $node_type"

if [ $# -lt 1 ]
	then
		echo "Correct Syntax: $0 <controller-host-name> <controller-ip-address>"
		echo "Second parameter required only for Network and Compute Node"
		exit 1;
fi

case $node_type in
	controller) 
		bash $(dirname $0)/update-etc-hosts.sh $1
		bash $(dirname $0)/update-nova-config-ip.sh
		bash $(dirname $0)/restart.sh 
		;;
	compute)
		bash $(dirname $0)/update-etc-hosts.sh $1 $2
		bash $(dirname $0)/update-nova-config-ip.sh $2
		bash $(dirname $0)/restart.sh 
		;;
	networknode)
		bash $(dirname $0)/update-etc-hosts.sh $1 $2
		bash $(dirname $0)/restart.sh 
		;;
	*)
		echo "Unsupported node type for $0: $node_type"
		exit 1
esac
