source install-parameters.sh
echo_and_sleep "Purging MariaDB..." 2
apt-get purge mariadb-server python-mysqldb -y

echo_and_sleep "Purging RabbitMQ..." 2
apt-get purge rabbitmq-server -y

echo_and_sleep "Purging Keystone..." 2
apt-get purge keystone python-keystoneclient -y

echo_and_sleep "Purging Glance..." 2
apt-get purge glance python-glanceclient -y

cirros_image_name="cirros-0.3.3-x86_64-disk.img"
wget_url_for_cirros="http://cdn.download.cirros-cloud.net/0.3.3/"$cirros_image_name
echo_and_sleep "URL for Image WGET:: "$wget_url_for_cirros 3
wget $wget_url_for_cirros

echo_and_sleep "Purging Nova..." 10
apt-get purge nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient -y

echo_and_sleep "Purging Neutron..." 10
apt-get purge neutron-server neutron-plugin-ml2 python-neutronclient -y

echo_and_sleep "Purging Horizon..." 10
apt-get purge openstack-dashboard apache2 libapache2-mod-wsgi memcached python-memcache -y


