if [ $# -ne 1 ]
	then
		echo "Correct Syntax: $0 [ allinone | controller | compute | networknode | controller_networknode ] <data-plane-eth-interface>"
		exit 1;
fi

if [ "$1" == "allinone" ]
	then
		echo "Configuring packages for All-in-one"
		bash lib/configure-packages.sh controller $2
		bash lib/configure-packages.sh networknode $2
		bash lib/configure-packages.sh compute $2
elif [ "$1" == "controller" ] || [ "$1" == "compute" ] || [ "$1" == "networknode" ]
	then
		echo "Configuring packages for: "$1
		bash lib/configure-packages.sh $1 $2
elif [ "$1" == "controller_networknode" ]
	then
		echo "Configuring packages for Controller and Network Node"
		bash lib/configure-packages.sh controller $2
		bash lib/configure-packages.sh networknode $2
else
	echo "Correct Syntax: $0 [ allinone | controller | compute | networknode | controller_networknode ] <data-plane-eth-interface>"
	exit 1;
fi
