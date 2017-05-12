function change-ip-in-etc-hosts() {
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

function get-ip-address() {
        ip_address_val=''
        ubuntu_version=`lsb_release -sr`
        if [ "$ubuntu_version" == "17.04" ]
        then
                ip_address_val=`ifconfig $1 | grep 'inet ' | cut -d' ' -f10 | awk '{ print $1}'`
        elif [ "$ubuntu_version" == "16.04" ]
        then
                ip_address_val=`ifconfig $1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
        else
                echo "This release is supported only on Zesty (17.04) or Xenial (16.04)"
                exit 1;
        fi
        echo $ip_address_val
}

echo "Running: $0 $@"
echo ""
sleep 3
dir_path=$(dirname $0)

node_type=`bash $(dirname $0)/detect-nodetype.sh`
echo "Local host type is: $node_type"

local_ip_address=$(get-ip-address $1)
echo "Local host IP is: $local_ip_address"

local_host_name=`hostname`
echo "Local host name: $local_host_name"
sleep 3

if [ "$node_type" == "controller" ] || [ "$node_type" == "allinone" ]
	then
		if [ $# -eq 2 ]
			then
				echo "Adding controller node info to /etc/hosts"
				change-ip-in-etc-hosts $2 $local_ip_address
		else
			echo "Correct syntax: $0 <mgmt-interface-name> <controller-host-name>"
			exit 1;
		fi
elif [ "$node_type" == "compute" ] || [ "$node_type" == "networknode" ]
	then
		if [ $# -eq 3 ]
			then
				echo "Updating local node IP address to /etc/hosts"
				change-ip-in-etc-hosts $local_host_name $local_ip_address
	
				echo "Updating controller IP address to /etc/hosts"
				change-ip-in-etc-hosts $2 $3
		else
			echo "Correct syntax: $0 <mgmt-interface-name> <controller-host-name> <controller-ip-address>"
			exit 1;
		fi
else
	echo "Unsupported Node type for $0: $node_type"
	exit 1;
fi

