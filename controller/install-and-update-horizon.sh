source install-parameters.sh

echo_and_sleep "About to call apt-get to Install Horizon" 10
apt-get install openstack-dashboard apache2 libapache2-mod-wsgi memcached python-memcache -y

if [ $? -eq 0 ]
	then
		echo_and_sleep "Edit /etc/openstack-dashboard/local_settings.py as follows:" 2
		echo_and_sleep "Set OPENSTACK_HOST = \"controller\"" 2
		echo_and_sleep "ALLOWED_HOSTS = ['*']" 2
		echo_and_sleep "CACHES = {" 1
		echo_and_sleep "    'default': {" 1
		echo_and_sleep "        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache'," 1
		echo_and_sleep "        'LOCATION': '127.0.0.1:11211'," 1
		echo_and_sleep "    }" 1
		echo_and_sleep "}" 1
		echo_and_sleep "And then restart the following services" 5
		echo_and_sleep "service apache2 restart" 2
		echo_and_sleep "service memcached restart" 2
fi
print_keystone_server_list
