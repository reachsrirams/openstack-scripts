if [ $# -lt 4]
	then
		echo "Correct Syntax: install-and-update-keystone <keystone-db-password> <mysql-username> <mysql-password> <controller-host-name>"
		exit 1
fi
echo "Installing Keystone..."
sleep 2
apt-get install keystone python-keystoneclient -y
if [ $? eq 0 ]
	then
		echo "Configuring MySQL for Keystone..."
		mysql -u "$2" -p"$1" <<EOF
		CREATE DATABASE keystone;
		GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$1';
		GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$1';
		EOF
		echo "Configuring Keystone - setting admin-token..."
		sed -e "/^#admin_token=.*$/s/^.*$/admin_token = $1/" -i /etc/keystone/keystone.conf
		echo "Configuring Keystone - setting DB Connection..."
		sed -e "/^connection =.*$/s/^.*$/connection = mysql:\/\/keystone:$1@$4\/keystone/" -i /etc/keystone/keystone.conf
