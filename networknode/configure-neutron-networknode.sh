source install-parameters.sh
source admin_openrc.sh

if [ $# -lt 4 ]
	then
		echo "Correct syntax: $0 <controller-host-name> <rabbitmq-password> <neutron-password> <data-traffic-interface>"
		exit 1;
fi


echo_and_sleep "Configuring Neutron Conf File" 3

crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend rabbit
crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_host $1
crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_password $2
crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone

crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_uri http://$1:5000/v2.0
crudini --set /etc/neutron/neutron.conf keystone_authtoken identity_uri http://$1:35357
crudini --set /etc/neutron/neutron.conf keystone_authtoken admin_tenant_name service
crudini --set /etc/neutron/neutron.conf keystone_authtoken admin_user neutron
crudini --set /etc/neutron/neutron.conf keystone_authtoken admin_password $3

crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin ml2
crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins router
crudini --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips True
crudini --set /etc/neutron/neutron.conf DEFAULT verbose True

echo_and_sleep "Configuring ML2 INI file"
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers local,vlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_type vlan,local
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_driver openvswitch
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks external

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vlan network_vlan_ranges physnet1:1001:1200
echo_and_sleep "Configured VLAN Range."

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_security_group True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver

echo_and_sleep "Configuring L3 Agent Information" 1
crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
crudini --set /etc/neutron/l3_agent.ini DEFAULT use_namespaces True
crudini --set /etc/neutron/l3_agent.ini DEFAULT verbose True
echo_and_sleep "Configured L3 Agent Information" 2

echo_and_sleep "Configuring DHCP Agent Information" 1
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver neutron.agent.linux.dhcp.Dnsmasq
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT use_namespaces True
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT verbose True
echo_and_sleep "Configured DHCP Agent Information" 2

ovs-vsctl add-br br-eth1
ovs-vsctl add-port br-eth1 $4
ovs-vsctl show
echo_and_sleep "Configured OVS bridges" 2
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs tenant_network_type vlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs bridge_mappings phynet1:br-eth1
service openvswitch-switch restart
echo_and_sleep "Restarted OVS Service..." 2

service neutron-plugin-openvswitch-agent restart 
service neutron-l3-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart
echo_and_sleep "Restarted Neutron Services" 2
