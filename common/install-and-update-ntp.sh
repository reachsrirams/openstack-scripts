if [ -z "$1" ]
        then
                ntp_server="controller"
        else
                ntp_server=$1
fi
echo "NTP Server is: $ntp_server"
apt-get install ntp -y
if [ $? -eq 0 ] ;
        then
                echo "NTP packages installed - configuring NTP Server"
                set -x
                service ntp restart
fi
