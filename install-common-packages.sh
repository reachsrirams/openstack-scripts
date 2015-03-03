echo "About to install NTP Server"
sleep 5
apt-get install ntp -y
service ntp restart

echo "About to configure Packages for JUNO"
sleep 5
apt-get install ubuntu-cloud-keyring -y
echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu" \
  "trusty-updates/juno main" > /etc/apt/sources.list.d/cloudarchive-juno.list
echo "Doing full system update"
sleep 5
apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y
apt-get autoremove -y
