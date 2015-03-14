echo "Running: $0 $@"
dir_path=$(dirname $0)

node_type=`bash $(dirname $0)/detect-nodetype.sh`
echo "Local host type is: $node_type"

local_ip_address=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Local host IP is: $local_ip_address"

local_host_name=`hostname`
echo "Local host name: $local_host_name"
sleep 3

if [ "$node_type" == "controller" ]
	then
		if [ $# -eq 1 ]
			then
				echo "Adding controller node info to /etc/hosts"
				bash $dir_path/change-ip-in-etc-hosts.sh $1 $local_ip_address
		else
			echo "Correct syntax: $0 <controller-host-name>"
			exit 1;
		fi
elif [ "$node_type" == "compute" ] || [ "$node_type" == "networknode" ]
	then
		if [ $# -eq 2 ]
			then
				echo "Updating local node IP address to /etc/hosts"
				bash $dir_path/change-ip-in-etc-hosts.sh $local_host_name $local_ip_address
	
				echo "Updating controller IP address to /etc/hosts"
				bash $dir_path/change-ip-in-etc-hosts.sh $1 $2
		else
			echo "Correct syntax: $0 <controller-host-name> <controller-ip-address>"
			exit 1;
		fi
else
	echo "Unsupported Node type for $0: $node_type"
	exit 1;
fi

