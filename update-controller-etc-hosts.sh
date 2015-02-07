source install-parameters.sh
if [ $# -lt 2 ]
        then
                echo "You can also use the syntax: $0 <compute-hostname> <compute-node-ip>"
fi
local_ip=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "eth0 IP is: $local_ip"
sleep 3
controller_ip_address=$local_ip

echo_and_sleep "Adding controller node info to /etc/hosts"
sh change-ip-in-etc-hosts.sh $controller_host_name $controller_ip_address

echo_and_sleep "Adding network-node info to /etc/hosts"
sh change-ip-in-etc-hosts.sh $network_node_host_name $network_node_ip_address

if [ $# -eq 2 ]
        then
                echo "Adding compute node info to /etc/hosts"
                bash change-ip-in-etc-hosts.sh $1 $2
fi

