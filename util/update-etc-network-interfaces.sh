if [ $# -lt 1 ]
	then
		echo "Correct syntax: $0 <interface-name>"
		exit 1;
fi

echo "auto $1" >> /etc/network/interfaces
sleep 1
echo "iface $1 inet manual" >> /etc/network/interfaces
sleep 1
echo "up ifconfig $1 up" >> /etc/network/interfaces
sleep 1
ifup $1
