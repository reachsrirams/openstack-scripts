if [ $# -ne 1 ]
	then
		echo "Correct Syntax: $0 [ allinone | controller | compute | networknode | controller_networknode ] <data-plane-eth-interface>"
		exit 1;
fi

eth0_ip=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "eth0 IP is: $eth0_ip"
sleep 3

if [ "$1" == "allinone" ]
	then
		bash lib/configure-packages.sh networknode $2
		bash lib/configure-packages.sh compute $2
elif [ "$1" == "controller" ] || [ "$1" == "compute" ] || [ "$1" == "networknode" ]
	then
		echo "Installing packages for: "$1
		bash lib/configure-packages.sh $1 $2
elif [ "$1" == "controller_networknode" ]
	then
		echo "Installing packages for: "$1
		bash lib/configure-packages.sh networknode $2
else
	echo "Correct Syntax: $0 [ allinone | controller | compute | networknode | controller_networknode ] <data-plane-eth-interface>"
	exit 1;
fi
