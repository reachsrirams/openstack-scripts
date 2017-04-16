function drop-db() {
	mysql_command="DROP DATABASE IF EXISTS $1; "
	echo "MySQL DB Command is: "$mysql_command 
	sleep 3
	mysql -u "$2" -p"$3" -e "$mysql_command"
}

if [ $# -ne 2 ]
then
	echo "Correct Syntax: $0 <dbusername> <dbpassword>"
	exit 1
fi

drop-db keystone $1 $2
drop-db glance $1 $2
drop-db nova $1 $2
drop-db nova_api $1 $2
drop-db neutron $1 $2
