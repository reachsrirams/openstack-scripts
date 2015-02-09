source install-parameters.sh
if [ $# -lt 1 ]
	then
		echo "Correct syntax: $0 <controller-ip> <compute-host-name>"
		exit 1;
fi
compute_host_name="compute1"
if [ $# -eq 2 ]
	then
		compute_host_name=$2
fi
compute_ip_address=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "eth0 IP is: $compute_ip_address"
echo "Compute host name: $compute_host_name"
sleep 3

echo "Updating compute IP address to /etc/hosts"
bash change-ip-in-etc-hosts.sh $compute_host_name $compute_ip_address

echo "Updating controller IP address to /etc/hosts"
bash change-ip-in-etc-hosts.sh $controller_host_name $1

