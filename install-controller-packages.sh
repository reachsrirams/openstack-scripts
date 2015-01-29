source install-parameters.sh
echo_and_sleep "Installing MariaDB..." 6
apt-get install mariadb-server python-mysqldb -y

echo_and_sleep "Installing RabbitMQ..." 6
apt-get install rabbitmq-server -y

echo_and_sleep "Installing Keystone..." 6
apt-get install keystone python-keystoneclient -y

echo_and_sleep "Installing Glance..." 6
apt-get install glance python-glanceclient -y

echo_and_sleep "Installing Nova..." 6
apt-get install nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient -y

echo_and_sleep "Installing Neutron..." 6
apt-get install neutron-server neutron-plugin-ml2 python-neutronclient -y

echo_and_sleep "Installing Horizon..." 6
apt-get install openstack-dashboard apache2 libapache2-mod-wsgi memcached python-memcache -y

echo_and_sleep "Installing Ceilometer..." 6
apt-get install mongodb-server -y
apt-get install ceilometer-api ceilometer-collector ceilometer-agent-central ceilometer-agent-notification ceilometer-alarm-evaluator ceilometer-alarm-notifier python-ceilometerclient -y

