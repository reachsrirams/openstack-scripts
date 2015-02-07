ource install-parameters.sh
if [ $# -lt 1 ]
        then
                echo "Correct syntax: $0 <controller-ip>"
                exit 1;
fi

netnode_ip_address=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "eth0 IP is: $netnode_ip_address"
sleep 3

echo "Updating network node IP address to /etc/hosts"
bash change-ip-in-etc-hosts.sh $network_node_host_name $netnode_ip_address

echo "Updating controller IP address to /etc/hosts"
bash change-ip-in-etc-hosts.sh $controller_host_name $1
