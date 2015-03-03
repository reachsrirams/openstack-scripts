if [ $# -lt 1 ]
	then
		echo "Correct syntax: $0 <data-plane-eth-interface>"
		exit 1;
fi
bash configure-packages-controller.sh
bash configure-packages-networknode.sh $1
