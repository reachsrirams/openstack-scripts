service mysql restart
sleep 5
service keystone restart
sleep 3
service glance-api restart
sleep 3
service glance-registry restart
sleep 3
service nova-api restart
sleep 3
service nova-cert restart
sleep 3
service nova-consoleauth restart 
sleep 3
service nova-scheduler restart 
sleep 3
service nova-conductor restart 
sleep 3
service nova-novncproxy restart
sleep 3
service neutron-server restart
sleep 3
service apache2 restart
sleep 3
service memcached restart
sleep 3
service ceilometer-api restart
