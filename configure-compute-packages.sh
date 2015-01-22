source install-parameters.sh
if [ $# -lt 4 ]
	then
		echo "Correct syntax: $0 <data-plane-ip>"
		exit 1;
fi
local_ip=`hostname -I`

echo "About to configure Nova for Compute"
bash compute/configure-nova-compute.sh $controller_host_name $nova_password $rabbitmq_password $local_ip

echo "About to configure Neutron for Compute"
bash compute/configure-neutron-compute.sh $controller_host_name $rabbitmq_password $neutron_password $1
