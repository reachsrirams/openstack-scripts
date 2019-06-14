readonly keystone_config_path="/etc/keystone/"
readonly keystone_config_file="keystone.conf"
readonly glance_config_path="/etc/glance/"
readonly glance_api_config_file="glance-api.conf"
readonly glance_registry_config_file="glance-registry.conf"
readonly nova_config_path="/etc/nova/"
readonly nova_config_file="nova.conf"
readonly neutron_config_path="/etc/neutron/"
readonly neutron_config_file="neutron.conf"
readonly neutron_ml2_config_path="/etc/neutron/plugins/ml2/"
readonly neutron_ml2_config_file="ml2_conf.ini"
readonly horizon_local_settings_path="/etc/openstack-dashboard/"
readonly horizon_local_settings_file="local_settings.py"

function backup() {
	mkdir $1
	echo "Copying config files to: "$1
	sleep 3
	cp -f $keystone_config_path$keystone_config_file $1
	cp -f $glance_config_path$glance_api_config_file $1
	cp -f $glance_config_path$glance_registry_config_file $1
	cp -f $nova_config_path$nova_config_file $1
	cp -f $neutron_config_path$neutron_config_file $1
	cp -f $neutron_ml2_config_path$neutron_ml2_config_file $1
	cp -f $horizon_local_settings_path$horizon_local_settings_file $1
}

function restore() {
	echo "Copying config files from: "$1
	sleep 3
	cp -f $1$keystone_config_file $keystone_config_path
	cp -f $1$glance_api_config_file  $glance_config_path
	cp -f $1$glance_registry_config_file  $glance_config_path
	cp -f $1$nova_config_file $nova_config_path
	cp -f $1$neutron_config_file $neutron_config_path
	cp -f $1$neutron_ml2_config_file $neutron_ml2_config_path
	cp -f $1$horizon_local_settings_file $horizon_local_settings_path
}

if [ $# -ne 2 ]
then
	echo "Correct Syntax: $0 [backup | restore] <directory_name>"
	exit 1
fi

if [ "$1" == "backup" ]
then
	backup $2
elif [ "$1" == "restore" ]
then
	restore $2
else
	echo "Invalid action. Correct Syntax: $0 [backup | restore] <directory_name>"
	exit 1
fi
