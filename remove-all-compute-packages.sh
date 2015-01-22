source install-parameters.sh

echo "About to remove Nova for Compute"
apt-get purge nova-compute sysfsutils -y

echo "About to remove Neutron for Compute"
apt-get purge neutron-plugin-ml2 neutron-plugin-openvswitch-agent -y

apt-get autoremove
