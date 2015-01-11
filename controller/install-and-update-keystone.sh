if [ $# -lt 5]
	then
		echo "Correct Syntax: install-and-update-keystone <keystone-db-password> <mysql-username> <mysql-password> <controller-host-name> <admin-tenant-password>"
		exit 1
fi
echo "Installing Keystone..."
sleep 2
apt-get install keystone python-keystoneclient -y
if [ $? eq 0 ]
	then
		echo "Configuring MySQL for Keystone..."
		mysql -u "$2" -p"$3" <<EOF
		CREATE DATABASE keystone;
		GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$1';
		GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$1';
		EOF

		echo "Configuring Keystone..."
		ADMIN-TOKEN=`openssl rand -hex 10`
		crudini --set /etc/keystone/keystone.conf DEFAULT admin_token $ADMIN-TOKEN
		crudini --set /etc/keystone/keystone.conf database connection mysql://keystone:$1@$4/keystone
		crudini --set /etc/keystone/keystone.conf token provider keystone.token.providers.uuid.Provider
		crudini --set /etc/keystone/keystone.conf token driver keystone.token.persistence.backends.sql.Token

		echo "Populate Identity Service Database..."
		su -s /bin/sh -c "keystone-manage db_sync" keystone

		echo "Restarting KeyStone Service..."
		service keystone restart
		
		echo "Removing KeyStone MySQL-Lite Database..."
		rm -f /var/lib/keystone/keystone.db

		echo "Setting up crontab for Identity Token cleanup..."
		(crontab -l -u keystone 2>&1 | grep -q token_flush) || echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/
keystone-tokenflush.log 2>&1' >> /var/spool/cron/crontabs/keystone	

		echo "Setting environment variables"
		export OS_SERVICE_TOKEN=$ADMIN_TOKEN
		export OS_SERVICE_ENDPOINT=http://$4:35357/v2.0

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

		echo "Restarting keystone..."
		sleep 10
		service keystone restart

		export OS_TENANT_NAME=admin
		export OS_USERNAME=admin
		export OS_PASSWORD=$5
		export OS_AUTH_URL=http://$4:35357/v2.0
		
fi
