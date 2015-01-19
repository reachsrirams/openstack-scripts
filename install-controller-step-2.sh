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

echo "About to setup Maria DB..."
sh controller/install-and-update-database.sh

echo "About to setup RabbitMQ..."
sh controller/install-and-update-rabbitmq.sh $rabbitmq_user $rabbitmq_password

echo "About to setup KeyStone..."
sh controller/install-and-update-keystone.sh $keystone_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password

echo "About to setup Glance..."
sh controller/install-and-update-glance.sh $glance_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password $glance_password

echo "About to setup NOVA..."
sh controller/install-and-update-nova.sh $nova_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password $nova_password $rabbitmq_password

