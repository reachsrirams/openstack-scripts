sh -c 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf'
sleep 2
sh -c 'echo "net.ipv4.conf.all.rp_filter=0" >> /etc/sysctl.conf'
sleep 2
sh -c 'echo "net.ipv4.conf.default.rp_filter=0" >> /etc/sysctl.conf'
sleep 2
echo "Configured sysctl.conf - applying changes"
sysctl -p
