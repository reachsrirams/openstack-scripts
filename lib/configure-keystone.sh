echo "Running: $0 $@"
source $(dirname $0)/config-parameters.sh
if [ $# -lt 5 ]
	then
		echo "Correct Syntax: $0 <keystone-db-password> <mysql-username> <mysql-password> <controller-host-name> <admin-tenant-password>"
		exit 1
fi
echo "Configuring MySQL for Keystone..."
mysql_command="CREATE DATABASE IF NOT EXISTS keystone; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$1'; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$1';"
echo "MySQL DB Command is: "$mysql_command 
sleep 3
mysql -u "$2" -p"$3" -e "$mysql_command"

echo_and_sleep "Configuring Keystone..." 2

crudini --set /etc/keystone/keystone.conf database connection mysql+pymysql://keystone:$1@$4/keystone
crudini --set /etc/keystone/keystone.conf token provider fernet
grep "mysql" /etc/keystone/keystone.conf
echo_and_sleep "Configured KeyStone Conf File" 2

echo_and_sleep "Executing Keystone DB Sync" 2
keystone-manage db_sync
echo_and_sleep "Setup Fernet" 2
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

keystone-manage bootstrap --bootstrap-password $5 \
  --bootstrap-admin-url http://$4:35357/v3/ \
  --bootstrap-internal-url http://$4:35357/v3/ \
  --bootstrap-public-url http://$4:5000/v3/ \
  --bootstrap-region-id RegionOne
echo_and_sleep "Executed Keystone Bootstrap" 2

grep -q '^ServerName' /etc/apache2/apache2.conf && sed 's/^ServerName.*/ServerName controller/' -i /etc/apache2/apache2.conf || echo "ServerName controller" >> /etc/apache2/apache2.conf 

echo_and_sleep "Restarting Apache Service" 2
service apache2 restart

echo "Removing KeyStone MySQL-Lite Database..."
rm -f /var/lib/keystone/keystone.db

echo_and_sleep "Setting environment variables" 1
export OS_USERNAME=admin
export OS_PASSWORD=$5
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://$4:35357/v3
export OS_IDENTITY_API_VERSION=3
echo_and_sleep "Set environment variables" 1


openstack project create --domain default --description "Service Project" service
echo_and_sleep "Configured Service Project" 2

openstack project create --domain default --description "Demo Project" demo
openstack user create --domain default --password password demo
openstack role create user
openstack role add --project demo --user demo user
echo_and_sleep "Configured Demo Tenant and Role" 2

echo_and_sleep "Keystone service restarted" 2
source $(dirname $0)/admin_openrc.sh
echo_and_sleep "Called Source Admin OpenRC"
print_keystone_service_list

