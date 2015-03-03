if [ $# -lt 1 ]
	then
		echo "Correct Syntax: $0 [ allinone | controller | compute | networknode | controller_networknode ]"
		exit 1;
fi

if [ "$1" == "allinone" ]
	then
		bash install-packages common
		bash install-packages controller
		bash install-packages compute
		bash install-packages networknode
fi

if [ "$1" == "controller" ] || [ "$1" == "compute ] || [ "$1" == "networknode" ]
	then
		bash install-packages common
		bash install-packages $1
fi

if [ "$1" == "controller_networknode" ]
	then
		bash install-packages common
		bash install-packages controller
		bash install-packages networknode
fi

