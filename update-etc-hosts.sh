echo "Running: $0 $@"
dir_path=$(dirname $0)
source $dir_path/lib/config-parameters.sh

local_ip_address=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "eth0 IP is: $local_ip_address"
sleep 3

local_host_name=`hostname`
echo "Local host name: $local_host_name"

if [ "$1" == "controller" ]
	then
		echo "Adding controller node info to /etc/hosts"
		sleep 3
		bash $dir_path/lib/change-ip-in-etc-hosts.sh $controller_host_name $local_ip_address
elif [ "$1" == "compute" ] || [ "$1" == "networknode" ]
	then
		if [ $# -eq 2 ]
			then
				echo "Updating local node IP address to /etc/hosts"
				bash $dir_path/lib/change-ip-in-etc-hosts.sh $local_host_name $local_ip_address
	
				echo "Updating controller IP address to /etc/hosts"
				bash $dir_path/lib/change-ip-in-etc-hosts.sh $controller_host_name $2
		else
			echo "Correct syntax: $0 [ compute | networknode ] <controller-ip-address>"
			exit 1;
		fi
else
	echo "Correct syntax: $0 [ controller | compute | networknode ] <controller-ip-address>"
	exit 1;
fi

