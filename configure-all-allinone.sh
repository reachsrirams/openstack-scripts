if [ $# -lt 1 ]
	then
		echo "Correct syntax: $0 <data-plane-eth-interface>"
		exit 1;
fi
eth0_ip=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "eth0 IP is: $eth0_ip"
sleep 3
bash configure-packages-controller.sh
bash configure-packages-networknode.sh $1
bash configure-packages-compute.sh $eth0_ip $1
