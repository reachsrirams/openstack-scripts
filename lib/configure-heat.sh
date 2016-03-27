echo "Running: $0 $@"
source $(dirname $0)/config-parameters.sh

if [ $# -lt 6 ]
	then
		echo "Correct Syntax: $0 <heat-db-password> <mysql-username> <mysql-password> <controller-host-name> <rabbitmq-password> <heat-password>"
		exit 1
fi

echo "Configuring MySQL for Heat..."
mysql_command="CREATE DATABASE IF NOT EXISTS heat; GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'localhost' IDENTIFIED BY '$1'; GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'%' IDENTIFIED BY '$1';"
echo "MySQL Command is:: "$mysql_command
mysql -u "$2" -p"$3" -e "$mysql_command"

source $(dirname $0)/admin_openrc.sh
echo_and_sleep "Called Source Admin OpenRC"

create-user-service heat $6 heat Orchestration orchestration
openstack service create --name heat-cfn  --description Orchestration cloudformation
echo_and_sleep "Created Heat-CFN Service $4"

create-api-endpoints orchestration http://$4:8004/v1/%\(tenant_id\)s
create-api-endpoints cloudformation http://$4:8000/v1
echo_and_sleep "Added Heat Service Endpoint"

echo_and_sleep "Creating User/Role specific for Heat" 2
openstack domain create --description "Stack projects and users" heat
openstack user create --domain heat --password password heat_domain_admin
openstack role add --domain heat --user heat_domain_admin admin
openstack role create heat_stack_owner
openstack role add --project demo --user demo heat_stack_owner
openstack role create heat_stack_user
echo_and_sleep "Created User/Role specific for Heat" 2

echo "Configuring Heat DB Connection." 2
crudini --set /etc/heat/heat.conf database connection mysql+pymysql://heat:$1@$4/heat

crudini --set /etc/heat/heat.conf DEFAULT rpc_backend rabbit
configure-oslo-messaging /etc/heat/heat.conf $4 openstack $5

configure-keystone-authentication /etc/heat/heat.conf $4 heat $6

echo "Configuring Misc Heat settings." 2
crudini --set /etc/heat/heat.conf trustee auth_plugin password
crudini --set /etc/heat/heat.conf trustee auth_url http://$4:35357
crudini --set /etc/heat/heat.conf trustee username heat
crudini --set /etc/heat/heat.conf trustee password $6
crudini --set /etc/heat/heat.conf trustee user_domain_id default

crudini --set /etc/heat/heat.conf clients_keystone auth_uri http://$4:5000
crudini --set /etc/heat/heat.conf ec2authtoken auth_uri http://$4:5000

crudini --set /etc/heat/heat.conf heat_metadata_server_url http://$4:8000
crudini --set /etc/heat/heat.conf heat_waitcondition_server_url http://$4:8000/v1/waitcondition
crudini --set /etc/heat/heat.conf stack_domain_admin heat_domain_admin
crudini --set /etc/heat/heat.conf stack_domain_admin_password password
crudini --set /etc/heat/heat.conf stack_user_domain_name heat

echo_and_sleep "About to populate Orchestration Service Database" 
heat-manage db_sync

echo_and_sleep "Restarting Heat Service..." 3
service heat-api restart
service heat-api-cfn restart
service heat-engine restart

echo_and_sleep "Removing Heat MySQL-Lite Database" 
rm -f /var/lib/heat/heat.sqlite

print_keystone_service_list
