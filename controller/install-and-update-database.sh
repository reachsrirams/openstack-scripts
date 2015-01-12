if [ $# -lt 1 ]
        then
                echo "Correct syntax: install-and-update-database <controller-ip>"
                exit 1;
fi
apt-get install mariadb-server python-mysqldb
if [ $? -eq 0 ]
	then
		echo "Updating MySQL Config File..."
		sed -i  's/127.0.0.1/'$controller-ip' /g' /etc/mysql/my.cnf
		sed -i "/\[mysqld\]/a default-storage-engine = innodb\\
				innodb_file_per_table\\
				collation-server = utf8_general_ci\\
				init-connect = 'SET NAMES utf8'\\
				character-set-server = utf8\\
		" /etc/mysql/my.cnf

		echo "Restarting MySQL and securing installation..."
		service mysql restart;
		mysql_secure_installation;
fi

