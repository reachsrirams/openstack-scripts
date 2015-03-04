source config-parameters.sh
source admin_openrc.sh

if [ $# -ne 5 ]
	then
		echo "Correct syntax: $0 [ compute | networknode ]  <controller-host-name> <rabbitmq-password> <neutron-password> <data-traffic-interface>"
		exit 1;
fi

if [ "$1" != "compute" -a "$1" != "networknode" ]
	then
		echo "invalid first parameter"
		exit 1;
fi

echo_and_sleep "Configuring Neutron Conf File" 3

crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend rabbit
crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_host $2
crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_password $3
crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone

crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_uri http://$1:5000/v2.0
crudini --set /etc/neutron/neutron.conf keystone_authtoken identity_uri http://$2:35357
crudini --set /etc/neutron/neutron.conf keystone_authtoken admin_tenant_name service
crudini --set /etc/neutron/neutron.conf keystone_authtoken admin_user neutron
crudini --set /etc/neutron/neutron.conf keystone_authtoken admin_password $4

crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin ml2
crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins router
crudini --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips True
crudini --set /etc/neutron/neutron.conf DEFAULT verbose True

echo_and_sleep "Configuring ML2 INI file"
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers $neutron_ml2_type_drivers
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types $neutron_ml2_tenant_network_types
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers $neutron_ml2_mechanism_drivers

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vlan network_vlan_ranges physnet1:1001:1200
echo_and_sleep "Configured VLAN Range."

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_security_group True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs tenant_network_type $neutron_ovs_tenant_network_type
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs bridge_mappings physnet1:br-eth1
echo_and_sleep "Configured OVS Information" 2

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini linux_bridge tenant_network_type $neutron_linuxbridge_tenant_network_type
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini linux_bridge physical_interface_mappings physnet1:eth1
echo_and_sleep "Configured Linux Bridge" 2

if [ "$1" == "compute" ]
	then
		crudini --set /etc/nova/nova.conf DEFAULT network_api_class nova.network.neutronv2.api.API
		crudini --set /etc/nova/nova.conf DEFAULT security_group_api neutron
		crudini --set /etc/nova/nova.conf DEFAULT linuxnet_interface_driver nova.network.linux_net.LinuxOVSIntefaceDriver
		crudini --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
		echo_and_sleep "Configured Nova to use Neutron - DEFAULT section" 5
		
		crudini --set /etc/nova/nova.conf neutron url http://$2:9696
		crudini --set /etc/nova/nova.conf neutron auth_strategy keystone
		crudini --set /etc/nova/nova.conf neutron admin_auth_url http://$2:35357/v2.0
		crudini --set /etc/nova/nova.conf neutron admin_tenant_name service
		crudini --set /etc/nova/nova.conf neutron admin_username neutron
		crudini --set /etc/nova/nova.conf neutron admin_password $4
		echo_and_sleep "Configured Nova to use Neutron - neutron section" 5
fi

if [ "$1" == "networknode" ]
	then
		crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks external

		echo_and_sleep "Configuring L3 Agent Information" 2
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
fi
		
echo_and_sleep "Restarting Neutron related services" 2
service openvswitch-switch restart
echo_and_sleep "Restarted OVS Service..." 2
if [ "$1" == "compute" ]
	then
		service nova-compute restart
fi

if [ "$1" == "networknode" ]
	then
		service neutron-plugin-openvswitch-agent restart 
		service neutron-plugin-linuxbridge-agent restart 
		service neutron-l3-agent restart
		service neutron-dhcp-agent restart
		service neutron-metadata-agent restart
fi
