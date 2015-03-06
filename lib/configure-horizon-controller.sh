source $(dirname $0)/config-parameters.sh
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
grep "ALLOWED_HOSTS" /etc/openstack-dashboard/local_settings.py
grep "OPENSTACK_HOST" /etc/openstack-dashboard/local_settings.py
echo_and_sleep "Restarting apache2" 3
service apache2 restart
echo_and_sleep "Restarting memcached" 3
service memcached restart
