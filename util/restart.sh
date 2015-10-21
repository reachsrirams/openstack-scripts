echo "Running: $0 $@"

if [ $# -ne 1 ]
	then
		echo "Correct Syntax: $0 [ all | nova | horizon | neutron ]"
		exit 1;
fi

$(dirname $0)/manage-services.sh $1 restart
