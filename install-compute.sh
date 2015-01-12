source ./install-parameters.sh
if [ $# -lt 2 ]
	then
		echo "Correct syntax: install-compute <compute-node-name> <data-plane-ip>"
		exit 1;
fi
local_ip = hostname -I
echo "IP to be configured in /etc/hosts: "$local_ip
sleep $sleep_duration
sh common/change-ip-in-etc-hosts.sh $1 $local_ip

echo "Adding controller node info to /etc/hosts"
sleep $sleep_duration
sh common/change-ip-in-etc-hosts.sh $controller_host_name $controller_ip_address

echo "Adding network-node info to /etc/hosts"
sleep $sleep_duration
sh common/change-ip-in-etc-hosts.sh $network_node_host_name $network_node_ip_address

echo "About to setup NTP..."
sleep $sleep_duration
sh common/install-and-update-ntp.sh

echo "About to configure OpenStack packages..."
sleep $sleep_duration
sh common/install-and-update-openstack-packages.sh

echo "About to configure Nova..."
sleep $sleep_duration
sh compute/install-and-update-nova.sh $controller_host_name $nova_password $rabbitmq_password $local_ip

echo "About to configure Neutron..."
sleep $sleep_duration
sh compute/install-and-update-neutron.sh $controller_host_name $rabbitmq_password $neutron_password $data-plane-ip

