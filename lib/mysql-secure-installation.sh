echo "Running: $0 $@"
source $(dirname $0)/config-parameters.sh
if [ $# -lt 2 ]
	then
		echo "Correct Syntax: $0 <mysql-username> <mysql-password>"
		exit 1
fi
echo_and_sleep "Changing MySQL password for $1" 2
mysqladmin -u $1 password $2
echo_and_sleep "Updating other security settings for MySQL"
#Credit for the block below goes to http://bertvv.github.io/notes-to-self/2015/11/16/automating-mysql_secure_installation/
mysql -u $1 <<_EOF_
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
_EOF_
echo_and_sleep "Restarting MySQL services..." 2
service mysql restart
