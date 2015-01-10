if [ $# -lt 3 ]
	then
		echo "Correct syntax: $0 <controller-host-name> <rabbitmq-password> <neutron-password> <dataplane-ip>"
		exit 1;
fi

echo "Installing Neutron for Compute node..."
sleep 2
apt-get install neutron-plugin-ml2 neutron-plugin-openvswitch-agent

neutron-conf-file="/etc/neutron/neutron.conf"

configure-neutron-conf $1 $2 $3

function configure-neutron-conf
{
	echo "Updating neutron.conf DEFAULT section..."
	crudini --set $neutron-conf-file DEFAULT rabbit_host $1
	crudini --set $neutron-conf-file DEFAULT rabbit_password $2
	crudini --set $neutron-conf-file DEFAULT auth_strategy keystone
	echo "Updating neutron.conf keystone_authtoken section..."
	crudini --set $neutron-conf-file keystone_authtoken auth_uri http://$1:5000/v2.0
	crudini --set $neutron-conf-file keystone_authtoken identity_url http://$1:35357
	crudini --set $neutron-conf-file keystone_authtoken admin_tenant_name service
	crudini --set $neutron-conf-file keystone_authtoken admin_user neutron
	crudini --set $neutron-conf-file keystone_authtoken admin_password $3
	
}

