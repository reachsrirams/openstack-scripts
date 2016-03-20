echo "Running: $0 $@"
source $(dirname $0)/config-parameters.sh
if [ $# -lt 1 ]
        then
                echo "Correct Syntax: $0 <cotroller-host-name>"
                exit 1
fi

echo "Edit /etc/openstack-dashboard/local_settings.py as follows:"
echo "*********"
echo "OPENSTACK_HOST = \"controller\"" 
echo "ALLOWED_HOSTS = ['*']" 
echo "CACHES = {" 
echo "    'default': {" 
echo "        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache'," 
echo "        'LOCATION': '127.0.0.1:11211'," 
echo "    }" 
echo "}" 
echo "*********"
sed -e "/^ALLOWED_HOSTS =.*$/s/^.*$/ALLOWED_HOSTS = ['*']/" -i /etc/openstack-dashboard/local_settings.py
sed -e "/^OPENSTACK_HOST =.*$/s/^.*$/OPENSTACK_HOST = \""$1"\"/" -i /etc/openstack-dashboard/local_settings.py
sed -e "/^OPENSTACK_KEYSTONE_DEFAULT_ROLE =.*$/s/^.*$/OPENSTACK_KEYSTONE_DEFAULT_ROLE = \"user\"/" -i /etc/openstack-dashboard/local_settings.py
sed -e "/^OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT =.*$/s/^.*$/OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = \"True\"/" -i /etc/openstack-dashboard/local_settings.py
grep "ALLOWED_HOSTS" /etc/openstack-dashboard/local_settings.py
grep "OPENSTACK_HOST" /etc/openstack-dashboard/local_settings.py
echo_and_sleep "Restarting apache2" 3
service apache2 reload
echo_and_sleep "Restarting memcached" 3
service memcached restart
