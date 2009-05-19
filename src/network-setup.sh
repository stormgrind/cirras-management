#/bin/sh

address=`ip addr list eth0 | grep "inet " | cut -d' ' -f6 | cut -d/ -f1`

if [ "$address" != "" ]; then
    exit
fi

# prepare network card
echo -e "DEVICE=eth0\nBOOTPROTO=none\nONBOOT=yes\nNETWORK=192.168.192.0\nNETMASK=255.255.255.0\nIPADDR=192.168.192.1\nUSERCTL=no" > /etc/sysconfig/network-scripts/ifcfg-eth0

# nameserver information
echo -e "nameserver 208.67.222.222\nnameserver 208.67.220.220" > /etc/resolv.conf

# enable forwarding
echo "FORWARD_IPV4=yes" >> /etc/sysconfig/network
echo "1" > /proc/sys/net/ipv4/ip_forward

# restarting network
/etc/init.d/network restart

# DHCP
echo -e "subnet 192.168.192.0 netmask 255.255.255.0 {\noption domain-name-servers 208.67.222.222, 208.67.220.220;\nrange dynamic-bootp 192.168.192.5 192.168.192.200;\noption subnet-mask 255.255.255.0;\noption broadcast-address 192.168.192.255;\noption routers 192.168.192.1;\n}" > /etc/dhcpd.conf

# restarting DHCP server
/etc/init.d/dhcpd restart