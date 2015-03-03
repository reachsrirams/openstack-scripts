echo "Installing MariaDB..."
sleep 5
apt-get install mariadb-server python-mysqldb -y

echo "Installing RabbitMQ..." 
sleep 5
apt-get install rabbitmq-server -y

echo "Installing Keystone..."
sleep 5
apt-get install keystone python-keystoneclient -y

echo "Installing Glance..."
sleep 5
apt-get install glance python-glanceclient -y

echo "Installing Nova..."
sleep 5
apt-get install nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient -y

echo "Installing Neutron..."
sleep 5
apt-get install neutron-server neutron-plugin-ml2 python-neutronclient -y

echo "Installing Horizon..."
sleep 5
apt-get install openstack-dashboard apache2 libapache2-mod-wsgi memcached python-memcache -y

echo "Installing Ceilometer..."
sleep 5
apt-get install mongodb-server -y
apt-get install ceilometer-api ceilometer-collector ceilometer-agent-central ceilometer-agent-notification ceilometer-alarm-evaluator ceilometer-alarm-notifier python-ceilometerclient -y
