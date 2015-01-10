if [ $# -lt 2 ]
	then
		echo "Correct Syntax: install-and-update-rabbitmq <mq-username> <mq-password>"
		exit;
fi
apt-get install rabbitmq-server -y
if [ $? -eq 0 ]
	then
		echo "Rabbit MQ Install successful. Updating password..."
		rabbitmqctl change_password $1 $2
		echo "Rabbit MQ password updated."
fi
		
