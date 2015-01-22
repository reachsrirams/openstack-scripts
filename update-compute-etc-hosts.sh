source install-parameters.sh
if [ $# -lt 4 ]
	then
		echo "Correct syntax: $0 <compute-node-name> <controller_ip_address> <netnode_ip_address>"
		exit 1;
fi
local_ip=`hostname -I`
echo "IP to be configured in /etc/hosts: "$local_ip
bash common/change-ip-in-etc-hosts.sh $1 $local_ip

echo "Adding controller node info to /etc/hosts"
bash common/change-ip-in-etc-hosts.sh $controller_host_name $2

echo "Adding network-node info to /etc/hosts"
bash common/change-ip-in-etc-hosts.sh $network_node_host_name $3

