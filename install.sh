if [ $# -ne 1 ]
	then
		echo "Correct Syntax: $0 [ allinone | controller | compute | networknode | controller_networknode | common ]"
		exit 1;
fi

if [ "$1" == "allinone" ]
	then
		bash install-packages.sh common
		bash install-packages.sh controller
		bash install-packages.sh compute
		bash install-packages.sh networknode
elif [ "$1" == "controller" ] || [ "$1" == "compute" ] || [ "$1" == "networknode" ]
	then
		echo "Installing packages for: "$1
		bash install-packages.sh common
		bash install-packages.sh $1
elif [ "$1" == "controller_networknode" ]
	then
		echo "Installing packages for: "$1
		bash install-packages.sh common
		bash install-packages.sh controller
		bash install-packages.sh networknode
elif [ "$1" == "common" ]
	then
		echo "Installing common packages"
		bash install-packages.sh common
else
	
	echo "Correct Syntax: $0 [ allinone | controller | compute | networknode | controller_networknode | common ]"
	exit 1;
fi
