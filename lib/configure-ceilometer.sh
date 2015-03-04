source config-parameters.sh

if [ "$1" != "controller" ] && [ "$1" != "compute" ]
	then
		echo "Correct Syntax: $0 [ controller | compute ] <controller-host-name> <rabbitmq-password> <ceilometer-password> <metering-secret> <ceilometer-db-password>"
		exit 1;
fi

if [ "$1" == "controller" ] && [ $# -ne 6 ]
	then
		echo "Correct Syntax: $0 controller <controller-host-name> <rabbitmq-password> <ceilometer-password> <metering-secret> <ceilometer-db-password>"
		exit 1;
fi
		
if [ "$1" == "compute" ] && [ $# -ne 5 ]
	then
		echo "Correct Syntax: $0 compute <controller-host-name> <rabbitmq-password> <ceilometer-password> <metering-secret>"
		exit 1;
fi
		
function update_mongodb_bind_address() {
	echo "Updating Bind IP in MongoDB Config File"
	sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongodb.conf
	grep "bind" /etc/mongodb.conf
	echo_and_sleep "Updated Bind Address" 2
}

source admin_openrc.sh

if [ "$1 == "controller" ]
	then
		update_mongodb_bind_address
		echo_and_sleep "Starting Mongo DB"
		service mongodb restart
		echo_and_sleep "About to create Ceilometer DB in MongoDB" 7
		mongo --host controller --eval 'db = db.getSiblingDB("ceilometer"); db.addUser({user:"ceilometer", pwd: "CEILOMETER_DBPASS",roles: [ "readWrite", "dbAdmin" ]})'
		
		echo_and_sleep "About to start Ceilometer setup-config"

		keystone user-create --name ceilometer --pass $4
		echo_and_sleep "Created Ceilometer User in KeyStone"
		keystone user-role-add --user ceilometer --tenant service --role admin
		echo_and_sleep "Created Ceilometer Tenant in KeyStone"
		
		keystone service-create --name ceilometer --type metering --description "Telemetry"
		echo_and_sleep "Called service-create for Ceilometer" 10
		
		keystone endpoint-create \
		--service-id $(keystone service-list | awk '/ metering / {print $2}') \
		--publicurl http://$2:8777 \
		--internalurl http://$2:8777 \
		--adminurl http://$2:8777 \
		--region regionOne
		
		echo_and_sleep "Created Ceilometer Endpoint in Keystone. About to Ceilometer Conf File" 10
		crudini --set /etc/ceilometer/ceilometer.conf database connection mongodb://ceilometer:$6@$2:27017/ceilometer
fi

crudini --set /etc/ceilometer/ceilometer.conf DEFAULT rpc_backend rabbit
crudini --set /etc/ceilometer/ceilometer.conf DEFAULT rabbit_host $2
crudini --set /etc/ceilometer/ceilometer.conf DEFAULT rabbit_password $3
crudini --set /etc/ceilometer/ceilometer.conf DEFAULT auth_strategy keystone

crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken auth_uri http://$2:5000/v2.0
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken identity_uri http://$2:35357
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken admin_tenant_name service
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken admin_user ceilometer
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken admin_password $4

crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_auth_url http://$2:5000/v2.0
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_tenant_name service
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_user ceilometer
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_password $4

crudini --set /etc/ceilometer/ceilometer.conf publisher metering_secret $5
crudini --set /etc/ceilometer/ceilometer.conf DEFAULT log_dir /var/log/ceilometer

if [ "$1" == "compute" ]
	then
		echo_and_sleep "Configuring Nova Conf File for Ceilometer" 3
		crudini --set /etc/nova/nova.conf DEFAULT instance_usage_audit True
		crudini --set /etc/nova/nova.conf DEFAULT instance_usage_audit_period hour
		crudini --set /etc/nova/nova.conf DEFAULT notify_on_state_change vm_and_task_state
		crudini --set /etc/nova/nova.conf DEFAULT notification_driver nova.openstack.common.notifier.rpc_notifier
		crudini --set /etc/nova/nova.conf DEFAULT notification_driver ceilometer.compute.nova_notifier
		echo_and_sleep "Configured Nova to use Ceilometer - DEFAULT section" 5
		crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_endpoint_type internalURL
fi

echo_and_sleep "Configured Ceilometer Conf File" 3

if [ "$1" == "controller" ]
	then
		echo_and_sleep "Restarting Ceilometer Compute Service" 2
		service ceilometer-agent-central restart
		service ceilometer-agent-notification restart 
		service ceilometer-api restart
		service ceilometer-collector restart
		service ceilometer-alarm-evaluator restart
		service ceilometer-alarm-notifier restart
elif [ "$1" == "compute" ]
	then
		echo_and_sleep "Restarting Nova" 3
		service nova-compute restart
		echo_and_sleep "Restarting Ceilometer Compute Service" 2
		service ceilometer-agent-compute restart
		
fi



