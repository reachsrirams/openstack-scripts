if [ $# -lt 1 ]
	then
		echo "Correct syntax: $0 <data-plane-eth-interface>"
		exit 1;
fi
bash configure-controller-packages.sh
bash configure-networknode-packages.sh $1
