if [ $# -ne 1 ]
	then
		echo "Correct Syntax: $0 [ allinone | controller | compute | networknode | controller_networknode ]"
		exit 1;
fi

if [ "$1" == "allinone" ]
	then
		echo "Configuring packages for All-in-one"
		sleep 5
		bash lib/configure-packages.sh controller 
		bash lib/configure-packages.sh networknode
		bash lib/configure-packages.sh compute 
elif [ "$1" == "controller" ] || [ "$1" == "compute" ] || [ "$1" == "networknode" ]
	then
		echo "Configuring packages for: "$1
		sleep 5
		bash lib/configure-packages.sh $1 
elif [ "$1" == "controller_networknode" ]
	then
		echo "Configuring packages for Controller and Network Node"
		sleep 5
		bash lib/configure-packages.sh controller 
		bash lib/configure-packages.sh networknode
else
	echo "Correct Syntax: $0 [ allinone | controller | compute | networknode | controller_networknode ]" 
	exit 1;
fi
