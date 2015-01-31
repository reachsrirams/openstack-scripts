source install-parameters.sh
if [ $# -lt 4 ]
	then
		echo "Correct syntax: $0 <networknode-ip> <controller-ip> <compute-node-name> <compute_ip_address>"
		exit 1;
fi
echo "Adding network node info to /etc/hosts"
bash change-ip-in-etc-hosts.sh $network_node_host_name $1

echo "Adding controller node info to /etc/hosts"
bash change-ip-in-etc-hosts.sh $controller_host_name $2

echo "Adding compute node info to /etc/hosts"
bash change-ip-in-etc-hosts.sh $3 $4

