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
set -x
grep -w " $1" $hosts_file_name
if [ $? -eq 0 ] ;
        then
                echo "controller found - going to remove it"
                sed_command="/ $1/d"
		echo "SED Command is:: "$sed_command
                sed -i "$sed_command" $hosts_file_name
fi
echo "going to add back"
echo "$2        $1" >> $hosts_file_name
echo "After update $hosts_file_name contents..."
cat $hosts_file_name
sleep 2
