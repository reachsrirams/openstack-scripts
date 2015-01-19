apt-get install mariadb-server python-mysqldb -y
if [ $? -eq 0 ]
	then
		echo "Updating MySQL Config File..."
		sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/my.cnf
		echo "Updated Bind Address"
		grep "bind" /etc/mysql/my.cnf
		echo "Updating MySQL Config File..."
		sleep 5
		sed -i "/\[mysqld\]/a default-storage-engine = innodb\\
				innodb_file_per_table\\
				collation-server = utf8_general_ci\\
				init-connect = 'SET NAMES utf8'\\
				character-set-server = utf8\\
		" /etc/mysql/my.cnf
		echo "Updated other MySQL Parameters"
		grep "storage-engine" /etc/mysql/my.cnf
		sleep 5
		echo "Restarting MySQL and securing installation..."
		service mysql restart;
		mysql_secure_installation;
fi

