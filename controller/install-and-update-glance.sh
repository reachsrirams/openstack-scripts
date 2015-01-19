if [ $# -lt 6 ]
	then
		echo "Correct Syntax: $0 <glance-db-password> <mysql-username> <mysql-password> <controller-host-name> <admin-tenant-password> <glance-password>"
		exit 1
fi

echo "Configuring MySQL for Glance..."
mysql_command="CREATE DATABASE IF NOT EXISTS glance; GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$1'; GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$1';"
echo "MySQL Command is:: "$mysql_command
mysql -u "$2" -p"$3" -e "$mysql_command"

export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$5
export OS_AUTH_URL=http://$4:35357/v2.0
sleep 2

echo "Updating KeyStone for Glance"
keystone user-create --name glance --pass $6
keystone user-role-add --user glance --tenant service --role admin
keystone service-create --name glance --type image --description "OpenStack Image Service"

set -x
keystone endpoint-create \
--service-id $(keystone service-list | awk '/ identity / {print $2}') \
--publicurl http://$4:9292 \
--internalurl http://$4:9292 \
--adminurl http://$4:9292 \
--region regionOne

apt-get install glance python-glanceclient -y
if [ $? -eq 0 ]
	then
		echo "Configuring Keystone..."
		crudini --set /etc/glance/glance-api.conf database connection mysql://glance:$1@$4/glance

		crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_uri http://$4:5000/v2.0
		crudini --set /etc/glance/glance-api.conf keystone_authtoken identity_uri http://$4:35357
		crudini --set /etc/glance/glance-api.conf keystone_authtoken admin_tenant_name service
		crudini --set /etc/glance/glance-api.conf keystone_authtoken admin_user glance
		crudini --set /etc/glance/glance-api.conf keystone_authtoken admin_password $6
		crudini --set /etc/glance/glance-api.conf paste_deploy flavor keystone
		crudini --set /etc/glance/glance-api.conf glance_store default_store file
		crudini --set /etc/glance/glance-api.conf glance_store filesystem_store_datadir /var/lib/glance/images

		crudini --set /etc/glance/glance-registry.conf database connection mysql://glance:$1@$4/glance

		crudini --set /etc/glance/glance-registry.conf keystone_authtoken auth_uri http://$4:5000/v2.0
		crudini --set /etc/glance/glance-registry.conf keystone_authtoken identity_uri http://$4:35357
		crudini --set /etc/glance/glance-registry.conf keystone_authtoken admin_tenant_name service
		crudini --set /etc/glance/glance-registry.conf keystone_authtoken admin_user glance
		crudini --set /etc/glance/glance-registry.conf keystone_authtoken admin_password $6
		crudini --set /etc/glance/glance-registry.conf paste_deploy flavor keystone

		echo "Populate Image Service Database..."
		glance-manage db_sync

		echo "Restarting Glance Service..."
		service glance-registry restart
		service glance-api restart
		
		echo "Removing Glance MySQL-Lite Database..."
		rm -f /var/lib/glance/glance.sqlite

		cirros_image_name="cirros-0.3.3-x86_64-disk.img"
		wget_url_for_cirros="http://cdn.download.cirros-cloud.net/0.3.3/"$cirros_image_name
		echo "URL for Image WGET:: "$wget_url_for_cirros
		sleep 3
		wget $wget_url_for_cirros
		glance image-create --name "cirros-0.3.3-x86_64" --file $cirros_image_name --disk-format qcow2 --container-format bare --is-public True --progress
		sleep 2
		glance image-list
		echo "About to delete the local image..."
		sleep 3
		rm -f $cirros_image_name
fi
