source install-parameters.sh
if [ -z $1 ]
	then
		echo "Using default controller host name: "$controller_host_name
	else
		controller_host_name = $1
fi
local_ip=`hostname -I`
echo "IP to be configured in /etc/hosts: "$local_ip
controller_ip_address=$local_ip

echo "About to setup Maria DB..."
bash controller/install-and-update-database.sh

echo "About to setup RabbitMQ..."
bash controller/install-and-update-rabbitmq.sh $rabbitmq_user $rabbitmq_password

