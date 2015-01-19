source install-parameters.sh
if [ -z $1 ]
	then
		echo "Using default controller host name: "$controller_host_name
	else
		controller_host_name = $1
fi
local_ip=`hostname -I`
echo "IP to be configured in /etc/hosts: "$local_ip
controller_ip_address=$local_ip

echo_and_sleep "About to setup KeyStone..." 5
bash controller/install-and-update-keystone.sh $keystone_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password

echo_and_sleep "About to setup Glance..." 5
bash controller/install-and-update-glance.sh $glance_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password $glance_password

echo_and_sleep "About to setup NOVA..."
bash controller/install-and-update-nova.sh $nova_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password $nova_password $rabbitmq_password

