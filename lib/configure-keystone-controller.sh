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

crudini --set /etc/keystone/keystone.conf database connection mysql://keystone:$1@$4/keystone

crudini --set /etc/keystone/keystone.conf memcache servers localhost:11211
echo_and_sleep "New in Kilo - Memcache configuration" 2

crudini --set /etc/keystone/keystone.conf token provider keystone.token.providers.uuid.Provider
crudini --set /etc/keystone/keystone.conf token driver keystone.token.persistence.backends.memcache.Token

crudini --set /etc/keystone/keystone.conf revoke driver keystone.contrib.revoke.backends.sql.Revoke
echo_and_sleep "New in Kilo - SQL Revoke configuration" 2

grep "mysql" /etc/keystone/keystone.conf
echo_and_sleep "Configured KeyStone Conf File" 2

grep -q '^ServerName' /etc/apache2/apache2.conf && sed 's/^ServerName.*/ServerName controller/' -i /etc/apache2/apache2.conf || echo "ServerName controller" >> /etc/apache2/apache2.conf 

cp $(dirname $0)/wsgi-keystone.conf /etc/apache2/sites-available/
ls -al /etc/apache2/sites-available | grep key
echo_and_sleep "Added Keystone file under Apache" 3

ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled
mkdir -p /var/www/cgi-bin/keystone
curl http://git.openstack.org/cgit/openstack/keystone/plain/httpd/keystone.py?h=stable/kilo \
  | tee /var/www/cgi-bin/keystone/main /var/www/cgi-bin/keystone/admin
chown -R keystone:keystone /var/www/cgi-bin/keystone
chmod 755 /var/www/cgi-bin/keystone/*

echo_and_sleep "Populate Identity Service Database" 2
keystone-manage db_sync

echo_and_sleep "Restarting KeyStone Service" 2
service keystone restart

echo_and_sleep "Restarting Apache Service" 2
service apache2 restart

echo "Removing KeyStone MySQL-Lite Database..."
rm -f /var/lib/keystone/keystone.db

echo "Setting up crontab for Identity Token cleanup..."
(crontab -l -u keystone 2>&1 | grep -q token_flush) || echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/
ystone-tokenflush.log 2>&1' >> /var/spool/cron/crontabs/keystone	

echo_sleep "Setting environment variables" 1
#export OS_SERVICE_TOKEN=$admin_token_parameter
#export OS_SERVICE_ENDPOINT=http://$4:35357/v2.0
export OS_TOKEN=$admin_token_parameter
export OS_URL=http://$4:35357/v2.0
#source $(dirname $0)/admin_openrc.sh
#echo_and_sleep "Called Source Admin OpenRC"
echo_sleep "Set environment variables" 2

openstack service create --name keystone --description "OpenStack Identity" identity
echo_and_sleep "Created Identity Service"

openstack endpoint create \
--publicurl http://$4:5000/v2.0 \
--internalurl http://$4:5000/v2.0 \
--adminurl http://$4:35357/v2.0 \
--region RegionOne \
identity
echo_and_sleep "Added Identity Endpoint and about to restart keystone" 2
service keystone restart
echo_and_sleep "Keystone service restarted" 2

openstack project create --description "Admin Project" admin
openstack user create --password $5 admin
echo_and_sleep "Created Admin Project and User"

openstack role create admin
openstack role add --project admin --user admin admin
echo_and_sleep "Created and added Admin Role" 2

openstack project create --description "Service Project" service

openstack project create --description "Demo Project" demo
openstack user create --password password demo
openstack role create user
openstack role add --project demo --user demo user
echo_and_sleep "Configured Demo Tenant and Role" 2

service keystone restart
echo_and_sleep "Keystone service restarted" 2
print_keystone_service_list

