source install-parameters.sh
echo_and_sleep "About to install NTP Server"
apt-get install ntp -y
service ntp restart

echo_and_sleep "About to configure Packages for JUNO"
apt-get install ubuntu-cloud-keyring -y
echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu" \
  "trusty-updates/juno main" > /etc/apt/sources.list.d/cloudarchive-juno.list
apt-get update && apt-get dist-upgrade -y
apt-get autoremove -y
