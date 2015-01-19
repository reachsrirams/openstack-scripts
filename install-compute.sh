source install-parameters.sh
if [ $# -lt 4 ]
	then
		echo "Correct syntax: install-compute <compute-node-name> <controller_ip_address> <netnode_ip_address> <data-plane-ip>"
		exit 1;
fi
local_ip=`hostname -I`
echo "IP to be configured in /etc/hosts: "$local_ip
bash common/change-ip-in-etc-hosts.sh $1 $local_ip

echo "Adding controller node info to /etc/hosts"
bash common/change-ip-in-etc-hosts.sh $controller_host_name $2

echo "Adding network-node info to /etc/hosts"
bash common/change-ip-in-etc-hosts.sh $network_node_host_name $3

echo "About to setup NTP..."
bash common/install-and-update-ntp.sh

echo "About to configure OpenStack packages..."
bash common/install-and-update-openstack-packages.sh

echo "About to configure Nova..."
bash compute/install-and-update-nova.sh $controller_host_name $nova_password $rabbitmq_password $local_ip

echo "About to configure Neutron..."
bash compute/install-and-update-neutron.sh $controller_host_name $rabbitmq_password $neutron_password $4

