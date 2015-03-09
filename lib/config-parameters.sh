controller_host_name="controller"

### Start - Neutron related settings

readonly neutron_ml2_type_drivers="vlan"
readonly neutron_ml2_tenant_network_types="vlan"
readonly neutron_ml2_mechanism_drivers="openvswitch"

readonly neutron_ml2_network_vlan_ranges="physnet1:1001:1200"

readonly neutron_ovs_tenant_network_type="vlan"
readonly neutron_ovs_bridge_mappings="physnet1:br-eth1"

readonly neutron_linuxbridge_tenant_network_type="vlan"
readonly neutron_linuxbridge_physical_interface_mappings="physnet1:eth1"

### End - Neutron related settings

readonly mysql_user="root"
readonly mysql_password="password"

readonly rabbitmq_user="guest"
readonly rabbitmq_password="password"

readonly keystone_db_password="password"

readonly glance_password="password"
readonly glance_db_password="password"

readonly admin_tenant_password="password"

readonly nova_password="password"
readonly nova_db_password="password"

readonly neutron_password="password"
readonly neutron_db_password="password"

readonly ceilometer_password="password"
readonly ceilometer_db_password="password"

function echo_and_sleep() {
	if [ -z "$2" ]
		then
			sleep_time=5
		else
			sleep_time=$2
	fi

	if [ -z "$1" ]
		then
			echo_string="About to sleep for "$sleep_time" seconds..."
		else
			echo_string=$1
	fi
	echo "$echo_string and sleeping for "$sleep_time" seconds..."
	sleep $sleep_time
}

function print_keystone_service_list() {
	echo_and_sleep "About to print Keystone Service List" 2
	keystone service-list
	echo_and_sleep "Printed Keystone Service List" 10
}

