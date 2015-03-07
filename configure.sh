if [ $# -ne 2 ]
	then
		echo "Correct Syntax: $0 [ allinone | controller | compute | networknode | controller_networknode ]"
		exit 1;
fi

if [ "$1" == "allinone" ]
	then
		echo "Configuring packages for All-in-one"
		bash lib/configure-packages.sh controller 
		bash lib/configure-packages.sh networknode
		bash lib/configure-packages.sh compute 
elif [ "$1" == "controller" ] || [ "$1" == "compute" ] || [ "$1" == "networknode" ]
	then
		echo "Configuring packages for: "$1
		bash lib/configure-packages.sh $1 
elif [ "$1" == "controller_networknode" ]
	then
		echo "Configuring packages for Controller and Network Node"
		bash lib/configure-packages.sh controller 
		bash lib/configure-packages.sh networknode
else
	echo "Correct Syntax: $0 [ allinone | controller | compute | networknode | controller_networknode ]" 
	exit 1;
fi
