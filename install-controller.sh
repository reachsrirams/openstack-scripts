source install-parameters.sh
if [ -z $1 ]
	then
		echo "Using default controller host name: "$controller_host_name
	else
		controller_host_name = $1
fi
local_ip=`hostname -I`
echo "IP to be configured in /etc/hosts: "$local_ip
controller_ip=$local_ip

echo "Adding controller node info to /etc/hosts"
sleep $sleep_duration
sh common/change-ip-in-etc-hosts.sh $controller_host_name $controller_ip_address

echo "Adding network-node info to /etc/hosts"
sleep $sleep_duration
sh common/change-ip-in-etc-hosts.sh $network_node_host_name $network_node_ip_address

echo "About to setup NTP..."
sleep $sleep_duration
sh common/install-and-update-ntp.sh

echo "About to configure OpenStack packages..."
sleep $sleep_duration
sh common/install-and-update-openstack-packages.sh

echo "About to setup Maria DB..."
sleep $sleep_duration
sh controller/install-and-update-database.sh $local_ip

echo "About to setup RabbitMQ..."
sleep $sleep_duration
sh controller/install-and-update-rabbitmq.sh $rabbitmq_user $rabbitmq_password

echo "About to setup KeyStone..."
sleep $sleep_duration
sh controller/install-and-update-keystone.sh $keystone_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password

echo "About to setup Glance..."
sleep $sleep_duration
sh controller/install-and-update-glance.sh $glance_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password $glance_password

echo "About to setup NOVA..."
sleep $sleep_duration
sh controller/install-and-update-glance.sh $nova_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password $nova_password $rabbitmq_password

