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
grep "admin_token" /etc/keystone/keystone.conf
sleep 3

crudini --set /etc/keystone/keystone.conf database connection mysql://keystone:$1@$4/keystone

echo_and_sleep "New in Kilo - Memcache configuration" 2
crudini --set /etc/keystone/keystone.conf memcache servers localhost:11211

crudini --set /etc/keystone/keystone.conf token provider keystone.token.providers.uuid.Provider
crudini --set /etc/keystone/keystone.conf token driver keystone.token.persistence.backends.memcache.Token

echo_and_sleep "New in Kilo - SQL Revoke configuration" 2
crudini --set /etc/keystone/keystone.conf revoke driver keystone.contrib.revoke.backends.sql.Revoke

grep "mysql" /etc/keystone/keystone.conf
echo_and_sleep "Configured KeyStone Conf File" 2

grep -q '^ServerName' /etc/apache2/apache2.conf && sed 's/^ServerName.*/ServerName controller/' -i /etc/apache2/apache2.conf || echo "ServerName controller" >> /etc/apache2/apache2.conf 

cp $(dirname $0)/wsgi-keystone.conf /etc/apache2/sites-available/
ls -al /etc/apache2/sites-available | grep key
echo_and_sleep "Keystone file under Apache" 5

ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled
mkdir -p /var/www/cgi-bin/keystone
curl http://git.openstack.org/cgit/openstack/keystone/plain/httpd/keystone.py?h=stable/kilo \
  | tee /var/www/cgi-bin/keystone/main /var/www/cgi-bin/keystone/admin
chown -R keystone:keystone /var/www/cgi-bin/keystone
chmod 755 /var/www/cgi-bin/keystone/*

echo "Populate Identity Service Database..."
keystone-manage db_sync

echo_and_sleep "Restarting KeyStone Service" 3
service keystone restart

echo "Restarting Apache Service..."
service apache2 restart

echo "Removing KeyStone MySQL-Lite Database..."
rm -f /var/lib/keystone/keystone.db

echo "Setting up crontab for Identity Token cleanup..."
(crontab -l -u keystone 2>&1 | grep -q token_flush) || echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/
ystone-tokenflush.log 2>&1' >> /var/spool/cron/crontabs/keystone	

echo "Setting environment variables"
#export OS_SERVICE_TOKEN=$admin_token_parameter
#export OS_SERVICE_ENDPOINT=http://$4:35357/v2.0
export OS_TOKEN=$admin_token_parameter
export OS_URL=http://$4:35357/v2.0
source $(dirname $0)/admin_openrc.sh
echo_and_sleep "Called Source Admin OpenRC"

openstack service create --name keystone --description "OpenStack Identity" identity
echo_and_sleep "Created Identity Service"

openstack endpoint create \
--publicurl http://$4:5000/v2.0 \
--internalurl http://$4:5000/v2.0 \
--adminurl http://$4:35357/v2.0 \
--region RegionOne \
identity

keystone tenant-create --name admin --description "Admin Tenant"
keystone user-create --name admin --pass $5 --email admin@example.com
echo_and_sleep "Created Admin Tenant"

keystone role-create --name admin
keystone user-role-add --tenant admin --user admin --role admin
echo_and_sleep "Created Admin Role"

keystone role-create --name _member_
keystone user-role-add --tenant admin --user admin --role _member_

keystone tenant-create --name demo --description "Demo Tenant"
keystone user-create --name demo --pass password
keystone user-role-add --tenant demo --user demo --role _member_
echo_and_sleep "Configured Demo Tenant and Role"

keystone tenant-create --name service --description "Service Tenant"

echo_and_sleep "Added Identity Endpoint and about to restart keystone"
service keystone restart
echo_and_sleep "Keystone service restarted" 2
print_keystone_service_list

