if [ $# -lt 4 ]
	then
		echo "Correct syntax: $0 <controller-host-name> <rabbitmq-password> <ceilometer-password> <metering-secret>"
		exit 1;
fi

source install-parameters.sh

echo_and_sleep "Configuring Nova Conf File for Ceilometer" 3
crudini --set /etc/nova/nova.conf DEFAULT instance_usage_audit True
crudini --set /etc/nova/nova.conf DEFAULT instance_usage_audit_period hour
crudini --set /etc/nova/nova.conf DEFAULT notify_on_state_change vm_and_task_state
crudini --set /etc/nova/nova.conf DEFAULT notification_driver nova.openstack.common.notifier.rpc_notifier
crudini --set /etc/nova/nova.conf DEFAULT notification_driver ceilometer.compute.nova_notifier
echo_and_sleep "Configured Nova to use Ceilometer - DEFAULT section" 5

echo_and_sleep "Restarting Nova" 3
service nova-compute restart

echo_and_sleep "About to configure Ceilometer Conf File" 3
crudini --set /etc/ceilometer/ceilometer.conf publisher metering_secret $4

crudini --set /etc/ceilometer/ceilometer.conf DEFAULT rabbit_host $1
crudini --set /etc/ceilometer/ceilometer.conf DEFAULT rabbit_password $2

crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken auth_uri http://$1:5000/v2.0
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken identity_uri http://$1:35357
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken admin_tenant_name service
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken admin_user ceilometer
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken admin_password $3

crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_auth_url http://$1:5000/v2.0
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_tenant_name service
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_user ceilometer
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_password $3
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_endpoint_type internalURL

crudini --set /etc/ceilometer/ceilometer.conf DEFAULT log_dir /var/log/ceilometer

echo_and_sleep "Configured Ceilometer Conf File" 3

echo_and_sleep "Restarting Ceilometer Compute Service" 2
service ceilometer-agent-compute restart
