node_type=`bash $(dirname $0)/../util/detect-nodetype.sh`
echo "Node Type detected as: $node_type"

if [ "$node_type" == "compute" ] || [ "$node_type" == "allinone" ]
	then
		egrep '(vmx|svm)' /proc/cpuinfo
		if [ $? -eq 1 ]
			then
				echo "Virtualization Extensions not available - using QEMU" 
				crudini --set /etc/nova/nova-compute.conf libvirt virt_type qemu
				sleep 2
				service nova-compute restart
		fi
else
	echo "This command does not work for Node type: $node_type"
fi
