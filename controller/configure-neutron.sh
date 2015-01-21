source install-parameters.sh
source admin_openrc.sh

if [ $# -lt 8 ]
	then
		echo "Correct Syntax: $0 <neutron-db-password> <mysql-username> <mysql-password> <controller-host-name> <admin-tenant-password> <neutron-password> <rabbitmq-password> <service_tenant_id>"
		exit 1
fi

echo "Configuring MySQL for Neutron..."
mysql_command="CREATE DATABASE IF NOT EXISTS neutron; GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '$1'; GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '$1';"
echo "MySQL Command is:: "$mysql_command
mysql -u "$2" -p"$3" -e "$mysql_command"

keystone user-create --name neutron --pass $6
keystone user-role-add --user neutron --tenant service --role admin
echo_and_sleep "Creating Neutron User in KeyStone" 10

keystone service-create --name neutron --type network --description "OpenStack Networking"
echo_and_sleep "Called service-create for Neutron Networking" 10

keystone endpoint-create \
--service-id $(keystone service-list | awk '/ network / {print $2}') \
--publicurl http://$4:9696/v2/%\(tenant_id\)s \
--internalurl http://$4:9696/v2/%\(tenant_id\)s \
--adminurl http://$4:9696/v2/%\(tenant_id\)s \
--region regionOne

echo_and_sleep "Configuring Neutron Conf File..." 3
crudini --set /etc/neutron/neutron.conf database connection mysql://neutron:$1@$4/neutron

crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend rabbit
crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_host $4
crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_password $7
crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone

crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_uri http://$4:5000/v2.0
crudini --set /etc/neutron/neutron.conf keystone_authtoken identity_uri http://$4:35357
crudini --set /etc/neutron/neutron.conf keystone_authtoken admin_tenant_name service
crudini --set /etc/neutron/neutron.conf keystone_authtoken admin_user neutron
crudini --set /etc/neutron/neutron.conf keystone_authtoken admin_password $6

crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin ml2
crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins router
crudini --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips True

crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes True 
crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes True
crudini --set /etc/neutron/neutron.conf DEFAULT nova_url http://$4:8774/v2 
crudini --set /etc/neutron/neutron.conf DEFAULT nova_admin_auth_url http://$4:35357/v2.0 
crudini --set /etc/neutron/neutron.conf DEFAULT nova_region_name regionOne
crudini --set /etc/neutron/neutron.conf DEFAULT nova_admin_username nova
crudini --set /etc/neutron/neutron.conf DEFAULT nova_admin_tenant_id $8 
crudini --set /etc/neutron/neutron.conf DEFAULT nova_admin_password $6

echo_and_sleep "Configuring ML2 INI file..." 5
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers vlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_type vlan,local
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_driver openvswitch

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vlan network_vlan_ranges physnet1:1001:1200
echo_and_sleep "Configured VLAN Range." 5

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_security_group True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
echo_and_sleep "Configured Security Group for ML2. About to Upgrade Neutron DB..." 5
neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade juno

echo_and_sleep "Restarting Neutron Service..." 5
service nova-api restart
service nova-scheduler restart
service nova-conductor restart
service neutron-server restart

echo_and_sleep "Printing Keystone Server List"
print_keystone_service_list
