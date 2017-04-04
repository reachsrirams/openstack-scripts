if [ "$controller_host_name" == "" ]
then
	echo "Controller Host Name Environment variable is blank. Checking command line argument."
	if [ "$1" == "" ]
	then
		echo "Controller Host Name Command line argument is blank. Using default name for Controller."
		final_controller_host_name="controller"
	else
		final_controller_host_name=$1
	fi	
else
	final_controller_host_name=$controller_host_name
fi

echo "Final Controller Host Name: "$final_controller_host_name
	
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=password
export OS_AUTH_URL=http://$final_controller_host_name:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
