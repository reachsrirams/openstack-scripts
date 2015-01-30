if [ $# -lt 4 ]
	then
		 echo "Correct syntax: $0 <controller-host-name> <rabbitmq-password> <neutron-password> <data-traffic-interface>"
		exit 1;
fi

source install-parameters.sh

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
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers flat,vlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_type vlan,local
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_driver openvswitch

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vlan network_vlan_ranges physnet1:1001:1200
echo_and_sleep "Configured VLAN Range." 

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_security_group True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver

ovs-vsctl add-br br-eth1
ovs-vsctl add-port br-eth1 $4
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs tenant_network_type vlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs bridge_mappings physnet1:br-eth1
echo_and_sleep "Configured OVS Information"
service openvswitch-switch restart
echo_and_sleep "Restarting OVS Service..." 5

crudini --set /etc/nova/nova.conf DEFAULT network_api_class nova.network.neutronv2.api.API
crudini --set /etc/nova/nova.conf DEFAULT security_group_api neutron
crudini --set /etc/nova/nova.conf DEFAULT linuxnet_interface_driver nova.network.linux_net.LinuxOVSIntefaceDriver
crudini --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
echo_and_sleep "Configured Nova to use Neutron - DEFAULT section" 5

crudini --set /etc/nova/nova.conf neutron url http://$1:9696
crudini --set /etc/nova/nova.conf neutron auth_strategy keystone
crudini --set /etc/nova/nova.conf neutron admin_auth_url http://$1:35357/v2.0
crudini --set /etc/nova/nova.conf neutron admin_tenant_name service
crudini --set /etc/nova/nova.conf neutron admin_user neutron
crudini --set /etc/nova/nova.conf neutron admin_password $3
echo_and_sleep "Configured Nova to use Neutron - neutron section" 5

echo_and_sleep "Restarting Nova Service..." 2
service nova-compute restart
