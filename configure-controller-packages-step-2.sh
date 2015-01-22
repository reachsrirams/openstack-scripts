source install-parameters.sh
if [ -z "$1" ]
	then
		echo "Using default controller host name: "$controller_host_name
	else
		controller_host_name=$1
fi
if [ -z "$2" ]
	then
		echo "Service Tenant ID is a mandatory parameter"
		exit 1;
	else
		service_tenant_id=$2
fi
local_ip=`hostname -I`
echo "IP to be configured in /etc/hosts: "$local_ip
controller_ip_address=$local_ip

echo_and_sleep "About to setup Neutron..." 5
bash controller/configure-neutron.sh $neutron_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password $neutron_password $rabbitmq_password $service_tenant_id

