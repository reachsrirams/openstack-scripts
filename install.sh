if [ $# -ne 1 ]
	then
		echo "Correct Syntax: $0 [ allinone | controller | compute | networknode | controller_networknode | common ]"
		exit 1;
fi

if [ "$1" == "allinone" ]
	then
		echo "Installing packages for All-in-One"
		bash lib/install-packages.sh common
		bash lib/install-packages.sh controller
		bash lib/install-packages.sh compute
		bash lib/install-packages.sh networknode
elif [ "$1" == "controller" ] || [ "$1" == "compute" ] || [ "$1" == "networknode" ]
	then
		echo "Installing packages for: "$1
		bash lib/install-packages.sh common
		bash lib/install-packages.sh $1
elif [ "$1" == "controller_networknode" ]
	then
		echo "Installing packages for Controller and Network Node"
		bash lib/install-packages.sh common
		bash lib/install-packages.sh controller
		bash lib/install-packages.sh networknode
elif [ "$1" == "common" ]
	then
		echo "Installing common packages"
		bash lib/install-packages.sh common
else
	
	echo "Correct Syntax: $0 [ allinone | controller | compute | networknode | controller_networknode | common ]"
	exit 1;
fi
