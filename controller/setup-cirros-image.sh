source install-parameters.sh

echo_and_sleep "About to add cirros image to Glance"
cirros_image_name="cirros-0.3.3-x86_64-disk.img"
wget_url_for_cirros="http://cdn.download.cirros-cloud.net/0.3.3/"$cirros_image_name
echo_and_sleep "Cirros Image URL: $wget_url_for_cirros"
wget $wget_url_for_cirros
source admin_openrc.sh
echo_and_sleep "Downloaded Cirros Image. Ready to call glance image-create command" 3
glance image-create --name "cirros-0.3.3-x86_64" --file $cirros_image_name --disk-format qcow2 --container-format bare --is-public True --progress
echo_and_sleep "Completed glance image-create"
glance image-list
echo_and_sleep "Verify Glance Image List" 7
