source install-parameters.sh
if [ $# -lt 1 ]
	then
		echo "Correct syntax: $0 <data-plane-interface>"
		exit 1;
fi

echo_and_sleep "About to configure sysctl" 2
bash networknode/configure-kernel-parameters.sh

echo_and_sleep "About to configure Neutron for Network Node" 2
bash networknode/configure-neutron-networknode.sh $controller_host_name $rabbitmq_password $neutron_password $1
