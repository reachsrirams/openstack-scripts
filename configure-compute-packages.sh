source install-parameters.sh
if [ $# -lt 2 ]
	then
		echo "Correct syntax: $0 <compute-ip> <data-plane-interface>"
		exit 1;
fi

echo_and_sleep "About to configure Kernel Paramters for Compute" 3
bash compute/configure-kernel-parameters.sh

echo_and_sleep "About to configure Nova for Compute" 3
bash compute/configure-nova-compute.sh $controller_host_name $nova_password $rabbitmq_password $1

echo_and_sleep "About to configure Neutron for Compute" 3
bash compute/configure-neutron-compute.sh $controller_host_name $rabbitmq_password $neutron_password $2

metering_secret="password"
echo_and_sleep "About to configure Ceilometer for Compute" 3
bash compute/configure-ceilometer-compute.sh $controller_host_name $rabbitmq_password $neutron_password $metering_secret
