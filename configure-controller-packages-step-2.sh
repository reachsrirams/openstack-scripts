source install-parameters.sh
if [ -z "$1" ]
	then
		echo "Using default controller host name: "$controller_host_name
	else
		controller_host_name=$1
fi
if [ -z "$2" ]
	then
		service_tenant_id=`keystone tenant-get service | grep id | cut -d '|' -f3 | tr -s ' '
		echo_and_sleep "Service Tenant ID is: "$service_tenant_id 10
	else
		service_tenant_id=$2
fi

echo_and_sleep "About to setup Neutron..." 5
bash controller/configure-neutron.sh $neutron_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password $neutron_password $rabbitmq_password $service_tenant_id

echo_and_sleep "About to setup Ceilometer..." 5
bash controller/configure-ceilometer-controller.sh $ceilometer_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password $ceilometer_password $rabbitmq_password $ceilometer_password

