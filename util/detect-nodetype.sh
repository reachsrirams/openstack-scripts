node_type="Unknown"

for package_name in nova-api nova-compute neutron-dhcp-agent
do
	dpkg --list | grep $package_name | grep -q ii
	if [ $? -eq 0 ] && [ $package_name == "nova-api" ]
	then
		node_type="controller"
		break
	elif [ $? -eq 0 ] && [ $package_name == "nova-compute" ]
	then
		node_type="compute"
		break
	elif [ $? -eq 0 ] && [ $package_name == "neutron-dhcp-agent" ]
	then
		node_type="networknode"
		break
	fi
done

echo $node_type
