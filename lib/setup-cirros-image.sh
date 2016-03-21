source $(dirname $0)/config-parameters.sh

glance_image_name="cirros"
if [ ! -z $1 ]
	then
		glance_image_name=$1
fi

echo_and_sleep "About to add cirros image to Glance"
cirros_image_name="cirros-0.3.4-x86_64-disk.img"
wget_url_for_cirros="http://download.cirros-cloud.net/0.3.4/"$cirros_image_name
echo_and_sleep "Cirros Image URL: $wget_url_for_cirros"
wget $wget_url_for_cirros
source $(dirname $0)/admin_openrc.sh
echo_and_sleep "Downloaded Cirros Image. Ready to call glance image-create command" 3
openstack image create --public --file $cirros_image_name --disk-format qcow2 --container-format bare $glance_image_name
echo_and_sleep "Completed glance image-create"
glance image-list
echo_and_sleep "Verify Glance Image List" 7
