if [ $# -lt 5 ]
	then
		echo "Correct Syntax: install-and-update-keystone <keystone-db-password> <mysql-username> <mysql-password> <controller-host-name> <admin-tenant-password>"
		exit 1
fi
echo_and_sleep "Installing Keystone..." 2
apt-get install keystone python-keystoneclient -y
if [ $? -eq 0 ]
	then
		echo "Configuring MySQL for Keystone..."
		mysql_command="CREATE DATABASE IF NOT EXISTS keystone; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$1'; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$1';"
		echo_and_sleep "MySQL DB Command is: "$mysql_command 5
		mysql -u "$2" -p"$3" -e "$mysql_command"

		echo "Configuring Keystone..."
		admin_token_parameter=`openssl rand -hex 10`
		crudini --set /etc/keystone/keystone.conf DEFAULT admin_token $admin_token_parameter
		grep "admin_token" /etc/keystone/keystone.conf
		sleep 5

		crudini --set /etc/keystone/keystone.conf database connection mysql://keystone:$1@$4/keystone
		crudini --set /etc/keystone/keystone.conf token provider keystone.token.providers.uuid.Provider
		crudini --set /etc/keystone/keystone.conf token driver keystone.token.persistence.backends.sql.Token

		echo "Configured KeyStone Conf File"
		grep "mysql" /etc/keystone/keystone.conf
		sleep 5

		echo "Populate Identity Service Database..."
		keystone-manage db_sync

		echo "Restarting KeyStone Service..."
		service keystone restart
		
		echo "Removing KeyStone MySQL-Lite Database..."
		rm -f /var/lib/keystone/keystone.db

		echo "Setting up crontab for Identity Token cleanup..."
		(crontab -l -u keystone 2>&1 | grep -q token_flush) || echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/
keystone-tokenflush.log 2>&1' >> /var/spool/cron/crontabs/keystone	

		echo "Setting environment variables"
		export OS_SERVICE_TOKEN=$admin_token_parameter
		export OS_SERVICE_ENDPOINT=http://$4:35357/v2.0
		source admin_openrc.sh
		echo_and_sleep "Called Source Admin OpenRC" 5

		keystone tenant-create --name admin --description "Admin Tenant"
		keystone user-create --name admin --pass $5 --email admin@example.com
		keystone role-create --name admin
		keystone user-role-add --tenant admin --user admin --role admin

		keystone role-create --name _member_
		keystone user-role-add --tenant admin --user admin --role _member_

		keystone tenant-create --name demo --description "Demo Tenant"
		keystone user-create --name demo --pass password
		keystone user-role-add --tenant demo --user demo --role _member_

		keystone tenant-create --name service --description "Service Tenant"

		keystone service-create --name keystone --type identity --description "OpenStack Identity"
		keystone endpoint-create \
		--service-id $(keystone service-list | awk '/ identity / {print $2}') \
		--publicurl http://$4:5000/v2.0 \
		--internalurl http://$4:5000/v2.0 \
		--adminurl http://$4:35357/v2.0 \
		--region regionOne

		echo_and_sleep "Restarting keystone..." 5
		service keystone restart

		print_keystone_service_list
fi
