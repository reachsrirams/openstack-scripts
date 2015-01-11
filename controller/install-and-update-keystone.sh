if [ $# -lt 4]
	then
		echo "Correct Syntax: install-and-update-keystone <keystone-db-password> <mysql-username> <mysql-password> <controller-host-name>"
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
		crudini --set /etc/keystone/keystone.conf DEFAULT admin_token $1
		crudini --set /etc/keystone/keystone.conf database connection mysql://keystone:$1@$4/keystone
		crudini --set /etc/keystone/keystone.conf token provider keystone.token.providers.uuid.Provider
		crudini --set /etc/keystone/keystone.conf token driver keystone.token.persistence.backends.sql.Token
fi
