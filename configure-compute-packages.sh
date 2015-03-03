source install-parameters.sh
if [ $# -lt 1 ]
	then
		echo "Correct syntax: $0 <data-plane-interface>"
		exit 1;
fi

compute_ip_address=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "eth0 IP is: $compute_ip_address"
sleep 3

echo_and_sleep "About to configure Kernel Paramters for Compute" 3
bash configure-forwarding-compute.sh

echo_and_sleep "About to configure Nova for Compute" 3
bash configure-nova-compute.sh $controller_host_name $nova_password $rabbitmq_password $compute_ip_address

echo_and_sleep "About to configure Neutron for Compute" 3
bash configure-neutron-compute.sh $controller_host_name $rabbitmq_password $neutron_password $1

metering_secret="password"
echo_and_sleep "About to configure Ceilometer for Compute" 3
bash configure-ceilometer-compute.sh $controller_host_name $rabbitmq_password $neutron_password $metering_secret

