readonly sleep_duration=5
controller_host_name="controller"
controller_ip_address="192.168.1.155"
network_node_host_name="networknode"
network_node_ip_address="192.168.1.156"

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

apt-get install crudini -y

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

