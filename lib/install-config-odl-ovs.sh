echo "Running: $0 $@"
sleep 4
source $(dirname $0)/config-parameters.sh

if [ $# -lt 2 ]
	then
		echo "Correct syntax: $0 <controller | compute | allinone> <ODL IP Address> [external] [external-bridge-name]"
		exit 1;
fi

node_type=$1

if [ "$3" == external ]
	then
		echo "Setting L3 Agent for external bridge"
		crudini --set /etc/neutron/l3_agent.ini DEFAULT external_network_bridge $4
fi

echo_and_sleep "About to remove Linux Bridge and install OVS in Controller" 5
apt-get purge -y neutron-linuxbridge-agent neutron-openvswitch-agent
apt-get autoremove -y
apt-get install -y openvswitch-switch

service openvswitch-switch stop
echo_and_sleep "About to delete OVS Config DB" 3
rm -rf /var/log/openvswitch/*
rm -rf /etc/openvswitch/conf.db
echo_and_sleep "About to start OVS" 2
service openvswitch-switch start
ovs-vsctl show
echo_and_sleep "Executed OVS VSCTL Show" 3

if [ "$node_type" == "controller" ] || [ "node_type" == "allinone" ]
	then
		apt-get install -y python-networking-odl
		echo_and_sleep "Configuring ML2 INI file" 5
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers flat,vxlan
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types vxlan
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers opendaylight
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers port_security
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks public
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan vni_ranges 1:1000
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup firewall_driver iptables_hybrid

                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_odl username admin
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_odl password admin
                crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_odl url http://$2:8080/controller/nb/v2/neutron

		echo_and_sleep "Configuring L3 and DHCP Agent Information" 2
                crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
                crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
                crudini --set /etc/neutron/dhcp_agent.ini DEFAULT enable_isolated_metadata True
                crudini --set /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_ip controller
                crudini --set /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret password
fi
overlay_interface_ip=$(get-ip-address $data_interface)
echo "Overlay Interface IP Address: $overlay_interface_ip"
sleep 5
uuid_ovs=`ovs-vsctl get Open_vSwitch . _uuid`
echo "UUID of OVS: $uuid_ovs"
sleep 5
ovs-vsctl set Open_vSwitch $uuid_ovs other_config={local_ip=$overlay_interface_ip}
sleep 3
ovs-vsctl set-manager tcp:$2:6640
echo_and_sleep "Set the manager for OVS" 7
ovs-vsctl show
echo_and_sleep "Executed OVS VSCTL Show" 5

if [ "$node_type" == "networknode" ] || [ "node_type" == "controller" ] || [ "node_type" == "allinone" ]
	then
		service neutron-server restart
		service neutron-l3-agent restart
		service neutron-dhcp-agent restart
fi
