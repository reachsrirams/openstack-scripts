source install-parameters.sh
if [ $# -lt 4 ]
	then
		echo "Correct syntax: $0 <compute-node-name> <compute-node-ip> <controller_ip> <netnode_ip>"
		exit 1;
fi
echo "IP to be configured in /etc/hosts: "$2
bash change-ip-in-etc-hosts.sh $1 $2

echo "Adding controller node info to /etc/hosts"
bash change-ip-in-etc-hosts.sh $controller_host_name $3

echo "Adding network-node info to /etc/hosts"
bash change-ip-in-etc-hosts.sh $network_node_host_name $4

