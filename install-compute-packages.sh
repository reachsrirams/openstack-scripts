source install-parameters.sh

echo "About to install Nova for Compute"
apt-get install nova-compute sysfsutils -y

echo "About to install Neutron for Compute"
apt-get install neutron-plugin-ml2 neutron-plugin-openvswitch-agent -y

echo "About to install Ceilometer for Compute"
apt-get install ceilometer-agent-compute -y

apt-get autoremove -y
