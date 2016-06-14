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
sleep 5
mysql -u "$2" -p"$3" -e "$mysql_command"

echo "Configuring Keystone..."
admin_token_parameter=`openssl rand -hex 10`
crudini --set /etc/keystone/keystone.conf DEFAULT admin_token $admin_token_parameter
sleep 1
grep "admin_token" /etc/keystone/keystone.conf
sleep 2

crudini --set /etc/keystone/keystone.conf database connection mysql+pymysql://keystone:$1@$4/keystone

crudini --set /etc/keystone/keystone.conf token provider fernet
grep "mysql" /etc/keystone/keystone.conf
echo_and_sleep "Configured KeyStone Conf File" 2

grep -q '^ServerName' /etc/apache2/apache2.conf && sed 's/^ServerName.*/ServerName controller/' -i /etc/apache2/apache2.conf || echo "ServerName controller" >> /etc/apache2/apache2.conf 

cp $(dirname $0)/wsgi-keystone.conf /etc/apache2/sites-available/
ls -al /etc/apache2/sites-available | grep key
echo_and_sleep "Added Keystone file under Apache" 3

ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled

echo_and_sleep "Populate Identity Service Database" 2
keystone-manage db_sync
echo_and_sleep "New in Mitaka - Fernet Setup" 2
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone

echo_and_sleep "Restarting Apache Service" 2
service apache2 restart

echo "Removing KeyStone MySQL-Lite Database..."
rm -f /var/lib/keystone/keystone.db

echo "Setting up crontab for Identity Token cleanup..."
(crontab -l -u keystone 2>&1 | grep -q token_flush) || echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/
ystone-tokenflush.log 2>&1' >> /var/spool/cron/crontabs/keystone	

echo_and_sleep "Setting environment variables" 1
export OS_TOKEN=$admin_token_parameter
export OS_URL=http://$4:35357/v3
export OS_IDENTITY_API_VERSION=3
echo_and_sleep "Set environment variables" 1

openstack service create --name keystone --description "OpenStackIdentity" identity
echo_and_sleep "Created Identity Service"

openstack endpoint create --region RegionOne identity public http://$4:5000/v2.0
openstack endpoint create --region RegionOne identity internal http://$4:5000/v2.0
openstack endpoint create --region RegionOne identity admin http://$4:35357/v2.0

openstack domain create --description "Default Domain" default
echo_and_sleep "Created Domain: default" 2

echo_and_sleep "Added Identity Endpoint and about to restart keystone" 2
service keystone restart
echo_and_sleep "Keystone service restarted" 2

openstack project create --domain default --description "Admin Project" admin
openstack user create --domain default --password $5 admin
echo_and_sleep "Created Admin Project and User" 2

openstack role create admin
openstack role add --project admin --user admin admin
echo_and_sleep "Created and added Admin Role" 2

openstack project create --domain default --description "Service Project" service
echo_and_sleep "Configured Service Project" 2

openstack project create --domain default --description "Demo Project" demo
openstack user create --domain default --password password demo
openstack role create user
openstack role add --project demo --user demo user
echo_and_sleep "Configured Demo Tenant and Role" 2

service keystone restart
echo_and_sleep "Keystone service restarted" 2
source $(dirname $0)/admin_openrc.sh
echo_and_sleep "Called Source Admin OpenRC"
print_keystone_service_list

