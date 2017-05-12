echo "Running: $0 $@"
source $(dirname $0)/config-parameters.sh
if [ $# -lt 1 ]
        then
                echo "Correct Syntax: $0 <cotroller-host-name>"
                exit 1
fi
echo_and_sleep "Copying local_settings.py to /etc/openstack-dashboard" 2
cp $(dirname $0)/local_settings.py /etc/openstack-dashboard/
echo_and_sleep "Copied local_settings.py to /etc/openstack-dashboard" 2

sed -e "/^OPENSTACK_HOST =.*$/s/^.*$/OPENSTACK_HOST = \""$1"\"/" -i /etc/openstack-dashboard/local_settings.py
sed -e "/^'LOCATION.*$/s/^.*$/'LOCATION': \'"$1:1121"\'/" -i /etc/openstack-dashboard/local_settings.py
grep "OPENSTACK_HOST" /etc/openstack-dashboard/local_settings.py
grep "LOCATION" /etc/openstack-dashboard/local_settings.py
echo_and_sleep "OCATA - fixing secret_key permission" 1
chown www-data /var/lib/openstack-dashboard/secret_key
echo_and_sleep "Restarting apache2" 1
service apache2 reload
echo_and_sleep "Restarted apache2" 1
