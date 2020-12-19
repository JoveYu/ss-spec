#!/bin/bash

IP=127.0.0.1

echo '>> create ipset'
ipset destroy chnroute
ipset create chnroute hash:net

echo '>> import local route to ipset'
ipset add chnroute 0.0.0.0/8
ipset add chnroute 10.0.0.0/8
ipset add chnroute 100.64.0.0/10
ipset add chnroute 127.0.0.0/8
ipset add chnroute 169.254.0.0/16
ipset add chnroute 172.16.0.0/12
ipset add chnroute 192.0.0.0/24
ipset add chnroute 192.0.2.0/24
ipset add chnroute 192.88.99.0/24
ipset add chnroute 192.168.0.0/16
ipset add chnroute 198.18.0.0/15
ipset add chnroute 198.51.100.0/24
ipset add chnroute 203.0.113.0/24
ipset add chnroute 224.0.0.0/4
ipset add chnroute 240.0.0.0/4
ipset add chnroute 255.255.255.255/32

# curl 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | grep ipv4 | grep CN | awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > chnroute.txt
echo '>> import chnroute to ipset'
for i in $( cat /etc/chnroute.txt ) ; do ipset add chnroute $i ; done

echo '>> create new chain'
iptables -t nat -N SSREDIR

echo '>> ignore ss server ip'
iptables -t nat -A SSREDIR -d $IP -j RETURN

echo '>> ignore ipset ip'
iptables -t nat -A SSREDIR -m set --match-set chnroute dst -j RETURN

echo '>> redirect'
iptables -t nat -A SSREDIR -p tcp -j REDIRECT --to-ports 1081

echo '>> proxy traffic'
iptables -t nat -A OUTPUT -p tcp -j SSREDIR
