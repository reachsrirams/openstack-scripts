source install-parameters.sh
echo_and_sleep "Installing MariaDB..." 2
apt-get install mariadb-server python-mysqldb -y

echo_and_sleep "Installing RabbitMQ..." 2
apt-get install rabbitmq-server -y

echo_and_sleep "Installing Keystone..." 2
apt-get install keystone python-keystoneclient -y

echo_and_sleep "Installing Glance..." 2
apt-get install glance python-glanceclient -y

cirros_image_name="cirros-0.3.3-x86_64-disk.img"
wget_url_for_cirros="http://cdn.download.cirros-cloud.net/0.3.3/"$cirros_image_name
echo_and_sleep "URL for Image WGET:: "$wget_url_for_cirros 3
wget $wget_url_for_cirros

echo_and_sleep "Installing Nova..." 10
apt-get install nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient -y

echo_and_sleep "Installing Neutron..." 10
apt-get install neutron-server neutron-plugin-ml2 python-neutronclient -y

echo_and_sleep "Installing Horizon..." 10
apt-get install openstack-dashboard apache2 libapache2-mod-wsgi memcached python-memcache -y


