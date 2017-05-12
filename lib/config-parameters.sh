controller_host_name="controller"

### Start - interface related settings
readonly mgmt_interface="enp0s3"
readonly data_interface="enp0s8"
### End - interface related settings

### Start - Neutron related settings
readonly neutron_ovs_tenant_network_type="vlan"
readonly neutron_ovs_bridge_mappings="provider:br-$data_interface"

readonly neutron_linuxbridge_tenant_network_type="vlan"
readonly neutron_linuxbridge_physical_interface_mappings="provider:$data_interface"
readonly neutron_linuxbridge_overlay_interface=$data_interface
### End - Neutron related settings

readonly mysql_user="root"
readonly mysql_password="password"

readonly rabbitmq_user="openstack"
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

readonly heat_password="password"
readonly heat_db_password="password"

function echo_and_sleep() {
	if [ -z "$2" ]
		then
			sleep_time=3
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
	openstack service list --long
	echo_and_sleep "About to print OpenStack Catalog List" 2
	openstack catalog list
	echo_and_sleep "Catalog list printed" 2
}

function configure-keystone-authentication() {
	echo "Called configure-keystone-authentication with paramters: $@"
	sleep 3
	crudini --set $1 keystone_authtoken auth_uri http://$2:5000
	crudini --set $1 keystone_authtoken auth_url http://$2:35357
	crudini --set $1 keystone_authtoken memcached_servers $2:11211
	crudini --set $1 keystone_authtoken auth_type password
	crudini --set $1 keystone_authtoken project_domain_name default
	crudini --set $1 keystone_authtoken user_domain_name default
	crudini --set $1 keystone_authtoken project_name service
	crudini --set $1 keystone_authtoken username $3
	crudini --set $1 keystone_authtoken password $4
}

function configure-oslo-messaging() {
	echo "Called configure-oslo-messaging with paramters: $@"
	sleep 3
	crudini --set $1 oslo_messaging_rabbit rabbit_host $2
	crudini --set $1 oslo_messaging_rabbit rabbit_userid $3
	crudini --set $1 oslo_messaging_rabbit rabbit_password $4
}

function create-user-service() {
	echo "Called create-user-service with paramters: $@"
	sleep 3
	openstack user create --domain default --password $2 $1
	echo_and_sleep "Created User $1" 2
	openstack role add --project service --user $1 admin
	echo_and_sleep "Created Role $1" 2
	openstack service create --name $3 --description $4 $5
	echo_and_sleep "Created Service $4" 2
}

function create-api-endpoints() {
	echo "Called create-api-endpoints with parameters: $@"
	sleep 5
	openstack endpoint create --region RegionOne $1 public $2
	echo_and_sleep "Created public endpoint" 2
	openstack endpoint create --region RegionOne $1 internal $2
	echo_and_sleep "Created internal endpoint" 2
	openstack endpoint create --region RegionOne $1 admin $2
	echo_and_sleep "Created admin endpoint" 2
}

function get-ip-address() {
        ip_address_val=''
        ubuntu_version=`lsb_release -sr`
        if [ "$ubuntu_version" == "17.04" ]
        then
                ip_address_val=`ifconfig $1 | grep 'inet ' | cut -d' ' -f10 | awk '{ print $1}'`
        elif [ "$ubuntu_version" == "16.04" ]
        then
                ip_address_val=`ifconfig $1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
        else
                echo "This release is supported only on Zesty (17.04) or Xenial (16.04)"
                exit 1;
        fi
        echo $ip_address_val
}

