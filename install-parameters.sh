readonly sleep_duration=5
readonly controller_host_name="controller"
controller_ip_address="192.168.100.100"
readonly network_node_host_name="networknode"
network_node_ip_address="192.168.100.101"

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

apt-get install crudini
