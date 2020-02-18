#!/bin/bash
##### EN DEV ####
cp interfaces /etc/network/interfaces
cp dhcpd.conf /etc/dhcp/dhcpd.conf
cp isc-dhcp-server /etc/default/isc-dhcp-server


echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

sysctl -p

apt-get install -y openvpn isc-dhcp-server

echo "dev tap" > /etc/openvpn/configvpn.conf
echo "remote 192.168.103.39" >> /etc/openvpn/configvpn.conf

iptables -t nat -A POSTROUTING -o tap0 -j MASQUERADE
iptables-save > /etc/iptables_rules.save

rm ../../Demo-Voip-Hack

reboot
