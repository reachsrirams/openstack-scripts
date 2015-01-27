source install-parameters.sh
source admin_openrc.sh

if [ $# -lt 8 ]
	then
		echo "Correct Syntax: $0 <ceilometer-db-password> <mysql-username> <mysql-password> <controller-host-name> <admin-tenant-password> <ceilometer-password> <rabbitmq-password> <metering-secret>"
		exit 1
fi

function update_mongodb_bind_address() {
	echo "Updating Bind IP in MongoDB Config File"
	sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongodb.conf
	grep "bind" /etc/mongodb.conf
	echo_and_sleep "Updated Bind Address" 2
}

update_mongodb_bind_address
echo_and_sleep "Starting Mongo DB"
service mongodb restart
echo_and_sleep "About to create Ceilometer DB in MongoDB" 10
mongo --host controller --eval 'db = db.getSiblingDB("ceilometer"); db.addUser({user:"ceilometer", pwd: "CEILOMETER_DBPASS",roles: [ "readWrite", "dbAdmin" ]})'

echo_and_sleep "About to start Ceilometer setup-config"
source admin_openrc.sh

keystone user-create --name ceilometer --pass $6
echo_and_sleep "Created Ceilometer User in KeyStone"
keystone user-role-add --user ceilometer --tenant service --role admin
echo_and_sleep "Created Ceilometer Tenant in KeyStone"

keystone service-create --name ceilometer --type metering --description "Telemetry"
echo_and_sleep "Called service-create for Ceilometer" 15

keystone endpoint-create \
--service-id $(keystone service-list | awk '/ metering / {print $2}') \
--publicurl http://$4:8777 \
--internalurl http://$4:8777 \
--adminurl http://$4:8777 \
--region regionOne

echo_and_sleep "Created Ceilometer Endpoint in Keystone. About to Ceilometer Conf File" 15
crudini --set /etc/ceilometer/ceilometer.conf database connection mongodb://ceilometer:$1@$4:27017/ceilometer

crudini --set /etc/ceilometer/ceilometer.conf DEFAULT rpc_backend rabbit
crudini --set /etc/ceilometer/ceilometer.conf DEFAULT rabbit_host $4
crudini --set /etc/ceilometer/ceilometer.conf DEFAULT rabbit_password $7
crudini --set /etc/ceilometer/ceilometer.conf DEFAULT auth_strategy keystone

crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken auth_uri http://$4:5000/v2.0
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken identity_uri http://$4:35357
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken admin_tenant_name service
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken admin_user ceilometer
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken admin_password $6

crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_auth_url http://$4:5000/v2.0
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_tenant_name service
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_user ceilometer
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_password $6

crudini --set /etc/ceilometer/ceilometer.conf publisher metering_secret $8
crudini --set /etc/ceilometer/ceilometer.conf DEFAULT log_dir /var/log/ceilometer

echo_and_sleep "Configured Ceilometer Conf File" 3

echo_and_sleep "Restarting Ceilometer Compute Service" 2
service ceilometer-agent-central restart
service ceilometer-agent-notification restart 
service ceilometer-api restart
service ceilometer-collector restart
service ceilometer-alarm-evaluator restart
service ceilometer-alarm-notifier restart

