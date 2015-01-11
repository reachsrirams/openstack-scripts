if [ $# -lt 1 ]
        then
                echo "Correct syntax: install-and-update-database <controller-ip>"
                exit 1;
fi
apt-get install mariadb-server python-mysqldb
if [ $? -eq 0 ]
	then
		echo "Updating MySQL Config File..."
		crudini --set /etc/mysql/my.cnf mysqld bind-address $1
		crudini --set /etc/mysql/my.cnf mysqld default-storage-engine innodb
		crudini --set /etc/mysql/my.cnf mysqld innodb_file_per_table 1
		crudini --set /etc/mysql/my.cnf mysqld collation-server utf8_general_ci
		crudini --set /etc/mysql/my.cnf mysqld character-set-server utf8
		crudini --set /etc/mysql/my.cnf mysqld init-connect 'SET NAMES utf8'

		echo "Restarting MySQL and securing installation..."
		service mysql restart;
		mysql_secure_installation;
fi

