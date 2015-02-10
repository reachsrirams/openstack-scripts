echo "About to install Neutron for Network Node..."
sleep 5
apt-get install neutron-plugin-ml2 neutron-plugin-openvswitch-agent neutron-l3-agent neutron-dhcp-agent neutron-plugin-linuxbridge-agent -y
