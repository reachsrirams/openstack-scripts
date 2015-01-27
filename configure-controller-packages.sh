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

echo "Updating MySQL Config File..."
sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/my.cnf
echo_and_sleep "Updated Bind Address" 2
grep "bind" /etc/mysql/my.cnf

sed -i "/\[mysqld\]/a default-storage-engine = innodb\\
		innodb_file_per_table\\
		collation-server = utf8_general_ci\\
		init-connect = 'SET NAMES utf8'\\
		character-set-server = utf8\\
" /etc/mysql/my.cnf
echo_and_sleep "Updated other MySQL Parameters" 2
grep "storage-engine" /etc/mysql/my.cnf

echo_and_sleep "Restarting MySQL and securing installation..."
service mysql restart;
sleep 10
mysql_secure_installation;


echo_and_sleep "Rabbit MQ: Updating password..."
rabbitmqctl change_password $rabbitmq_user $rabbitmq_password
echo_and_sleep "Rabbit MQ: password updated."

		
echo_and_sleep "About to setup KeyStone..."
bash controller/configure-keystone.sh $keystone_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password


echo_and_sleep "About to setup Glance..."
bash controller/configure-glance.sh $glance_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password $glance_password


echo_and_sleep "About to setup NOVA..."
bash controller/configure-nova.sh $nova_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password $nova_password $rabbitmq_password

if [ -z "$2" ]
	then
		service_tenant_id=`keystone tenant-get service | grep id | cut -d '|' -f3 | tr -s ' '`
		echo_and_sleep "Service Tenant ID is: "$service_tenant_id 10
	else
		service_tenant_id=$2
fi

echo_and_sleep "About to setup Neutron..."
bash controller/configure-neutron.sh $neutron_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password $neutron_password $rabbitmq_password $service_tenant_id

echo_and_sleep "About to setup Horizon-Dashboard"
bash controller/configure-horizon.sh $controller_ip_address

echo_and_sleep "About to setup Ceilometer..."
bash controller/configure-ceilometer-controller.sh $ceilometer_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password $ceilometer_password $rabbitmq_password $ceilometer_password

