function change-ip-etc-host() {
	if [ $# -lt 2 ]
        	then
                	echo "Correct syntax: change-ip-etc-host <hostname> <new-ip-address>"
                	exit 1;
	fi
	if [ -z "$3" ]
        	then
                	hosts_file_name="/etc/hosts"
        	else
                	hosts_file_name=$3
	fi
	echo "Host File is: $hosts_file_name"
	grep -w " $1" $hosts_file_name
	if [ $? -eq 0 ] ;
        	then
                	echo "controller found - going to remove it"
                	sed_command="/ $1/d"
			echo "SED Command is:: "$sed_command
                	sed -i "$sed_command" $hosts_file_name
	fi
	echo "$2        $1" >> $hosts_file_name
	echo "After update $hosts_file_name contents..."
	grep -w " $1" $hosts_file_name
	sleep 2
}


echo "Running: $0 $@"
dir_path=$(dirname $0)

node_type=`bash $(dirname $0)/detect-nodetype.sh`
echo "Local host type is: $node_type"

local_ip_address=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Local host IP is: $local_ip_address"

local_host_name=`hostname`
echo "Local host name: $local_host_name"
sleep 3

if [ "$node_type" == "controller" ] || [ "$node_type" = "controller_networknode" ]
	then
		if [ $# -eq 1 ]
			then
				echo "Adding controller node info to /etc/hosts"
				change-ip-in-etc-hosts.sh $1 $local_ip_address
		else
			echo "Correct syntax: $0 <controller-host-name>"
			exit 1;
		fi
elif [ "$node_type" == "compute" ] || [ "$node_type" == "networknode" ]
	then
		if [ $# -eq 2 ]
			then
				echo "Updating local node IP address to /etc/hosts"
				change-ip-in-etc-hosts.sh $local_host_name $local_ip_address
	
				echo "Updating controller IP address to /etc/hosts"
				change-ip-in-etc-hosts.sh $1 $2
		else
			echo "Correct syntax: $0 <controller-host-name> <controller-ip-address>"
			exit 1;
		fi
else
	echo "Unsupported Node type for $0: $node_type"
	exit 1;
fi

