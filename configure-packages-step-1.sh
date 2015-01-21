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

echo "Restarting MySQL and securing installation..."
service mysql restart;
sleep 5
mysql_secure_installation;


echo "Rabbit MQ: Updating password..."
rabbitmqctl change_password $1 $2
echo "Rabbit MQ: password updated."

		
echo_and_sleep "About to setup KeyStone..." 5
bash controller/configure-keystone.sh $keystone_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password


echo_and_sleep "About to setup Glance..." 5
bash controller/configure-glance.sh $glance_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password $glance_password


echo_and_sleep "About to setup NOVA..."
bash controller/configure-nova.sh $nova_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password $nova_password $rabbitmq_password

