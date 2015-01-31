source install-parameters.sh
if [ $# -lt 4 ]
	then
		echo "Correct syntax: $0 <compute-hostname> <compute-node-ip>"
		exit 1;
fi
local_ip=`hostname -I`
echo "IP to be configured in /etc/hosts: "$local_ip
controller_ip_address=$local_ip

echo_and_sleep "Adding controller node info to /etc/hosts" 
sh change-ip-in-etc-hosts.sh $controller_host_name $controller_ip_address

echo_and_sleep "Adding network-node info to /etc/hosts" 
sh change-ip-in-etc-hosts.sh $network_node_host_name $network_node_ip_address

echo "Adding compute node info to /etc/hosts"
bash change-ip-in-etc-hosts.sh $1 $2


