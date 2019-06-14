echo "Running: $0 $@"
source $(dirname $0)/config-parameters.sh

if [ $# -lt 6 ]
	then
		echo "Correct Syntax: $0 <glance-db-password> <mysql-username> <mysql-password> <controller-host-name> <admin-tenant-password> <glance-password>"
		exit 1
fi

echo "Configuring MySQL for Glance..."
mysql_command="CREATE DATABASE IF NOT EXISTS glance; GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$1'; GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$1';"
echo "MySQL Command is:: "$mysql_command
mysql -u "$2" -p"$3" -e "$mysql_command"

source $(dirname $0)/admin_openrc.sh
echo_and_sleep "Called Source Admin OpenRC"

create-user-service glance $6 glance OpenStackImage image

create-api-endpoints image http://$4:9292
echo_and_sleep "Added Glance Service Endpoint"

echo "Configuring Glance..."
crudini --set /etc/glance/glance-api.conf database connection mysql+pymysql://glance:$1@$4/glance

configure-keystone-authentication /etc/glance/glance-api.conf $4 glance $6
crudini --set /etc/glance/glance-api.conf paste_deploy flavor keystone
crudini --set /etc/glance/glance-api.conf glance_store stores file,http
crudini --set /etc/glance/glance-api.conf glance_store default_store file
crudini --set /etc/glance/glance-api.conf glance_store filesystem_store_datadir /var/lib/glance/images

crudini --set /etc/glance/glance-registry.conf database connection mysql+pymysql://glance:$1@$4/glance

configure-keystone-authentication /etc/glance/glance-registry.conf $4 glance $6
crudini --set /etc/glance/glance-registry.conf paste_deploy flavor keystone

echo_and_sleep "About to populate Image Service Database" 
glance-manage db_sync

echo_and_sleep "Restarting Glance Service..." 3
service glance-registry restart
service glance-api restart

echo_and_sleep "Removing Glance MySQL-Lite Database" 
rm -f /var/lib/glance/glance.sqlite

print_keystone_service_list
