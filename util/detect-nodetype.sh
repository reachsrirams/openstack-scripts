node_type="Unknown"
nova_api_installed=false
nova_compute_installed=false
neutron_dhcp_installed=false

dpkg --list | grep nova-api | grep -q ii
if [ $? -eq 0 ]
then
	nova_api_installed=true
fi

dpkg --list | grep nova-compute | grep -q ii
if [ $? -eq 0 ]
then
	nova_compute_installed=true
fi

dpkg --list | grep neutron-dhcp-agent | grep -q ii
if [ $? -eq 0 ]
then
	neutron_dhcp_installed=true
fi

if [ $nova_api_installed == "true" ]
then
	node_type="controller"
	if [ $nova_compute_installed == "true" ]
	then
		node_type="allinone"
	fi
elif [ $nova_compute_installed == "true" ]
then
	node_type="compute"
elif [ $neutron_dhcp_installed == "true" ]
then
	node_type="networknode"
fi

echo $node_type
