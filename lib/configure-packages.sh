source config-parameters.sh
if [ $# -ne 2 ]
	then
		echo "Correct syntax: $0 [ controller | compute | networknode ] <data-plane-interface>"
		exit 1;
fi

if [ "$1" == "compute" ]
	then
		local_ip_address=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
		echo "eth0 IP is: $local_ip_address"
		sleep 3
		
		echo_and_sleep "About to configure Compute"
		bash configure-forwarding.sh compute

		echo_and_sleep "About to configure Nova for Compute" 3
		bash configure-nova-compute.sh $controller_host_name $nova_password $rabbitmq_password $local_ip_address
		
		echo_and_sleep "About to configure Neutron for Compute" 3
		bash configure-neutron.sh compute $controller_host_name $rabbitmq_password $neutron_password $2
		
		metering_secret="password"
		echo_and_sleep "About to configure Ceilometer for Compute" 3
		bash configure-ceilometer.sh compute $controller_host_name $rabbitmq_password $neutron_password $metering_secret
elif [ "$1" == "networknode" ]
	then
		echo_and_sleep "About to configure Network Node"
		bash configure-forwarding.sh networknode

		echo_and_sleep "About to configure Neutron for Network Node" 2
		bash configure-neutron.sh networknode $controller_host_name $rabbitmq_password $neutron_password $2

elif [ "$1" == "controller" ]
	then
		echo_and_sleep "About to configure Controller"	
		local_ip_address=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
		echo "eth0 IP is: $local_ip_address"
		sleep 3
		controller_ip_address=$local_ip_address
		
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
		
		echo_and_sleep "Rabbit MQ: Updating password: $rabbitmq_password"
		rabbitmqctl change_password $rabbitmq_user $rabbitmq_password
		echo_and_sleep "Rabbit MQ: password updated."
		sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
		echo_and_sleep "Configured Guest account in Rabbit MQ" 10
		service rabbitmq-server restart
		
				
		echo_and_sleep "About to setup KeyStone..."
		bash configure-keystone-controller.sh $keystone_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password
		
		
		echo_and_sleep "About to setup Glance..."
		bash configure-glance-controller.sh $glance_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password $glance_password
		
		
		echo_and_sleep "About to setup NOVA..."
		bash configure-nova.sh $nova_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password $nova_password $rabbitmq_password
		
		
		echo_and_sleep "About to setup Neutron..."
		source admin_openrc.sh
		service_tenant_id=`keystone tenant-get service | grep id | cut -d '|' -f3 | tr -s ' '`
		echo_and_sleep "Service Tenant ID is: $service_tenant_id" 10
		bash configure-neutron-controller.sh $neutron_db_password $mysql_user $mysql_password $controller_host_name $admin_tenant_password $neutron_password $rabbitmq_password $service_tenant_id
		
		echo_and_sleep "About to setup Horizon-Dashboard"
		bash configure-horizon-controller.sh $controller_host_name
		
		echo_and_sleep "About to setup Ceilometer..."
		bash configure-ceilometer.sh controller $controller_host_name $rabbitmq_password $neutron_password $metering_secret $ceilometer_db_password
else
	echo "Correct syntax: $0 [ compute | networknode ] <data-plane-interface>"
	exit 1;
fi
