if [ $# -lt 1 ]
	then
		echo "Correct Syntax: $0 [ compute | networknode | controller ]"
		exit 1;
fi

if [ "$1" == "networknode" ] || [ "$1" == "controller" ] 
	then
		sh -c 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf'
		sleep 2
fi

if [ "$1" == "networknode" ] || [ "$1" == "compute" ] || [ "$1" == "controller" ] 
	then
		sh -c 'echo "net.ipv4.conf.all.rp_filter=0" >> /etc/sysctl.conf'
		sleep 2
		sh -c 'echo "net.ipv4.conf.default.rp_filter=0" >> /etc/sysctl.conf'
		sleep 2
		echo "Configured sysctl.conf - applying changes"
		sysctl -p
	else
		echo "Correct Syntax: $0 [ compute | networknode | controller ]"
		exit 1;
fi
