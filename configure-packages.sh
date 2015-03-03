source install-parameters.sh
if [ $# -lt 2 ]
	then
		echo "Correct syntax: $0 [ compute | networknode ] <data-plane-interface>"
		exit 1;
fi

if [ "$1" == "networknode" ]
	then
		compute_ip_address=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
		echo "eth0 IP is: $compute_ip_address"
		sleep 3
		
		echo_and_sleep "About to configure forwarding" 2
		bash configure-forwarding.sh compute

		echo_and_sleep "About to configure Nova for Compute" 3
		bash configure-nova-compute.sh $controller_host_name $nova_password $rabbitmq_password $compute_ip_address
		
		echo_and_sleep "About to configure Neutron for Compute" 3
		bash configure-neutron-compute.sh $controller_host_name $rabbitmq_password $neutron_password $1
		
		metering_secret="password"
		echo_and_sleep "About to configure Ceilometer for Compute" 3
		bash configure-ceilometer-compute.sh $controller_host_name $rabbitmq_password $neutron_password $metering_secret
fi


if [ "$1" == "networknode" ]
	then
		echo_and_sleep "About to configure forwarding" 2
		bash configure-forwarding.sh networknode

		echo_and_sleep "About to configure Neutron for Network Node" 2
		bash configure-neutron-networknode.sh $controller_host_name $rabbitmq_password $neutron_password $2
fi
