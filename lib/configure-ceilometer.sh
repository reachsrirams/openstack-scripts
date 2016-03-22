echo "Running: $0 $@"
source $(dirname $0)/config-parameters.sh

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
		
function update_mongodb_config_file() {
	echo "Updating Bind IP in MongoDB Config File"
	sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongodb.conf
	grep "bind" /etc/mongodb.conf
	echo_and_sleep "Updated Bind Address" 2
	echo "smallfiles = true" >> /etc/mongodb.conf
	grep "smallfiles" /etc/mongodb.conf
	sleep 2
}

source $(dirname $0)/admin_openrc.sh

if [ "$1" == "controller" ]
	then
		update_mongodb_config_file
		echo_and_sleep "Stopping Mongo DB"
		service mongodb stop
		rm -f /var/lib/mongodb/journal/prealloc.*
		echo_and_sleep "Starting Mongo DB"
		service mongodb start


		echo_and_sleep "About to create Ceilometer DB in MongoDB" 6
		mongo --host controller --eval 'db = db.getSiblingDB("ceilometer"); db.addUser({user:"ceilometer", pwd: "CEILOMETER_DBPASS",roles: [ "readWrite", "dbAdmin" ]})'
		
		echo_and_sleep "About to start Ceilometer setup-config"

		create-user-service ceilometer $4 ceilometer OpenStackTelemetry metering
		echo_and_sleep "Created Ceilometer User in Keystone. About to create endpoints."

		create-api-endpoints metering http://$2:8777
		
		echo_and_sleep "Created Ceilometer Endpoint in Keystone. About to Ceilometer Conf File" 4
		crudini --set /etc/ceilometer/ceilometer.conf database connection mongodb://ceilometer:$6@$2:27017/ceilometer

		crudini --set /etc/glance/glance-api.conf DEFAULT notification_driver messagingv2
		crudini --set /etc/glance/glance-registry.conf DEFAULT notification_driver messagingv2
		configure-oslo-messaging /etc/glance/glance-api.conf $2 openstack $3
		configure-oslo-messaging /etc/glance/glance-registry.conf $2 openstack $3

		#crudini --set /etc/ceilometer/ceilometer.conf publisher metering_secret $5
		#crudini --set /etc/ceilometer/ceilometer.conf DEFAULT log_dir /var/log/ceilometer
fi

crudini --set /etc/ceilometer/ceilometer.conf DEFAULT rpc_backend rabbit
configure-oslo-messaging /etc/ceilometer/ceilometer.conf $2 openstack $3
crudini --set /etc/ceilometer/ceilometer.conf DEFAULT auth_strategy keystone

configure-keystone-authentication /etc/ceilometer/ceilometer.conf $2 ceilometer $4

crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_auth_url http://$2:5000/v2.0
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_tenant_name service
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_username ceilometer
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_password $4
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_region_name RegionOne
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_endpoint_type internalURL

if [ "$1" == "compute" ]
	then
		echo_and_sleep "Configuring Nova Conf File for Ceilometer" 3
		crudini --set /etc/nova/nova.conf DEFAULT instance_usage_audit True
		crudini --set /etc/nova/nova.conf DEFAULT instance_usage_audit_period hour
		crudini --set /etc/nova/nova.conf DEFAULT notify_on_state_change vm_and_task_state
		crudini --set /etc/nova/nova.conf DEFAULT notification_driver messagingv2
		echo_and_sleep "Configured Nova to use Ceilometer - DEFAULT section" 3
fi

crudini --set /etc/ceilometer/ceilometer.conf DEFAULT verbose True
echo_and_sleep "Configured Ceilometer Conf File" 3

if [ "$1" == "controller" ]
	then
		echo_and_sleep "Restarting Ceilometer Compute Service" 2
		service glance-api restart
		service glance-registry restart
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

